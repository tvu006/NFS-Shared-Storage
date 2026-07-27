
# NFS Shared Storage on Kubernetes (kind)

  

## Project Overview

  

This project demonstrates how to deploy an in-cluster NFS server on Kubernetes and provide shared **ReadWriteMany (RWX)** storage to multiple pods.

  

The environment runs entirely on a local **kind Kubernetes cluster** hosted on an AWS EC2/Cloud9 instance.

  

The demonstration proves that:

  

- Data is stored independently from pod lifecycle.

- Multiple pods can mount the same shared filesystem using NFS.

- A writer pod can be deleted and replaced without losing data.

- Two reader pods on different worker nodes can access the same file.

- ReadWriteOnce (RWO) storage behaves differently from ReadWriteMany (RWX).

- Multiple writers sharing the same file introduces concurrency risks.

  

## Technologies Used

  

- Kubernetes

- kind

- Docker

- NFS

- PersistentVolumes

- PersistentVolumeClaims

- Kubernetes Deployments

- Kubernetes Services

  

Images:

  

- NFS Server: `itsthenetwork/nfs-server-alpine:latest`

  

- Client workloads: `busybox`

  

## Running the Project

### Prerequisites

The host requires:

  

Docker

kubectl

kind

git

The project should be executed from the AWS EC2/Cloud9 environment.

  

Continue with runbook.md