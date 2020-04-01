

### Creating the Registry

[Docker Registry](https://docs.docker.com/registry/)

[Deploy a registry server](https://docs.docker.com/registry/deploying/)

### Certificates

This example is set up in a way so you can use self-signed certificates. Of
course this is not something you would want to do in production, but this way we
ease up the task for those who are curious to try it out.
In order to create self-signed certificates, you could use the following command:

```bash
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout portus.key -out portus.crt
```

```sh
# 创建自签名证书
$ openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=cloud.xx.com"

# 将证书存储到 Kubernetes Secret 中
$ kubectl create secret generic cloud-xx-tls --from-file=tls.crt --from-file=tls.key -n kube-system

```

After that, you can simply move the ``portus.key`` and the ``portus.crt`` files
into the secrets directory.

### Configure the Docker daemon

```sh
cat /etc/docker/daemon.json
vi /etc/docker/daemon.json
```

```json
{
  "registry-mirrors": [
    "https://dockerhub.azk8s.cn",
    "https://hub-mirror.c.163.com"
  ],
  "allow-nondistributable-artifacts": ["registry.bifrontend.domain.com"],
  "insecure-registries": ["registry.bifrontend.domain.com"],
}
```

```sh
docker login registry.bifrontend.domain.com
docker tag hello-world:latest registry.bifrontend.domain.com/test/hello:v1
docker push registry.bifrontend.domain.com/test/hello:v1

docker tag hello-world:latest registry.bifrontend.domain.com:32604/test/hello:v1
docker push registry.bifrontend.domain.com:32604/test/hello:v1

docker --insecure-registry=registry.bifrontend.domain.com login registry.bifrontend.domain.com


kubectl get pods -n kube-system
kubectl logs registry-6fc9cb445b-qqtcg -n kube-system

docker login registry.bifrontend.domain.com
docker logout registry.bifrontend.domain.com
docker run registry.bifrontend.domain.com/test/hello:v1

docker rmi registry.bifrontend.domain.com/test/hello:v1
```