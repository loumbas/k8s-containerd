#Run On master
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=k8s-nfs.example.com --set nfs.path=/nfs/subdir --set storageClass.onDelete=true
