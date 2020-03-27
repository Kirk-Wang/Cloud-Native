

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
  "allow-nondistributable-artifacts": ["myregistrydomain.com:5000"],
  "insecure-registries": ["myregistrydomain.com:5000"],
}
```

```sh
service docker restart

docker login 10.10.28.156:5000
docker tag hello-world:latest 10.10.28.156:5000/username/hello-world:latest
docker push 10.10.28.156:5000/username/hello-world:latest


docker build -t portus.bifrontend.ruqimobility.com:5000/wangzuowei/gohttpserver:1.0 -f docker/Dockerfile .

docker login portus.bifrontend.ruqimobility.com:5000
docker push portus.bifrontend.ruqimobility.com:5000/wangzuowei/gohttpserver:1.0
```