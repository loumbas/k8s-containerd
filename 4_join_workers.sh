#run on workers only
sudo kubeadm join k8s-master.example.com:6443  --token <token> \
        --discovery-token-ca-cert-hash <ca-cert-hash>

#In case we do not have the tokens run this on master
sudo kubeadm token create --print-join-command
