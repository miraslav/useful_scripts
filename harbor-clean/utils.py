#!/usr/bin/env python3
import subprocess


def _run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True, check=True)


def get_deployments(kubeconfig, namespace):
    cmd = [
        "kubectl",
        f"--kubeconfig={kubeconfig}",
        "get",
        "deployment",
        "-n",
        namespace,
        "--request-timeout=40s",
    ]
    try:
        result = _run(cmd)
        lines = result.stdout.strip().split("\n")
        return [line.split()[0] for line in lines[1:] if line.strip()]
    except subprocess.CalledProcessError:
        return []


def get_images(kubeconfig, namespace, deployment):
    cmd = [
        "kubectl",
        f"--kubeconfig={kubeconfig}",
        "get",
        "deployment",
        "-n",
        namespace,
        deployment,
        "-o",
        "jsonpath={.spec.template.spec.containers[*].image}",
        "--request-timeout=40s",
    ]
    try:
        result = _run(cmd)
        return result.stdout.strip() or "NULL"
    except subprocess.CalledProcessError:
        return "NULL"
