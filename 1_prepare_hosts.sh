#Run on all hosts Master, Workers,NFS
# Disable swap
sudo swapoff -a
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# Set NTP
sudo sh -c 'echo "NTP=NTP_SERVER" >> /etc/systemd/timesyncd.conf'
sudo systemctl restart systemd-timesyncd 

# Disable automatic updates on Ubuntu
sudo systemctl disable --now unattended-upgrades.service
sudo dpkg-reconfigure unattended-upgrades

# Add FQDNs to /etc/hosts
sudo sh -c 'echo "xx.xx.xx.xx k8s-master.example.com k8s-master" >> /etc/hosts'
sudo sh -c 'echo "xx.xx.xx.xx k8s-worker1.example.com k8s-worker1" >> /etc/hosts'
sudo sh -c 'echo "xx.xx.xx.xx k8s-worker2.example.com k8s-worker2" >> /etc/hosts'
sudo sh -c 'echo "xx.xx.xx.xx k8s-worker3.example.com k8s-worker3" >> /etc/hosts'
sudo sh -c 'echo "xx.xx.xx.xx k8s-nfs.example.com k8s-nfs" >> /etc/hosts'


#Disable IPv6
sudo sh -c 'echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf'
sudo sh -c 'echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf'
sudo sh -c 'echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf'
sudo sysctl -p


#UPDATE PACKAGES
sudo apt-get update && sudo apt-get upgrade -y

#For the NFS Provisioner we need to install the NfS Client on all Kubernetes Mashines
sudo apt install nfs-client -y

#Reboot to load new kernel
sudo reboot

#Remove old kernels and packages
sudo apt autoremove --purge


#Prepare for containerd
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf 
overlay 
br_netfilter 
EOF

#Reload Configuration

sudo modprobe overlay
sudo modprobe br_netfilter


cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

#Reload system
sudo sysctl --system


#Install containerd,runc,
wget https://github.com/containerd/containerd/releases/download/v1.7.0/containerd-1.7.0-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.0-linux-amd64.tar.gz
wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.2.0.tgz
sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl status containerd


#Install Kubernets components
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=1.24.11-00 kubectl=1.24.11-00 kubeadm=1.24.11-00
sudo apt-mark hold kubelet kubeadm kubectl

