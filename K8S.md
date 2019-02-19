# K8S 快速上手

[minikube](https://github.com/kubernetes/minikube)

```sh
minikube # 看指令

minikube start

minikube ssh

exit

minikube profile test-minikub2 # 改变 profile
minikube start # 会新起一个 k8s-cluster
minikube profile minikube # 切回去
```

本机 mac

```sh
kubectl get node

kubectl cluster-info
```

本机 mac 启动 dashboard

```sh
kubectl cluster-info

minikube dashboard
```