# Network File System (NFS) Shared Storage Demo Runbook

# Project Overview
This runbook documents the procedures for deploying, verifying, and demonstrating an in-cluster NFS server providing ReadWriteMany (RWX) storage inside a Kind Kubernetes cluster.

Environment:

- Cluster: `nfs-cluster`
- Namespace: `nfs-tvu27`
- NFS Server Deployment: `nfs-server-tvu27`
- Shared PV: `pv-nfs-tvu27`
- Shared PVC: `pvc-shared-tvu27`

The deployment runs entirely inside Kind on a local EC2/Cloud9 host.

# 1. Clone Repo
```bash
git clone https://github.com/tvu006/NFS-Shared-Storage
cd NFS-Shared-Storage
```

# 2. Check Tools
```bash
# kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version

# kubectle
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

docker version
```

# 3. Bootstrap From a Clean Host
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

# 4. Verify
```bash
kubectl get nodes
kubectl get pods -o wide -n nfs-tvu27
kubectl get pv,pvc -n nfs-tvu27

kubectl exec -it <writer-pod> -n nfs-tvu27 -- tail -5 /data/log-tvu27.txt
kubectl exec -it <reader1> -n nfs-tvu27 -- tail -5 /data/log-tvu27.txt
```

# 5. Demo
# Prove RWO vs RWX
```bash
kubectl apply -f manifests/rwo-conflict.yaml
kubectl get pods -n nfs-tvu27
kubectl describe pod rwo-conflict -n nfs-tvu27
```

# 6. Twist
# Delete Writer
```bash
kubectl get pods -n nfs-tvu27
kubectl delete pod <writer-pod> -n nfs-tvu27
kubectl get pods -w -n nfs-tvu27
kubectl exec -it <new-writer> -n nfs-tvu27 -- tail -10 /data/log-tvu27.txt
```

# Scale
```bash
kubectl scale deployment writer-tvu27 --replicas=2 -n nfs-tvu27
kubectl exec -it <reader> -n nfs-tvu27 -- tail -20 /data/log-tvu27.txt
```

# Kill NFS Server Pod
```bash
kubectl exec -it <reader-pod> -n nfs-tvu27 -- tail -f /data/log-tvu27.txt
kubectl delete pod nfs-server-tvu27-8fcc55b7d-6xcdl -n nfs-tvu27
kubectl exec -it <reader-pod> -n nfs-tvu27 -- tail -20 /data/log-tvu27.txt
```

# 7. Destruction
```bash
kubectl delete namespace nfs-tvu27
kubectl delete pv pv-nfs-tvu27
kind delete cluster

kubectl get all -n nfs-tvu27
kubectl get pv
```