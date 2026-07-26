apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-tvu27
spec:
  capacity:
    storage: 1Gi

  accessModes:
    - ReadWriteMany

  persistentVolumeReclaimPolicy: Retain

  storageClassName: ""

  mountOptions:
    - vers=4

  nfs:
    server: __NFS_IP__
    path: /