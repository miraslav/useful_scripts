# Harbor image cleaner

Deletes Harbor artifacts that are older than 14 days, are not `latest`, and are not running in Kubernetes.

`get.py` writes live image refs to `kmetrics.json`. `clean.py` then walks Harbor projects and deletes the rest.

## Rules

An artifact is deleted only if all of these are true:

- it is in `HARBOR_PROJECTS`
- it is older than `DAYS` (14)
- none of its tags start with `latest`
- the same `project/repo:tag` is not used by a live Deployment, StatefulSet, DaemonSet, CronJob, or Job
- a tag is also kept if the same `repo:tag` is running from another Harbor project

Deleting tags does not free disk. Harbor garbage collection still has to run afterwards.

## Setup

```bash
cd harbor-clean
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# set HARBOR_URL, HARBOR_USER, HARBOR_PASS, HARBOR_PROJECTS
# copy kubeconfig-qa.yml kubeconfig-prod.yml kubeconfig-preprod.yml here
```

Dry run first:

```bash
set -a && . ./.env && set +a
python3 get.py
DRY_RUN=true python3 clean.py
```

A daily timer at 03:00:

```bash
sudo cp harbor-clean.service harbor-clean.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now harbor-clean.timer
```
