#run on workers only
sudo kubeadm join nsx-k8s-master.example.com:6443  --token <token> \
        --discovery-token-ca-cert-hash <ca-cert-hash>
