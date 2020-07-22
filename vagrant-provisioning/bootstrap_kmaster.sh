#!/bin/bash

# 阿里云镜像同步有延迟，当前最新版本是 1.18.3
KUBE_VERSION=1.18.3

# Initialize Kubernetes
echo "[TASK 1] Initialize Kubernetes Cluster"
# REPO="k8s.gcr.io/"
# kubeadm config images list 2>/dev/null | grep "k8s.gcr.io/" | grep "$REPO" | while IFS= read -r line; do
#     imageName="${line#$REPO}"
#     docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/"${imageName}"
#     docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/"${imageName}" "$REPO${imageName}"
#     docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/"${imageName}"
# done
kubeadm init --kubernetes-version="${KUBE_VERSION}" --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >>/root/kubeinit.log 2>/dev/null

# Copy Kube admin config
echo "[TASK 2] Copy kube admin config to Vagrant user .kube directory"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Deploy Calico network
echo "[TASK 3] Deploy Calico network"
su - vagrant -c "kubectl create -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml"

# Generate Cluster join command
echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command 2>/dev/null >/joincluster.sh
