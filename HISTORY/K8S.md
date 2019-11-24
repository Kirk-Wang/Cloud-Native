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

本机 Mac, run 一个 image，这个 Image 我已经发布到了 Docker Hub(注意在 minikube 里面登录一下 docker hub)

```sh
kubectl run lotteryjs --image=lotteryjs/lotteryjs.com:latest --port=3000

#Exposing a service as a NodePort

kubectl expose deployment lotteryjs --type=NodePort

# minikube makes it easy to open this exposed endpoint in your browser:

minikube service lotteryjs

# Start a second local cluster:

minikube start -p cluster2

# Stop your local cluster:

minikube stop

# Delete your local cluster:

minikube delete
```