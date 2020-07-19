for x in {0..10}; do 
    cat >> pvs.yaml << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gravity-vol-$(printf "%02d" $x)
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 20Gi
  nfs:
    path: /nfs/disk-$(printf "%02d" $x)
    server: 
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: nfs
---
EOF
done
