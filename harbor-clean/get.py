#!/usr/bin/env python3
import json
import os
import subprocess
from datetime import datetime

import utils

kubeconfig_path_preprod = os.getenv("KUBECONFIG_PREPROD", "kubeconfig-preprod.yml")
kubeconfig_path_prod = os.getenv("KUBECONFIG_PROD", "kubeconfig-prod.yml")
kubeconfig_path_qa = os.getenv("KUBECONFIG_QA", "kubeconfig-qa.yml")
harbor_host = os.getenv("HARBOR_REGISTRY", "harbor.halykmarket.com")
kmetrics_file = os.getenv("KMETRICS_FILE", "kmetrics.json")
qa_prefix = os.getenv("QA_NS_PREFIX", "hb-market-qa")
qa_count = int(os.getenv("QA_NS_COUNT", "10"))
ns_preprod = os.getenv("NS_PREPROD", "hb-market-preprod")
ns_prod = os.getenv("NS_PROD", "hb-market-prod")


def as_list(value):
    # kubectl failure used to return the string "NULL" and crash the concat
    return value if isinstance(value, list) else []


def remember(kmetrics, workload, namespace, image):
    if not workload or not image or image == "NULL":
        return
    env = kmetrics.setdefault(workload, {})
    env.setdefault(namespace, image)


def collect_harbor_images(kmetrics, kubeconfig):
    """Keep any Harbor image still referenced by a live workload."""
    cmd = [
        "kubectl",
        f"--kubeconfig={kubeconfig}",
        "get",
        "deploy,sts,ds,cronjob,job",
        "-A",
        "-o",
        "json",
        "--request-timeout=40s",
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        data = json.loads(result.stdout or "{}")
    except Exception as exc:
        print(f"[WARN] workload scan failed for {kubeconfig}: {exc}")
        return
    for item in data.get("items") or []:
        meta = item.get("metadata") or {}
        ns = meta.get("namespace") or ""
        name = meta.get("name") or ""
        spec = item.get("spec") or {}
        if "jobTemplate" in spec:
            spec = (spec.get("jobTemplate") or {}).get("spec") or {}
        podspec = ((spec.get("template") or {}).get("spec") or {})
        containers = (podspec.get("containers") or []) + (podspec.get("initContainers") or [])
        for container in containers:
            image = container.get("image") or ""
            if f"{harbor_host}/" not in image:
                continue
            remember(kmetrics, name, ns, image)


deployments = []
deployments_preprod = as_list(utils.get_deployments(kubeconfig_path_preprod, ns_preprod))
deployments_prod = as_list(utils.get_deployments(kubeconfig_path_prod, ns_prod))
for i in range(1, qa_count + 1):
    deployments_qa = as_list(utils.get_deployments(kubeconfig_path_qa, qa_prefix + str(i)))
    deployments = list(set(deployments + deployments_qa))
deployments = list(set(deployments + deployments_prod + deployments_preprod))

kmetrics = {}
for deployment in deployments:
    env = {}
    for i in range(1, qa_count + 1):
        env[qa_prefix + str(i)] = utils.get_images(
            kubeconfig_path_qa, qa_prefix + str(i), deployment
        )
    env[ns_preprod] = utils.get_images(kubeconfig_path_preprod, ns_preprod, deployment)
    env[ns_prod] = utils.get_images(kubeconfig_path_prod, ns_prod, deployment)
    kmetrics[deployment] = env

now = datetime.now()
for kubeconfig in (kubeconfig_path_qa, kubeconfig_path_prod, kubeconfig_path_preprod):
    collect_harbor_images(kmetrics, kubeconfig)

with open(kmetrics_file, "w", encoding="utf-8") as f:
    json.dump(kmetrics, f, ensure_ascii=False, indent=4)
print(str(now) + " - Ok")
