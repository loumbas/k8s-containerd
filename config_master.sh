#Source https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/
#Source https://docs.docker.com/engine/install/ubuntu/

#configure hostnames
sudo hostnamectl set-hostname "k8smaster.example.net"

#Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#Load Containerd
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
