
```sh
# kubeadm init \
#     --control-plane-endpoint "k8s-api:6443" --upload-certs \
#     --image-repository registry.aliyuncs.com/google_containers \
#     --pod-network-cidr=192.168.0.0/16 \
#     --v=6

kubeadm init \
    --apiserver-advertise-address=10.10.28.170 \
    --pod-network-cidr=10.244.0.0/16 \
    --image-repository registry.aliyuncs.com/google_containers

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
```