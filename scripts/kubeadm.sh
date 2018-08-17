#!/bin/bash

# Install docker vim apt-transport-https curl jq
apt-get update
apt-get install -y docker.io vim apt-transport-https curl jq

# Install kubelet kubeadm kubectl kubernetes-cni
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo sysctl net.bridge.bridge-nf-call-iptables=1

# swapoff
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# kubeadm init
kubeadm config images pull
kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# # Wait for apiserver running
A=''
while [ -z $A ]
do
  A=$(kubectl -n kube-system get pod kube-apiserver-ubuntu --template={{.status.phase}})
  sleep 1s
done

# Install flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

# Untaint the master node
kubectl taint nodes --all node-role.kubernetes.io/master-

# # Install and init Helm
curl -Lo helm-linux-amd64.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.8.0-linux-amd64.tar.gz && tar -zxvf helm-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/helm
helm Init

# kubectl -n kube-system get pod kube-apiserver-ubuntu --template={{.status.phase}}
# kubectl get pods -n kube-system
# kubectl get pods --all-namespaces
# kubectl cluster-info 
# systemctl daemon-reload
# systemctl restart kubelet
