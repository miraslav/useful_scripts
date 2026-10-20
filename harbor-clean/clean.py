#!/usr/bin/env python3

import json
import os
from datetime import datetime, timedelta, timezone
from urllib.parse import quote, urlparse

import requests


def env_bool(name, default):
    value = os.getenv(name)
    if value is None:
        return default
    return value.lower() in ("1", "true", "yes", "y")


HARBOR = os.getenv("HARBOR_URL", "").rstrip("/")
USER = os.getenv("HARBOR_USER", "")
PASS = os.getenv("HARBOR_PASS")

HARBOR_REGISTRY = os.getenv("HARBOR_REGISTRY") or urlparse(HARBOR).netloc
PROJECTS = [p.strip() for p in os.getenv("HARBOR_PROJECTS", "library").split(",") if p.strip()]
KMETRICS_FILE = os.getenv("KMETRICS_FILE", "kmetrics.json")

DAYS = int(os.getenv("DAYS", os.getenv("MIN_AGE_DAYS", "3")))
DRY_RUN = env_bool("DRY_RUN", True)
VERIFY_TLS = env_bool("VERIFY_TLS", False)
HTTP_TIMEOUT = int(os.getenv("HTTP_TIMEOUT", "30"))

# Protected tags. Default keeps latest.
PROTECT_TAG_PREFIXES = [
    tag.strip()
    for tag in os.getenv("PROTECT_TAG_PREFIXES", os.getenv("KEEP_TAGS", "latest")).split(",")
    if tag.strip()
]

requests.packages.urllib3.disable_warnings()


def encode_repo(repo):
    # Harbor wants slashes encoded twice: a/b -> a%252Fb
    return quote(quote(repo, safe=""), safe="")


def validate_config():
    missing = []
    if not HARBOR:
        missing.append("HARBOR_URL")
    if not USER:
        missing.append("HARBOR_USER")
    if not PASS:
        missing.append("HARBOR_PASS")
    if missing:
        raise SystemExit(f"[ERROR] Missing variables: {', '.join(missing)}")
    if not os.path.exists(KMETRICS_FILE):
        raise SystemExit(f"[ERROR] {KMETRICS_FILE} not found. Run get.py first")


def normalize_image(image):
    image = image.strip()
    if not image or image == "NULL":
        return ""

    name = image.split("@", 1)[0]
    first = name.split("/", 1)[0]
    if "/" not in name:
        image = f"docker.io/library/{image}"
    elif "." not in first and ":" not in first and first != "localhost":
        image = f"docker.io/{image}"

    tail = image.rsplit("/", 1)[-1]
    if "@" not in image and ":" not in tail:
        image += ":latest"

    return image


def parse_used_image(image):
    image = normalize_image(image)
    if not image:
        return None

    prefix = HARBOR_REGISTRY.rstrip("/").lower() + "/"
    image_lower = image.lower()
    if not image_lower.startswith(prefix):
        return None

    without_registry = image_lower[len(prefix):]
    if "@" in without_registry:
        repo, digest = without_registry.rsplit("@", 1)
        return {"repo": repo, "tag": None, "digest": digest}

    if ":" not in without_registry.rsplit("/", 1)[-1]:
        without_registry += ":latest"

    repo, tag = without_registry.rsplit(":", 1)
    return {"repo": repo, "tag": tag, "digest": None}


def load_used_refs(path=KMETRICS_FILE):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    used_tags = set()
    used_digests = set()

    for _service, envs in data.items():
        if not isinstance(envs, dict):
            continue

        for _env, image in envs.items():
            if not image or image == "NULL":
                continue

            parsed = parse_used_image(str(image))
            if not parsed:
                continue

            if parsed["digest"]:
                used_digests.add(f"{parsed['repo']}@{parsed['digest']}")
            elif parsed["tag"]:
                used_tags.add(f"{parsed['repo']}:{parsed['tag']}")

    return used_tags, used_digests


def tag_protected(tag):
    return any(tag.startswith(prefix) for prefix in PROTECT_TAG_PREFIXES)


def harbor_get(path, params=None):
    url = f"{HARBOR}/api/v2.0{path}"
    response = requests.get(
        url,
        params=params or {},
        auth=(USER, PASS),
        verify=VERIFY_TLS,
        timeout=HTTP_TIMEOUT,
    )
    if response.status_code != 200:
        raise RuntimeError(f"GET {url} failed: HTTP {response.status_code} {response.text[:300]}")
    return response.json()


def harbor_paged(path, params=None):
    result = []
    page = 1

    while True:
        query = dict(params or {})
        query["page"] = page
        query["page_size"] = 100

        items = harbor_get(path, query)
        result.extend(items)

        if len(items) < 100:
            return result

        page += 1


