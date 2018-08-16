#!/bin/bash

set -xe
# Install Docker-CE
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    jq
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Install minikube & kubectl
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.11.2/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/

echo $HOME
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir $HOME/.kube || true
touch $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config

# socat is needed for portforwarding
sudo apt-get install -f socat

# Install kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
add-apt-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt-get update
apt-get install -y kubeadm=$(apt-cache madison kubeadm | grep "$KUBERNETES" | head -1 | awk '{print $3}')


# Install Helm
curl -Lo helm-linux-amd64.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz && tar -zxvf helm-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/helm

export DISPATCH_HOST=$(minikube ip)

# Download Dispatch
export LATEST=$(curl -s https://api.github.com/repos/vmware/dispatch/releases/latest | jq -r .name)
curl -OL https://github.com/vmware/dispatch/releases/download/$LATEST/dispatch-linux
chmod +x dispatch-linux
sudo mv dispatch-linux /usr/local/bin/dispatch

cat << EOF > config.yaml
apiGateway:
  host: $DISPATCH_HOST
dispatch:
  host: $DISPATCH_HOST
  debug: true
  skipAuth: true
EOF

# Start Minikube
# sudo minikube start --vm-driver=hyperkit
# sudo minikube start --vm-driver=kubeadm
# sudo minikube start --vm-driver=none --bootstrapper=kubeadm
sudo minikube start --vm-driver=none

# sudo chown -R $USER $HOME/.minikube
# sudo chgrp -R $USER $HOME/.minikube

# Helm Init
helm init --wait