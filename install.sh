#!/bin/bash

set -xe
# Install Docker-CE
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Install minikube & kubectl
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/

echo $HOME
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir $HOME/.kube || true
touch $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config

# Start Minikube
sudo minikube start --vm-driver=none --bootstrapper=kubeadm

sudo chown -R $USER $HOME/.minikube
sudo chgrp -R $USER $HOME/.minikube

# socat is needed for portforwarding
sudo apt-get install -f socat

# Install Helm
curl -Lo helm-linux-amd64.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.8.0-linux-amd64.tar.gz && tar -zxvf helm-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/helm

# Helm Init
helm init
