#!/bin/bash

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Install Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Install Kubernetes components
sudo apt update && sudo apt install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize master node (only run on master)
if [ "$1" == "master" ]; then
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Install Calico network plugin
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

    # Generate join command for workers
    kubeadm token create --print-join-command > join_command.sh
    echo "Join command saved to join_command.sh"
fi

# Join worker nodes (only run on workers)
if [ "$1" == "worker" ]; then
    if [ -f join_command.sh ]; then
        bash join_command.sh
    else
        echo "Please copy the join command from master node and run it here."
    fi
fi
