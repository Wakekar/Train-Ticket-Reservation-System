#!/bin/bash
# ================================================================
# Title   : Single-Node Kubernetes Cluster Setup (Kubeadm + containerd)
# Author  : Your Name
# Date    : 2026-01-17
# Purpose : Install kubeadm, kubelet, kubectl, containerd and 
#           create a single-node Kubernetes cluster for practice.
# Notes   : Pod network uses Flannel (10.244.0.0/16)
# ================================================================

#     How to Run
#     ✅ How to Use in Future
# Save as: setup-k8s.sh
# Make executable:
# chmod +x setup-k8s.sh
# Run as root or with sudo:
# sudo ./setup-k8s.sh
#    After completion, run:

#    kubectl get nodes
#    kubectl get pods -A
# You should see your node Ready and Flannel pods running.
# This script is robust for:
# Fresh Linux installs
# Ensuring containerd is running
# Setting up kubeadm with Flannel
# Avoiding port conflicts and leftover kubelet issues

set -e

echo "=== STEP 1: Update system and install dependencies ==="
sudo dnf update -y
sudo dnf install -y conntrack socat iproute-tc git curl wget vim bash-completion

echo "=== STEP 2: Install containerd ==="
sudo dnf install -y containerd
sudo systemctl enable --now containerd

echo "=== STEP 3: Download Kubernetes binaries ==="
K8S_VERSION="v1.27.16"
curl -LO https://dl.k8s.io/release/$K8S_VERSION/bin/linux/amd64/kubectl
curl -LO https://dl.k8s.io/release/$K8S_VERSION/bin/linux/amd64/kubeadm
curl -LO https://dl.k8s.io/release/$K8S_VERSION/bin/linux/amd64/kubelet

echo "=== STEP 4: Make binaries executable and move to PATH ==="
chmod +x kubectl kubeadm kubelet
sudo mv kubectl kubeadm kubelet /usr/local/bin/

echo "=== STEP 5: Enable and start kubelet service ==="
sudo tee /etc/systemd/system/kubelet.service <<EOF
[Unit]
Description=Kubernetes Node Agent
After=network.target

[Service]
ExecStart=/usr/local/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now kubelet

echo "=== STEP 6: Install crictl for container runtime ==="
CRICTL_VERSION="v1.27.0"
curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
sudo tar -C /usr/local/bin -xzf crictl-$CRICTL_VERSION-linux-amd64.tar.gz
rm -f crictl-$CRICTL_VERSION-linux-amd64.tar.gz

echo "=== STEP 7: Configure hostname in /etc/hosts ==="
HOSTNAME=$(hostname)
sudo bash -c "echo '127.0.0.1 $HOSTNAME localhost' >> /etc/hosts"

echo "=== STEP 8: Reset any previous kubeadm setup ==="
sudo kubeadm reset -f
sudo systemctl restart containerd
sudo systemctl restart kubelet

echo "=== STEP 9: Initialize Kubernetes cluster ==="
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///run/containerd/containerd.sock

echo "=== STEP 10: Configure kubectl for current user ==="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "=== STEP 11: Deploy Flannel network plugin ==="
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "=== STEP 12: Verify cluster status ==="
kubectl get nodes
kubectl get pods --all-namespaces
