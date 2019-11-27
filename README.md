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

### Compose CLI Basics-1
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
* Notice it didn't build so force it 
```sh
docker-compose up -d --build
```
* Now try curl again
```sh
docker-compose exec web sh
curl localhost
exit
```

### Cleanup
* Inside sample-02 directory
```sh
docker-compose down
docker-compose down --helps
```

### Compose CLI Basics-2

* build no chace
```sh
docker-compose build --no-cache
```
* `docker-compose ps`
```sh
sample-02_web_1   docker-entrypoint.sh node  ...   Up      0.0.0.0:3000->3000/tcp
```
  * `sample-02` -> name of the project
  * `web` -> name of the service
  * `1` -> numerical number of the replica

open [localhost:3000](http://localhost:3000)
* `docker-machine ls`
* `docker-compose logs`
```sh
docker-compose logs web
```
* `docker-compose exec`
```sh
docker-compose exec web sh
curl localhost
```
* add `RUN apk add --update curl` to `Dockerfile`
```sh
docker-compose up -d --build
docker-compose exec web sh
curl localhost
curl localhost:3000
docker-compose down
```

### Dockerfile Node Basics

[Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

* COPY, not ADD
* npm/yarn install during build
* CMD node, not npm 
  * requires another application to run
  * not as literal in Dockerfiles
  * doesn't work well as an init or PID 1 process
* WORKDIR not RUN mkdir
  * Unless you need chown

### FROM Base Image Guidelines

[Alpine Linux](https://www.alpinelinux.org/)|
[Node.js Release Schedule](https://github.com/nodejs/Release#release-schedule)|
[GitHub: ONBUILD deprecation](https://github.com/docker-library/official-images/issues/2076)|
[Node Official Image on Docker Hub](https://hub.docker.com/_/node)

* Stick to even numbered major releases
* Don't use :latest tag
* Start with Debian if migrating
* Move to Alpline later
* Don't use :slim
* Don't use :onbuild

### When to use Alpine Images
* Alpine is "small" and "sec focused"
* But Debian/Ubuntu are smaller now too
* ~100MB space savings isn't significant
* Alpine has its own issues
* Alpine CVE scanning fails
* Enterprises may require CentOS or Ubuntu/Debian

### Making a CentOS Node Image
* Install Node in the official CentOS
* Copy Dockerfile lines frome node:10
* Use ENV to specify node version
* This will take a few tries
* Useful for knowing how to make your own node, but only if you have to

### Assignment Answers:Making a CentOS Node Image

**NOTE: You must add 'USER node' before CMD in Dockerfile to enable non-root user**

```yml
# Dockfile
RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node
```

build
```sh
docker build -t centos-node .
docker run centos-node node --version
```

### Least Privilege: Using node User
* Official node images have a node user
* But it's not used by default
* Do this after `apt/apk` and `npm i -g`
* Do this before `npm i`
* May cause permissions issues with write access
* May require `chown node:node`
* Change user from root to node
```sh
USER node
```
* Set permissions on app dir
```sh
RUN mkdir app && chown -R node:node .
```
* Run a command as root in container
```sh
docker-compose exec -u root
```

### Making Images Efficiently
* Pick proper FROM
* Line order matters
* COPY twice: package.json* then . .
  1. copy only the package and lock files
  2. run npm install
  3. copy everything else
* One apt-get per Dockerfile
  * apt-get update cache prob

### Node Process Management In Containers
* No need for nodemon, forever, or pm2 on server
  * We'll use nodemon in dev for file watch later
* Docker manages app start, stop, restart, healthcheck
* Node multi-thread: Docker manages multiple "replicas"
* One npm/node problem: They don't listen for proper shutdown signal by default

### The Truth About The PID 1 Problem
* PID 1 (Process Identifier) is the first process in a system (or container) (AKA init)
* Init process in a container has two jobs:
  * reap zombie processes
  * pass signals to sub-processes
* Zombie not a big Node issue
* Focus on proper Node shutdown

### Proper CMD for Healthy Shutdown
* Docker uses Linux signals to stop app (SIGINT/SIGTERM/SIGKILL)
* SIGINT/SIGTERM allow graceful stop
* npm doesn't respond to SIGINT/SIGTERM
* node doesn't respond by default, but can with code
* Docker provides a init PID 1 replacement option

### Proper Node Shutdown Options
* Temp: Use --init to fix ctrl-c for now
* Workaround: add tini to your image
* Production: your app captures SIGINT for proper exit
* Run any node app with --init to handle signals(temp solution)
```sh
docker run --init -d nodeapp
```
* Add tini to your Dockerfile, then use it in CMD (permanent workaround)
```sh
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "./bin/www"]
```
* Use JS snippet to properly capture signals(production solution)
```sh
./sample-graceful-shutdown/sample.js
```

### Assignment: Node Dockerfiles
* Make a Dockerfile for existing Node app
* use ./assignment-dockerfile/Dockerfile
* Start with node 10.15 on alpine
* Install tini, start node with tini
* Copy package/lock files first, then npm, then copy

[Tini](https://github.com/krallin/tini)

```yml
FROM
EXPOSE
RUN
WORKDIR
COPY
RUN
COPY
ENTRYPOINT
CMD
```

```sh
docker build -t assignment1 .
docker run -p 3001:3000 assignment1
# docker run -d -p 3001:3000 assignment1
```

[localhost:3001](http://localhost:3001)

### Testing Graceful shutdowns
* Use ./assignment-dockerfile/
* Run with tini built in, try to ctrl-c
* Run with tini built in, try to stop
* Remove ENTRYPOINT, rebuild
* Add --init to run command,ctrl-c/stop
* Bonus: add signal watch code

```sh
docker build -t assignment1:notini .
docker run -d -p 3001:3000 assignment1:notini
docker top 48a6
docker stop 48a6
# docker run --init -d -p 3001:3000 assignment1:notini
# docker top

docker run -d -p 3002:3000 assignment1
docker top 6ec2
docker stop 6ec2
```

### Multi-stage Builds
* New feature in 17.06 (mid-2017)
* Build multiple images from on file
* Those images can FROM each other
* COPY files between them
* Space + Security benefits
* Great for "artifact only"
* Great for dev + test + prod
  1. FROM node as prod
  2. ENV NODE_ENV=production
  3. COPY package*.json ./
  4. RUN npm install && npm cache clear --force
  5. COPY . .
  6. CMD ["node", "./bin/wwww"]
  7. FROM prod as dev
  8. ENV NODE_ENV = development
  9. CMD ["nodemon", "./bin/www", "--inspect=0.0.0.0:9229"]
* To build dev image from dev stage
```sh
docker build -t myapp .
```
* To build prod image from prod stage
```sh
docker build -t myapp:prod --target prod .
```

### More Multi-stage
* Add a test stage that runs npm test
* Have CI build --target test stage before building prod
* Add npm install --only=development to dev stage
* Don't COPY code into dev stage

### Building A 3-Stage Dockerfile
* Create a Dockerfile from ./sample-multi-stage
* Create three stages for prod, dev, and test
* Prod has no devDependencies and runs node
* Dev includes devDep, runs nodemon
* Test has devDep, runs npm test
* Build all three stages with unique tags
* Goal: don't repeat lines

**Assignment Answers**
```sh
# prod
docker build -t multistage --target prod . && docker run --init -p 3000:3000 multistage

# dev
docker build -t multistage:dev --target dev . && docker run --init -p 3000:3000 multistage:dev

# test
docker build -t multistage:test --target test . && docker run --init multistage:test
```

### Cloud Native App Guidelines
* Follow [12factor.net](https://12factor.net) principles, especially
  * Use Environment Variables for config
  * Log to stdout/stderr
  * Pin all versions, even npm
  * Graceful exit SIGTERM/INIT
* Create a .dockerignore (like .gitignore)
* Heroku wrote a highly respected guide to creating distributed apps
* Twelve factors to consider when developing or designing distributed apps
* Containers are almost always distributed apps
* Good news: You get many of these by using Docker
* Lets focus on a few for Node.js

### 12 Factor:Config
* [12factor.net/config](https://12factor.net/config)
* Store environment config in Environment Variables (env vars)
* Docker & Compose are great at this with multiple options
* Old apps: Use CMD or ENTRYPOINT script with `envsubst` to pass env vars into conf files 

### 12 Factor:Logs
* [12factor.net/logs](https://12factor.net/logs)
* Apps shouldn't route or transport logs to anything but stdout/stderr
* `console.log()` works
* Winston/Bunyan/Morgan: Use levels to control verbosity
* Winston transport: "Console"

### .dockerignore
* Prevent bloat and unneeded files
  * .git/
  * node_modules/
  * npm-debug
  * docker-compose*.yml
* Not needed but useful in image
  * Dockerfile
  * README.md

### Migrating Traditional Apps
* "Traditional App" = Pre-Docker App
* Take a typical Node app and "migrate"
* ./assignment-mta
* add .dockerignore
* Create Dockerfile
* Change Winston transport to Console

### MTA Requirements
* See README.md for app details
* Image shouldn't include `in`, `out`, `node_modules` or `logs` directories
* Change Winston to Console `winston.transports.Console`
* bind-mount `in` and `out` dirs
* Set `CHARCOAL_FACTOR` to 0.1

### MTA Outcomes
* Running container with `./in` and `./out` bind-mounts results in new chalk images in `./out` on host
* Changing `--env CHARCOAL_FACTOR` changes look of image (test with 10)
* No `.gif` files in image
* `docker logs` shows Winston output

**Assignment**
```sh
docker build -t mta .
docker run mta
docker run -it mta bash

docker run -v $(pwd)/in:/app/in -v $(pwd)/out:/app/out mta
docker run -v $(pwd)/in:/app/in -v $(pwd)/out:/app/out --env CHARCOAL_FACTOR=10 mta
docker ps -l
docker logs dbda736f5c09

docker run -v $(pwd)/logs:/app/logs -v $(pwd)/in:/app/in -v $(pwd)/out:/app/out mta
docker run -v $(pwd)/logs:/app/logs -v $(pwd)/in:/app/in -v $(pwd)/out:/app/out --env CHARCOAL_FACTOR=10 mta
```

### Compose Project Tips: Do's
* cd ./compose-tips
* Do use docker-compose for local dev
* Do use v2 format for local dev
  * v2 only: depends_on, hardware specific
* Do study compose file and CLI features

### Compose Project Tips: Don'ts
* Unnecessary: "alias" & "container_name"
* Legacy: "expose" & "links"
* No need to set defaults

### Bind-Mounting Code
* Don't use host file paths
* Don't bing-mount databases
* For local dev only？don't copy in code
* DDforWin needs drive perms
* Perms: Linux != Windows 

### Bind-Mounting: Performance

### node_modules in Images
* Problem: we shouldn't build images with node_modules from host
  * Example: node-gyp
* Solution: add node_modules  to `.dockerignore`
* Let's do this to `./sample-sails`
  ```sh
  cp .gitignore .dockerignore
  docker build -t sailsbret .
  ```

### node_modules in Bind-Mounts
* Problem: we can't bind-mount node_modules from host on macOS/Windows (different arch)
* To Potential Solutions:
  * Never use `npm i` on host, run `npm i` in compose
  * Move modules in image, hide modules from host
```sh
# sample-express
docker-compose up # can't find module ...

docker-compose run express npm install
docker-compose up
```
* Solution 1, simple but less flexible;
  * You can't `docker-compose up` until you've used `docker-compose run`
  * node_modules on host is now only usable from container
* Solution 2, more setup but flexible:
  * Move node_modules up a directory in Dockerfile
  * Use empty volume to hide node_modules on bind-mount
  * node_modules on host doesn't conflict
  ```sh
  # .dockerignore--->node_modules
  ls
  npm install
  docker-compose build # rebuiding
  docker-compose up -d
  docker-compose ps
  docker-compose exec express bash
  ls node_modules/
  ```

### NPM, Yarn, and Other Tools in Compose
* Two ways to run various tools inside the container:
* docker-compose run: start a new container and run command/shell
* docker-compose exec: run additional command/shell in currently running container

```sh
# sample-strapi, .dockerignore -> node_modules
# Also remember to postinstall for strapi:
docker-compose run api npm i
docker-compose up

# other iterm
docker-compose exec api strapi --help
docker-compose exec api bash
```

### File Monitoring and Node Auto Restarts
* Use nodemon for compose file monitoring
* webpack-dev-server, etc. work the same
* Override Dockerfile via compose command
* If Windows, enable polling
* Create a nodemon.yml for advanced workflows(bower, webpack, parcel)
```sh
docker-compose run express npm install nodemon --save-dev

docker-compose build
docker-compose up
```

### Startup Order and Dependencies
* Problem: Multi-service apps start out of order, node might exit or cycle
* Multi-container apps need:
  * Dependency awareness
  * Name resolution (DNS)
  * Connection failure handling

### Dependency Awareness
* `depends_on:` when "up X", start Y first
* Fixes name resolution issues with "can't resolve <service_name>"
* Only for compose, not Orch
* compose YAML v2: works with healthchecks like a "wait for script"

### Connection Failure Handling
* `restart: on-failure`
  * Good: helps slow db startup and Node.js failing. Better: depends_on
  * Bad: could spike CPU with restart cycling
* Solution: build connection timeout, buffer, and retries in your apps

### Healthchecks for depends_on
* `depends_on`: is only dependency control by default
* Add v2 healthchecks for true "wait_for"
* Let's see some examples
  * Mongo
  * Postgres/MySQL
  * Web

### Making Microservices Easier
* Problem: many HTTP endpoints, many ports
* Solution: Nginx/HAProxy/Traefik for host header routing + wildcard localhost domain
* Problem: CORS failures in dev
* Solution: Proxy with  * header
* Problem: HTTPS locally
* Solution: Create local proxy certs

### Local DNS For Many Endpoints
* Problem: Multiple endpoints and need unique DNS for each
  * Use x.localhost, y.localhost in Chrome 