def get_repos(project):
    repos = harbor_paged(f"/projects/{quote(project, safe='')}/repositories")
    result = []

    for repo in repos:
        name = repo["name"]
        if name.startswith(project + "/"):
            name = name.split("/", 1)[1]
        result.append(name)

    return result


def get_artifacts(project, repo):
    return harbor_paged(
        f"/projects/{quote(project, safe='')}/repositories/{encode_repo(repo)}/artifacts",
        {"with_tag": "true"},
    )


def delete_artifact(project, repo, digest, tags):
    if DRY_RUN:
        print(f"[DRY-RUN] DELETE: {project}/{repo}@{digest} tags={tags}")
        return True

    url = (
        f"{HARBOR}/api/v2.0/projects/{quote(project, safe='')}"
        f"/repositories/{encode_repo(repo)}/artifacts/{quote(digest, safe='')}"
    )
    response = requests.delete(
        url,
        auth=(USER, PASS),
        verify=VERIFY_TLS,
        timeout=HTTP_TIMEOUT,
    )

    if response.status_code in (200, 202, 204):
        print(f"[DELETE] {project}/{repo}@{digest}")
        return True

    print(f"[ERROR] Failed to delete {project}/{repo}@{digest}: {response.status_code} {response.text[:300]}")
    return False


def parse_push_time(value):
    if not value:
        return None
    return datetime.fromisoformat(value.replace("Z", "+00:00")).astimezone(timezone.utc)


def artifact_used(project, repo, digest, tags, used_tags, used_digests):
    repo_ref = f"{project}/{repo}".lower()

    if f"{repo_ref}@{digest.lower()}" in used_digests:
        return True

    if any(f"{repo_ref}:{tag.lower()}" in used_tags for tag in tags):
        return True

    # The same repo:tag may run from another Harbor project. Keep both copies.
    suffix = f"/{repo.lower()}:"
    for tag in tags:
        needle = suffix + tag.lower()
        if any(
            ref.endswith(needle) or ref.split("/", 1)[-1] == f"{repo.lower()}:{tag.lower()}"
            for ref in used_tags
        ):
            return True
    return False


def main():
    validate_config()

    used_tags, used_digests = load_used_refs()
    threshold = datetime.now(timezone.utc) - timedelta(days=DAYS)

    deleted_or_candidate = 0
    kept = 0
    errors = 0

    print(f"[INFO] Harbor: {HARBOR}")
    print(f"[INFO] Projects: {PROJECTS}")
    print(f"[INFO] kmetrics: {KMETRICS_FILE}")
    print(f"[INFO] Loaded used tags: {len(used_tags)}")
    print(f"[INFO] Loaded used digests: {len(used_digests)}")
    print(f"[INFO] DRY_RUN={DRY_RUN}, older than {DAYS} days, threshold={threshold.isoformat()}")
    print(f"[INFO] Protected tag prefixes: {PROTECT_TAG_PREFIXES}\n")

    for project in PROJECTS:
        print(f"=== Project: {project} ===")

        try:
            repos = get_repos(project)
        except Exception as exc:
            errors += 1
            print(f"[ERROR] Cannot list repos in project={project}: {exc}")
            continue

        print(f"[INFO] Project {project}: {len(repos)} repos found")

        for repo in repos:
            print(f"\n--- Repo: {repo} ---")

            try:
                artifacts = get_artifacts(project, repo)
            except Exception as exc:
                errors += 1
                print(f"[ERROR] Cannot list artifacts for repo={repo}: {exc}")
                continue

            print(f"[INFO] Repo {repo}: {len(artifacts)} artifacts found")

            for artifact in artifacts:
                digest = artifact.get("digest", "")
                tags = [tag["name"] for tag in artifact.get("tags") or [] if tag.get("name")]
                push_time = parse_push_time(artifact.get("push_time"))

                print(f"\nArtifact {digest}")
                print(f"  Tags: {tags}")
                print(f"  Push time: {push_time}")

                if not tags:
                    kept += 1
                    print("  → Skip: no tags")
                    continue

                if any(tag_protected(tag) for tag in tags):
                    kept += 1
                    print("  → Skip: protected tag")
                    continue

                if artifact_used(project, repo, digest, tags, used_tags, used_digests):
                    kept += 1
                    print("  → Skip: used in Kubernetes")
                    continue

                if push_time is None:
                    kept += 1
                    print("  → Skip: unknown push_time")
                    continue

                if push_time > threshold:
                    kept += 1
                    print("  → Skip: fresh (< days limit)")
                    continue

                if delete_artifact(project, repo, digest, tags):
                    deleted_or_candidate += 1
                else:
                    errors += 1

    print(
        f"\n=== FINISHED — DRY_RUN={DRY_RUN}, "
        f"deleted_or_candidate={deleted_or_candidate}, kept={kept}, errors={errors} ==="
    )

    if errors:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
