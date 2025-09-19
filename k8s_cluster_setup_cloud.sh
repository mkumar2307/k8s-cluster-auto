#!/bin/bash

set -e

ROLE=$1

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Update system and install Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Install Kubernetes components
sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

if [ "$ROLE" == "master" ]; then
    # Initialize Kubernetes master
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16

    # Set up kubeconfig for the ubuntu user
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Install Calico network plugin
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

    # Generate join command
    kubeadm token create --print-join-command > join_command.sh
    echo "Join command saved to join_command.sh. Copy this to worker nodes."
else
    # Wait for join_command.sh to be available
    if [ -f join_command.sh ]; then
        bash join_command.sh
    else
        echo "Please copy join_command.sh from master node and run it manually."
    fi
fi
