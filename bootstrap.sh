#!/usr/bin/env bash

set -euo pipefail

# Configuration
STUDENTID="tvu27"

NAMESPACE="nfs-${STUDENTID}"
PV_NAME="pv-nfs-${STUDENTID}"
CLUSTER_NAME="nfs-cluster"

MANIFESTS="manifests"

# Create Kind Cluster
echo "Creating Kind cluster."

kind delete cluster --name "${CLUSTER_NAME}" >/dev/null 2>&1 || true

kind create cluster \
    --name "${CLUSTER_NAME}" \
    --config kind-config.yaml

# Namespace
echo "Creating namespace."

kubectl apply -f "${MANIFESTS}/namespace.yaml"

# Backend PVC
echo "Creating backend PVC."

kubectl apply -f "${MANIFESTS}/backend-pvc.yaml"

# NFS Server
echo "Deploying NFS server."

kubectl apply -f "${MANIFESTS}/nfs-server.yaml"
kubectl apply -f "${MANIFESTS}/nfs-service.yaml"

echo "Waiting for NFS server."

kubectl rollout status deployment/nfs-server-${STUDENTID} \
    -n "${NAMESPACE}" \
    --timeout=180s

# Get ClusterIP
echo "Retrieving NFS Service ClusterIP."

NFS_IP=$(kubectl get svc nfs-svc-${STUDENTID} \
    -n "${NAMESPACE}" \
    -o jsonpath='{.spec.clusterIP}')

echo "NFS Service IP: ${NFS_IP}"

# Render PV Template
echo "Rendering PV template..."

sed "s/__NFS_IP__/${NFS_IP}/g" \
    "${MANIFESTS}/pv-nfs.yaml.tpl" \
    > /tmp/pv-nfs.yaml

kubectl apply -f /tmp/pv-nfs.yaml

# Shared PVC
echo "Creating shared PVC."

kubectl apply -f "${MANIFESTS}/shared-pvc.yaml"
echo "Waiting for shared PVC."

kubectl wait \
    --for=jsonpath='{.status.phase}'=Bound \
    pvc/pvc-shared-${STUDENTID} \
    -n "${NAMESPACE}" \
    --timeout=120s

# Writer & Readers
echo "Deploying writer."

kubectl apply -f "${MANIFESTS}/writer-deployment.yaml"

echo "Deploying readers."

kubectl apply -f "${MANIFESTS}/reader-deployment.yaml"

# Wait for Pods
echo "Waiting for deployments."

kubectl rollout status deployment/writer-${STUDENTID} \
    -n "${NAMESPACE}" \
    --timeout=180s

kubectl rollout status deployment/reader-${STUDENTID} \
    -n "${NAMESPACE}" \
    --timeout=180s

# Wait until writer creates file
echo "Waiting until writer has produced 5 lines."

WRITER_POD=""

until [[ -n "${WRITER_POD}" ]]; do
    WRITER_POD=$(kubectl get pods \
        -n "${NAMESPACE}" \
        -l app=writer-${STUDENTID} \
        -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

    sleep 2
done

LINES=0

until [[ ${LINES} -ge 5 ]]; do

    LINES=$(kubectl exec \
        -n "${NAMESPACE}" \
        "${WRITER_POD}" \
        -- sh -c "test -f /data/log-${STUDENTID}.txt && wc -l < /data/log-${STUDENTID}.txt || echo 0")

    echo "Current lines: ${LINES}"

    sleep 2

done

# Final Status
echo "Deployment Complete."

kubectl get pv

kubectl get pvc -n "${NAMESPACE}"

kubectl get pods -o wide -n "${NAMESPACE}"

echo "Bootstrap completed successfully."