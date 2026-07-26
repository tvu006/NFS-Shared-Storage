# NFS RWX Kubernetes Demo Runbook

## Project Overview

This runbook documents the procedures for deploying, verifying, and demonstrating an in-cluster NFS server providing ReadWriteMany (RWX) storage inside a Kind Kubernetes cluster.

Environment:

- Cluster: `nfs-cluster`
- Namespace: `nfs-tvu27`
- NFS Server Deployment: `nfs-server-tvu27`
- Shared PV: `pv-nfs-tvu27`
- Shared PVC: `pvc-shared-tvu27`

The deployment runs entirely inside Kind on a local EC2/Cloud9 host.

---

# 1. Bootstrap From a Clean Host

## Prerequisites

Verify required tools:

```bash
kind version
kubectl version --client
docker version