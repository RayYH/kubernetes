#!/bin/bash

# 阿里云镜像同步有延迟，当前最新版本是 1.18.3
KUBE_VERSION=1.18.3

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts <<EOF
172.16.16.100 kmaster.example.com kmaster
172.16.16.101 kworker1.example.com kworker1
172.16.16.102 kworker2.example.com kworker2
EOF

# Install docker from Docker-ce repository
echo "[TASK 2] Install docker container engine"
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl --silent -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
yum clean all
yum makecache
yum install -y -q yum-utils device-mapper-persistent-data lvm2 >/dev/null 2>&1
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo >/dev/null 2>&1
yum install -y -q docker-ce >/dev/null 2>&1

# Enable docker service
echo "[TASK 3] Enable and start docker service"
systemctl enable docker >/dev/null 2>&1
systemctl start docker

# Disable SELinux
echo "[TASK 4] Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Stop and disable firewalld
echo "[TASK 5] Stop and Disable firewalld"
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld

# Add sysctl settings
echo "[TASK 6] Add sysctl settings"
cat >>/etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1

# Disable swap
echo "[TASK 7] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

# Add yum repo file for Kubernetes
echo "[TASK 8] Add yum repo file for kubernetes"
cat <<EOF >/etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# Install Kubernetes
echo "[TASK 9] Install Kubernetes (kubeadm, kubelet and kubectl)"
yum install -y -q "kubeadm-${KUBE_VERSION}" "kubelet-${KUBE_VERSION}" "kubectl-${KUBE_VERSION}" --disableexcludes=kubernetes >/dev/null 2>&1

# Start and Enable kubelet service
echo "[TASK 10] Enable and start kubelet service"
systemctl enable --now kubelet >/dev/null 2>&1
systemctl start kubelet >/dev/null 2>&1

# Enable ssh password authentication
echo "[TASK 11] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 12] Set root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1

# Update vagrant user's bashrc file
echo "export TERM=xterm" >>/etc/bashrc
