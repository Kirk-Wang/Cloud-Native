#!/bin/bash

# kubeadm init --apiserver-advertise-address=YOUR_IP_HERE --pod-network-cidr=10.244.0.0/16

# mkdir $HOME/.kube
# cp /etc/kubernetes/admin.conf $HOME/.kube/config
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# If by some chance you misplaced the kubeadm join command you can generate another one on the master node by running
# kubeadm token create --print-join-command

# kubectl get nodes
