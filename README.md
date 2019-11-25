# Cloud-Native-And-DevOps

### Check Our Tools

* Docker Desktop preferred(Win/Mac)
* Docker Toolbox(Win 7/8/10 Home)
* Linux: Install via Docker Docs
  * [docs.docker.com](https://docs.docker.com)

### Getting Docker Compose
* CLI: docker-compose
  * Included in Docker Desktop & Toolbox
  * Linux: pip install docker-compose

```sh
docker version
# xx
docker-compose version
# xx
```

### Why Compose?
* 2 parts: CLI and YAML files
* Designed around developer workflows
* docker-compose CLI a substitute for docker CLI
* Use CLI by default locally

**OOPS!~I meant to say "I reccomend you use Docker Compose locally"**

### Compose File Format
* Docker standard (not yet industry std)
* Defines multiple containers, networks, volumes, etc.
* Can layer sets of YAML files, use templates, variables, and more
* docker-compose.yml default

### YAML
**YAML: "YAML Ain't Markup Language"**
* Common configuration file format
* Used by Docker, Kubernetes, Amazon, and others
* : used for key/value pairs
* Only spaces, no tabs
* - used for lists

### Compose YAML v2 vs V3
* Myth busting: v3 does not replace v2
* v2 focus: single-node dev/test
* v3 focus: muti-node orchestration
* If not using Swarm/Kubernetes, stick to v2

### docker-compose CLI
* many docker commands == docker-compose
* IDE's now support docker-compose
* "batteries included, but swappable"
* CLI and YAML versions differ

### docker-compose up
* "one stop shop"
* build/pull image(s) if missing
* create volume/network/container(s)
* starts containers(s) in foregound(-d to detach)
* --build to always build

### docker-compose down
* "one stop shop"
* stop and delete network/container(s)
* use -v to delete volumes

### docker-compose...
* Many commands take "service" option
* **build** just build/rebuild image(s)
* **stop** just stop containers don't delete
* **ps** list "services"
* **push** images to registry
* **logs** same as docker CLI
* **exec** same as docker CLI

### Compose CLI Basics
* Run through simple compose commands
```sh
cd sample-02
docker-compose up
ctrl-c (same as docker-compose stop)
docker-compose down
docker-compose up -d
docker-compose ps
docker-compose logs
```
* While app is running detached...
```sh
docker-compose exec web sh
curl localhost
exit
```
* edit Dockerfile, add curl with apk
```sh
RUN apk add --update curl
docker-compose up -d
```