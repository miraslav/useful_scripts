# Useful scripts

Personal sysadmin notes and scripts. Read a script before running it. Disk scripts ask for confirmation because they rewrite partition tables and filesystems.

## Layout

- `disk-manage/` — find empty disks, create LVM, extend VG/LV, rescan, XFS repair
- `docker/setup/ubuntu.sh` — current Docker Engine apt repository
- `docker/containers/` — Compose file for MySQL, Grafana, Prometheus, and Portainer
- `gitlab/setup/ubuntu.sh` — GitLab EE, requires `EXTERNAL_URL`
- `jenkins/setup/ubuntu.sh` — Jenkins LTS with OpenJDK 21
- `network-scripts/` — DNS lookups from a text file
- `gitlab_runner_cleaner.sh` — prune Docker data on a GitLab Runner host
- `ansible-mock-exam/` — exam answer playbooks, not production roles

## Examples

```bash
EXTERNAL_URL=https://gitlab.example.com bash gitlab/setup/ubuntu.sh
bash docker/containers/up.sh
bash disk-manage/get_empty_disk.sh
bash ping.sh server_list.txt
```
