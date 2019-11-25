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
