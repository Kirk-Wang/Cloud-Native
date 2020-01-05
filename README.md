# Cloud-Native-And-DevOps


Bitnami containers

Bitnami containers give you the latest stable versions of your application stacks, allowing you to focus on coding rather than updating dependencies or outdated libraries.

[Development Containers](https://bitnami.com/containers)|[Turnkey Containers](https://bitnami.com/containers#turnkey-containers)

## Kubernetes features (1.16)

### What and why of orchestration
* There are many computing orchestrators
* They make decisions about when and where to "do work"
* We've done this since the dawn of computing:Mainframe schedulers, Puppet, Terraform, AWS, Mesos, Hadoop, etc.
* Since 2014 we've had resurgence of new orchestration projects because:
  1. Popularity of distributed computing
  2. Docker containers as a app package and isolated runtime
* We needed "many servers to act like one, and run many containers"
* An the Container Orchestrator was born
* Many open source projects have been created in the last 5 years to:
  * Schedule running of containers on servers
  * Dispatch them across many nodes
  * Monitor and react to container and server health
  * Provide storage, networking, proxy, security, and logging features
  * Do all this in a declarative way, rather than imperative
  * Provide API's to allow extensibility and management

### Major container orchestration projects
* Kubernetes, aka K8s
* Docker Swarm(and Swarm classic)
* Apache Mesos/Marathon
* Cloud Foundry
* Amazon ECS(not OSS, AWS-only)
* HashiCorp Nomad
* Many of these tools run on top of Docker Engine
* Kubernetes is the one orchestator with many distributions

### Kubernetes distributions
* Kubernetes "vanilla upstream"(not a distribution)
* Cloud-Managed distros: AKS, GKE, EKS,DOK...
* Self-Managed distros: RedHat OpenShift, Docker Enterprise, Rancher, Canonical Charmed, openSUSE Kubic...
* Vanilla installers: Kubeadm, kops, kubicorn...
* Local dev/test: Docker Desktop, minikube, microK8s
* CI testing:kind
* Special builds: Rancher K3s
* And Many, many more..(86 as of June 2019)

### Kubernetes concepts
* Kubernetes is a container management system
* It runs and manages containerized applications on a cluster(one or more servers)
* Often this is simply called "container orchestration"
* Sometimes shortened to Kube or K8s("Kay-eights" or "Kates")

### Basic things we can ask Kubernetes to do
* Start 5 containers using image `atseashop/api:v1.3`
* Place an internal load balancer in front of these containers
* Start 10 containers using image `atseashop/webfront:v1.3`
* Place a public load balancer in front of these containers
* It's Black Friday(or Christmas), traffic spikes, grow our cluster and add containers
* New release!Replace my containers with the new image `atseashop/webfront:v1.4`
* Keep processing requests during the upgrade;update my containers one at a time

### Other things that Kubernetes can do for us
* Basic autoscaling
* Blue/green deployment, canary deployment
* Long running services, but also batch(one-off) and CRON-like jobs
* Overcommit our cluster and evict low-priority jobs
* Run services with stateful data(database etc.)
* Fine-grained access control defining what can be done whom on which resources
* Integrating third party services(service catalog)
* Automating complex tasks(operators)

### Kubernetes architecture
* Ha ha ha ha
* OK, I was trying to scare you, it's much simpler than that ❤️

### Kubernetes architecture: the nodes
* The nodes executing our containers run a collection of services:
  * a container Engine(typically Docker)
  * kubelet(the "node agent")
  * kube-proxy(a necessary but not sufficient network component)
* Nodes were formerly called "minions"
  * (You might see that word in older articles or documentation)

### Kubernetes architecture: the control plane
* The Kubernetes logic(its "brains") is a collection of services:
  * the API server(our point of entry to everything!)
  * core services like the scheduler and controller manager
  * `etcd` (a highly available key/value store; the "database" of Kubernetes)
* Together, these services form the control plane of our cluster
* The control plane is also called the "master"

### Running the control plane on special nodes
* It is common to reserve a dedicated node for the control plane
  * (Except for single-node development clusters, like when using minikube)
* This node is then called a "master"
  * (Yes,this is ambiguous:is the "master" a node, or the whole control plane?)
* Normal applications are restricted from running on this node
  * (By using a mechanism called "taints")
* When high availability is required, each service of the control plane must be resilient
* The control plane is then replicated on multiple nodes
  * (This is sometimes called a "multi-master" setup)

### Running the control plane outside containers
* The services of the control plane can run in or out of containers
* For instance: since `etcd` is a critical service, some people deploy it directly on a dedicated cluster(without containers)
  * (This is illustrated on the first "super complicated" schema)
* In some hosted Kubernetes offerings(e.g. AKS, GKE, EKS), the control plane is invisible
  * (We only "see" a Kubernetes API endpoint)
* In that case, there is no "master node"

`For this reason, it is more accurate to say "control plane" ranther than "master"`

### Do we need to run Docker at all?
No!
* By default, Kubernetes uses the Docker Engine to run containers
* Or leverage other pluggable runtimes through the Container Runtime Interface
* We could also use rkt("Rocket") from CoreOS(deprecated)
* containerd: maintained by Docker, IBM, and community
* Used by Docker Engine, microK8s, K3s, GKE, and standalone; has `ctr` CLI
* CRI-O: maintained by Red Hat, SUSE, and community; based on containerd
* Used by OpenShift and Kubic, version matched to Kubernetes

Yes!
* In this course, we'll run our apps on a single node first
* We may need to build images and ship them around
* We can dot these things without Docker
  * (and get diagnosed with NIH syndrome)
* Docker is still the most stable container engine today
  * (but other options are maturing very quickly)

NIH--> Not Invented Here

* On your development environments, CI pipelines...:
  * Yes, almost certainly
* On our production servers:
  * Yes(today)
  * Probally not(in the future)

More information about CRI `on the Kubernetes blog`

### Interacting with Kubernetes
* We will interact with our Kubernetes cluster through the Kubernetes API
* The Kubernetes API is (mostly) RESTful
* It allows us to create, read, update, delete resources
* A few common resource types are:
  * node (a machine == physical or virtual -- in our cluster)
  * pod (group of containers running together on a node)
  * service (stable network endpoint to connect to one or multiple containers)

### Pods
* Pods are a new abstraction!
* A `pod` can have multiple containers working together
* (But you usually only have on container per pod)
* Pod is our smallest deployable unit; Kubernetes can't mange containers directly
* IP address are associated with `pods`, not with individual containers
* Containers in a pod share `loacalhost`, and can share volumes
* Multiple containers in a pod are deployed together
* In reality, Docker doesn't know a pod, only containers/namespaces/volumes 


### Getting a Kubernetes cluster for learning
* Best: Get a environment locally
  * Docker Desktop(Win/MacOS), minikube(Win Home), or microk8s(Linux)
  * Small setup effort;free;flexible environments
  * Requires 2GB+ of memory
* Good: Setup a cloud Linux host to run microk8s
  * Great if you don't have the local resources to run Kubernetes
  * Small setup effort; only free for a while
  * My $50 DigitalOcean coupon lets you run Kubernetes free for a month
* Last choice: Use a browser-based solution
  * Low setup effort; but host is short-lived and has limited resources
  * Not all hands-on examples will work in the browser sandbox

### Docker Desktop(Windows 10/macOS)
* Docker Desktop(DD) is great for a local dev/test setup
* Requires modern macOS or Windows 10 Pro/Ent/Edu(no Home)
* Requires Hyper-V, and disables VirtualBox

Exercise
* Download Windows or macOS versions and install
* For Windows, ensure you pick "Linux Containers" mode
* Once running, enabled Kubernetes in Settings/Perferences

### Check your connection in a terminal
```sh
 kubectl get nodes
```

### minikube(Windows 10 Home)
* A good local install option if you can't run Docker Desktop
* Inspired by Docker Toolbox
* Will create a local VM and configure latest Kubernetes
* Has lots of other features with it `minikube` CLI
* But, requires spearate install of VirtualBox and kubectl
* May not work with older Windows version(YMMV)

Exercise
* Download and install `VirtualBox`
* Download `kubectl`, and add to $PATH
* Download and install `minikube`
* Run `minikube start` to create and run a Kubernetes VM
* Run `minikube stop` when you're done


### microk8s(linux)
* Easy install and management of local Kubernetes
* Made by Canonical(Ubuntu).Installs using `snap`.Works nearly everywhere
* Has lots of other features with its `microk8s` CLI
* But, requires you install snap if not on Ubuntu
* Runs on containerd rather than Docker, no biggie
* Needs alias setup for `microk8s.kubectl`

Exercise
* Install `microk8s`, change group permissions, then set alias in bashrc
```
sudo apt install snapd
sudo snap install microk8s --classic
microk8s.kubectl
sudo usermod -a -G microk8s <username>
echo "alias kubectl='microk8s.kubectl'" >> ~/.bashrc
```

### Web-based options
Last choice: Use a browser-based solution
* Low setup effort; but host is short-lived and has limited resources
* Services are not always working right, and may not be up to date
* Not all hands-on examples will work in the browser sandbox

Exercise
* Use a prebuilt Kubernetes server at `Katacoda`
* Or setup a Kubernetes node at `play-with-k8s.com`
* Maybe try the latest OpenShift at `learn.openshift.com`
* See if instruqt works for `a Kubernetes playground`

### shpod: For a consistent Kubernetes experience...
* You can use `shpod` for examples
* `shpod` provides a shell running in a pod on the cluster
* It comes with many tools pre-installed(helm, stern, curl, jq...)
* These tools are used in many exercises in these slides
* `shpod` also gives you shell completion and a fancy prompt
* Create it with `kubectl apply -f https://k8smastery.com/shpod.yaml`
* Attach to shell with `kubectl attach --namespace=shpod -ti shpod`
* After finishing course `kubectl delete -f https://k8smastery.com/shpod.yaml`

### First contact with `kubectl`
* `kubectl` is(almost) the only tool we'll need to talk to Kubernetes
* It is a rich CLI tool around the Kubernetes API
  * (Everything you can do with `kubectl`, you can do directly with the API)
* On our machines, there is a `~/.kube/config` file with:
  * the Kubernetes API address
  * the path to our TLS certificates used to authenticate
* You can also use the `--kubeconfig` flag to pass a config file
* Or directly `--server`, `--user`, etc.
* `kubectl` can be pronounced "Cube C T L", "Cube cuttle", "Cube cuddle"...
* I'll be using the official name "Cube Control"

### kubectl get
* Let's look at our `Node` resources with `kubectl get`!

Exercise
* Look at the composition of our cluster:
```sh
kubectl get node
```
* These commands are equivalent:
```sh
kubectl get no
kubectl get node
kubectl get nodes
```

### Obtaining machine-readable output
* `kubectl get` con output JSON, YAML, or be directly formatted

Exercise
* Give us more info about the nodes:
```sh
kubectl get nodes -o wide
```
* Let's have some YAML:
```sh
kubectl get no -o yaml
```
See that `kind: List` at the end? It's the type of our result!

### (Ab)using `kubectl` and `jq`
* It's super easy to build custom reports

Exercise
* Show the capacity of all our nodes as a stream of JSON objects:
```sh
kubectl get nodes -o json | jq ".items[] | {name:.metadata.name} + .status.capacity"
```

### Kubectl describe
* `kubectl describe` needs a resource type and (optionally) a resource name
* It is possible to provide a resource name prefix(all matching objects will be displayed)
* `kubectl describe` will retrieve some extra information about the resource

Exercise
* Look at the information available for your node name with one of the following:
```sh
kubectl describe node/<node>
kubectl describe node <node>

kubectl describe node/docker-desktop
```
(We should notice a bunch of control plane pods.)

### Exploring types and definitions
* We can list all available resource types by running `kubectl api-resources`
  * (in Kubernetes 1.10 and prior, this command used to be `kubectl get`)
* We can view the definition for a resource type with:
```sh
kubectl explain type
```
* We can view the definition of a field in a resource, for instance:
```sh
kubectl explain node.spec
```
* Or get the list of all fields and sub-fields:
```sh
kubectl explain node --recursive
```
e.g.
```sh
kubectl explain node
kubectl explain node.spec
```

### Introspection vs. documentation
* We can access the same information by reading the `API documentation`
* The API documentation is usually easier to read, but:
  * it won't show custom types(like Custom Resource Definitions)
  * We need to make sure that we look at the correct version
* `kubectl api-resources` and `kubectl explain` perform introspection
  * (they communicate with the API server and obtain the exact type definitions)

### Type names
* The most common resource names have three forms:
  * singular(e.g. `node`, `service`, `deployment`)
  * plural(e.g. `nodes`, `services`, `deployments`)
  * short(e.g. `no`, `svc`, `deploy`)
* Some resources do not have a short name
* `Endpoints` only have a plural form
  * (because even a single `Endpoints` resource is actually a list of endpoints)

### More `get` commands: Services
* A service is a stable endpoint to connect to "something"
  * (in the initial proposal, they were called "portals")

Exercise
* List the services on our cluster with one of these commands:
```
kubectl get services
kubectl get svc
```
There is already one service on our cluster: the Kubernetes API itself.

### More `get` commands: Listing running containers
* Containers are manipulated through pods
* A pod is a group of containers:
  * running together (on the same node)
  * sharing resources(RAM, CPU; but also network, volumes)

Exercise
* List pods on our cluster:
```sh
kubectl get pods
```

### Namespaces
* Namespaces allow us to segregate resources

Exercise
* List the namespaces on our cluster with one of these commands:
```sh
kubectl get namespaces
kubectl get namespace
kubectl get ns
```

You know what...This `kube-system` thing looks suspicious

In fact, I'm pretty sure it showed up earlier, when we did:
```sh
kubectl describe node <node-name>
```

### Accessing namespaces
* By default, `kubectl` uses the `default` namespace
* We can see resources in all namespaces with `--all-namespaces`

Exercise
* List the pods in all namespaces:
```sh
kubectl get pods --all-namespaces
```
* Since Kubernetes 1.14, we can also use `-A` as a shorter version:
```sh
kubectl get pods -A
```
Here are our system pods!

### What are all these control plane pods?
* `etcd` is our etcd server
* `kube-apiserver` is the API server
* `kube-controller-manager` and `kube-scheduler` are other control plane components
* `coredns` provides DNS-based service discovery(replacing kube-dns as of 1.11)
* `kube-proxy` is the(per-node) component managing port mappings and such
* `<net name>` is the optional(per-node) component managing the network overlay
* the `READY` column indicates the number of conatainers in each pod
* Note: this only shows containers, you won't see host svcs(e.g. microk8s)
* Also Note: you may see different namespaces depending on setup


### Scoping another namespace
* We can also look at a different namespace(other than `default`)

Exercise
* List only the pods in the `kube-system` namespace:
```sh
kubectl get pods --namespace=kube-system
kubectl get pods -n kube-system
```

### Namespaces and other `kubectl` commands
* We can use `-n/--namespace` with almost every `kubectl` command
* Example:
  * `kubectl create --namespace=X` to create something in namespace X
* We can use `-A/--all-namespaces` with most commands that manipulate multiple objects
* Examples:
  * `kubectl delete` can delete resources across multiple namespaces
  * `kubectl label` can add/remove/update labels across multiple namespaces

### What about `kube-public`?
Exercise
* List the pods in the `kube-public` namespace:
```sh
kubectl -n kube-public get pods
```

Nothing!

`kube-public` is created by our installer & `used for security bootstrapping`.

### Exploring `kube-public`
* The only interesting object in `kube-public` is a ConfigMap named `cluster-info`

Exercise
* List ConfigMap objects:
```sh
kubectl -n kube-public get configmaps
```
* inspect `cluster-info`:
```sh
kubectl -n kube-public get configmap cluster-info -o yaml
```
Note the `selfLink` URI:`/api/v1/namespaces/kube-public/configmaps/cluster-info`

We can use that (later in `kubectl context` lectures)!

```sh
kubectl -n kube-public get configmaps
kubectl -n kube-public get configmap cluster-info -o yaml
```

### What about `kube-node-lease`?
* Starting with kubernetes 1.14, there is `kube-node-lease` namespace
  * (or in Kubernetes 1.13 if the NodeLease feature gate is enabled)
* That namespace contains one Lease object per node
* Node leases are a new way to implement node heartbeats
  * (i.e. node regularly pinging the control plane to say "I'm alive!")
* For more details, see `KEP-0009` or the `node controller documentation`

### Running our first containers on Kubernetes
* First things first: we cannot run a container
* We are going to run a pod, and in that pod there will be a single container
* In that container in the pod, we are going to run a simple `ping` command
* Then we are going to start additional copies of the pod

### Starting a simple pod with `kubectl run`
* We need to spcify at least a name and the image we want to use

Exercise
* Let's ping `1.1.1.1`, Cloudflare's `public DNS resolver`:
```sh
kubectl run pingpong --image alpine ping 1.1.1.1
```
(Starting with Kubernetes 1.12, we get a message telling us that `kubectl run` is deprecated. Let's ignore it for now.)

### Behind the scenes of `kubectl run`
* Let's look at the resources that were created by `kubectl run`

Exercise
* List most resource types:
```sh
kubectl get all
```

We should see the following things:
* `deployment.apps/pingpong` (the deployment that we just created)
* `replicaset.apps/pingpong-xxxxxxxxx ` (a replica set created by the deployment)
* `pod/pingpong-xxxxxxxx-yyyyyyy` (a pod created by the replica set)

Note: as of 1.10.1, resource types are displayed in more detail.

### What are these different things?
* A deployment is a high-level construct
  * allows scaling, rolling updates, rollbacks
  * multiple deployments can be used together to implement a `canary deployment`
  * delegates pods management to replica sets
* A replica set is a low-level construct
  * makes sure that a given number of identical pods are running
  * allows scaling
  * rarely used directly
* Note: A replication controller is the (deprecated) predecessor of a replica set


### Our `pingpong` deployment
* `kubectl run` created a deployment, `deployment.apps/pingpong`
```
NAME                       DESIRED     CURRENT      UP-TO-DATE     AVAILABLE  AGE
deployment.apps/pingpong   1           1            1              1          10m 
``` 

* That deployment created a replica set,`replicaset.apps/pingpong-xxxxxxxxxxxxx`
```
NAME                                  DESIRED     CURRENT      READY      AGE
replicaset.apps/pingpong-7c8bbcd9bc   1           1            1          10m 
```

* That replica set created a pod, `pod/pingpong-xxxxxxxxxxxxx-yyyy`
```
NAME                            READY    STATUS      RESTARTS    AGE
pod/pingpong-7c8bbcd9bc-6c9qz   1/1      Running     0           10m
```

* We'll see later how these folks play together for:
  * scaling, high availability, rolling updates

### Viewing container output
* Let's use the `kubectl logs` command
* We will pass either a pod name, or a type/name
  * (E.g. if we specify a deployment or replica set, it will get the first pod in it)
* Unless specified otherwise, it will only show logs of the first container in the pod
  * (Good thing there's only one in ours!)

Exercise
* View the result of our `ping` command:
```
kubectl logs deploy/pingpong
```

### Scaling our application
* We can create additional copies of our container(I mean, our pod) with `kubectl scale`

Exercise
* Scale our `pingpong` deployment:
```sh
kubectl scale deploy/pingpong --replicas 3
```
* Note that this command does exactly the same thing:
```sh
kubectl scale deployment pingpong --replicas 3
```
Note: what if we tried to scale `replicaset.apps/pingpong-xxxxxxx`?

We could! But he deployment would notice it right away, and scale back to the ...

```sh
kubectl scale deploy/pingpong --replicas 3
```

Streaming logs in real time
* Just like `docker logs`, `kuberctl logs` supports conveninent options:
  * `-f/--follow` to stream logs in real time(a la `tail -f`)
  * `--tail` to indicate how many lines you want to see(from the end)
  * `--since` to get logs only after a given timestramp

Exercise
* View the latest logs of our `ping` command:
```sh
kubectl logs deploy/pingpong --tail 1 --follow
```
* Leave that command running, so that we can keep an eye on these logs

### Streaming logs of multiple pods
* What happens if we restart `kubctl logs`?

Exercise
* interrupt `kubectl logs` (with Ctrl-C)
* Restart it:
```sh
kubectl logs deploy/pingpong --tail 1 --follow
```

`kubectl logs` will warn us that multiple pods were found, and that it's showing us only one of them.

Let's leave `kubectl logs` running while we keep exploring.

### Resilience
* The deployment `pingpong` watches its `replica set`
* The replica set ensures that the right number of pods are running
* What happens if pods disappear?

Exercise
* In a separate window, watch the list of pods:
```sh
watch kubectl get pods
```
* Destroy the pod currently shown by `kubectl logs`:
```sh
kubectl delete pod pingpong-xxxxxxxxxxxxx-yyyyyy
```

e.g.
```sh
watch kubectl get pods
kubectl delete pod pingpong-xxxxxxxxxxxxx-yyyyyy
```

### What happened?
* `kubectl delete pod` terminates the pod gracefully
  * (sending it the TERM signal and waiting for it to shutdown)
* As soon as the pod is in "Terminating" state, the Replica Set replaces it
* But we can still see the output of the "Terminating" pod in `kubectl logs`
* Until 30 seconds later, when the grace period expires
* The pod is then killed, and `kubectl logs` exits

### What if we wanted something different?
* What if we wanted to start a "one-shot" container that doesn't get restarted?
* We could use `kubectl run --restart=OnFailure` or `kubectl run --restart=Never`
* These commands would create jobs or pods instead of deployments
* Under the hood, `kubectl run` invokes "generators" to create resource descriptions
* We could also write these resource descriptions ourselves(typically in YAML),
  and create them on the cluster with `kubectl apply -f`(discussed later)
* With `kubectl run --schedule=...`, we can also create cronjobs.

### Scheduling periodic background work
* A Cron Job is a job that will be executed at specific intervals
  * (the name comes from the traditional cronjobs executed by the UNIX crond)
* It requires a schedule,represented as five space-separated fields:
  * minute[0,59]
  * hour[0,23]
  * day of the month[1,31]
  * month of the year[1,12]
  * day of the week([0,6] with 0=Sunday)
* `*` means "all vaild values";`/N` means "every N"
* Example: `*/3 * * * *` means "every three minutes"

### Creating a Cron Job
* Let's create a simple job to be executed every three minutes
* Cron Jobs need to terminate, otherwise they'd run forever

Exercise
* Create the Cron Job:
```sh
kubectl run --schedule="*/3 * * * *" --restart=OnFailure --image=alpine sleep 10
```
* Check the resource that was created:
```sh
kubectl get cronjobs
```

### Cron Jobs in action
* At the specified schedule, the Cron Job will create a Job
* The Job will create a Pod
* The Job will make sure that the Pod completes
  * (re-creating another on if it fails, for instance if its node fails)

Exercise
* Check the Jobs that are created:
```sh
kubectl get jobs
```
(it will take a few minutes before the first job is scheduled.)


### What about that deprecation warning?

* As we can see from the previous slide, `kubectl run` can do many things
* The exact type of resource created is not obvious
* To make things more explicit, it is better to use `kubectl create`:
  * `kubectl create deployment` to create a deployment
  * `kubectl create job` to create a job
  * `kubectl create cronjob` to run a job periodically
    * (since Kubernetes 1.14)
* Eventually, `kubectl run` will be used only to start one-shot pods
  * (see https://github.com/kubernetes/kubernetes/pull/68132)

### Various ways of creating resources
* `kubectl run`
  * easy way to get started
  * versatile
* `kubectl create <resource>`
  * explicit, but lacks some features
  * can't create a CronJob before Kubernetes 1.14
  * can't pass command-lin arguments to deployments
* `kubectl create -f foo.yaml` or `kubectl apply -f foo.yaml`
  * all features are available
  * requires writing YAML

### Streaming logs of multiple pods
* Can we stream the logs of all our `pingpong` pods?

Exercise
* Combine `-l` and `-f` flags:
```sh
kubectl logs -l run=pingpong --tail 1 -f
```

Note: combining `-l` and `-f` is only possible since Kubernetes 1.14!

Let's try to understand why...


### Streaming logs of many pods
* Let's see what happens if we try to stream the logs for more than 5 pods

Exercise
* Scale up our deployment:
```sh
kubectl scale deployment pingpong --replicas=8
```
* Stream the logs
```sh
kubectl logs -l run=pingpong --tail 1 -f
```

We see a message like the following one:
```
error: your are attempting to follow 8 log streams,
but maximum allowed concurency is 5,
use --max-log-requests to increase the limit
```
e.g.
```sh
kubectl scale deployment pingpong --replicas=8
kubectl get pods
kubectl logs -l run=pingpong --tail 1 -f
# error: you are attempting to follow 8 log streams, but maximum allowed concurency is 5, use --max-log-requests to increase the limit
```
### Why can't we stream the logs of many pods?
* `kubectl` opens one connection to the API server per pod
* For each pod, the API server opens one extra connection to the corresponding kubelet
* If there are 1000 pods in our deployments, that's 1000 inbound + 1000 outbound connections on the API server
* This could easily put a lot of stress on the API server
* Prior Kubernetes 1.14, it was decided to not allow multiple connections
* From Kubernetes 1.14, it is allowed, but limited to 5 connetcions
  * (this can be changed with `--max-log-requests`)
* For more details about the rationale, see `PR #67573`

### Shortcomings of `kubectl logs`
* We don't see which pod sent which log line
* If pods are restarted/replaced, the log stream stops
* If new pods are added, we don't see their logs
* To stream the logs of multiple pods, we need to write a selector
* There are external tools to address these shortcomings
  * (e.g.: Stern)


### Accessing logs from the CLI
* The `kubectl logs` commands has limitaions:
  * it cannot stream logs from multiple pods at a time
  * when showing logs from multiple pods, it mixes them all together
* We are going to see how to do it better


### Doing it manually
* We could(if we were so inclined) write a program or script that would:
  * take a selector as an argument
  * enumerate all pods matching that selector (with `kubectl get -l...`)
  * for one `kubectl logs --follow ...` command per container
  * annotate the logs (the output of each `kubectl logs ....` process) with their origin
  * preserve ordering by using `kubectl logs --timestramps ...` and merge the output
* We could do it, but thankfully, other did it for us already!

### Stern
[Stern](https://github.com/wercker/stern) is an open source project by `Wercker`

From the README:
```
Stern allows you to tail multiple pods on Kubernetes and multiple containers within the pod. Each result is color coded for quicker debugging.

The query is a regular expression so the pod name can easily be filtered and you don't need to specify the exact id (for instance omitting the deployment id). If a pod is deleted it gets removed from tail and if a new pod is added it automatically gets tailed.
```

Exactly what we need!

### Installing Stern
* Run `stern`(without arguments) to check if it's installed
```
$ stern
Tail multiple pods and containers from Kubernetes

Usage:
stern pod-query [flags]
```
* If it is not installed, the easiest method is to download a `binary release`
* The following commands will install Stern on a Linux Intel 64 bit machine:
```sh
sudo curl -L -o /usr/local/bin/stern \
  https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
sudo chmod +x /usr/local/bin/stern
```
* On OS X, just `brew install stern`

### Using Stern
* There are two ways to specify the pods whose logs we want to see:
  * `-l` followed by a selector expression(like with many `kubectl` commands)
  * with a "pod query," i.e. a regex used to match pod names
* These two ways can be combined if necessary

Exercise
* View the logs for all the pingpong containers:
```sh
stern pingpong
```

### Stern conveninent options
* The `--tail N` flag shows the last `N` lines for each container
  * (instead of showing the logs since the creation of the container)
* The `-t`/`--timestamps` flag shows timestamps
* The `--all-namespaces` flag is self-explanatory

Exercise
* View what's up with the `pingpong` system containers:
```sh
stern --tail 1 --timestamps pingpong
```

### Cleanup
Let's cleanup before we start the next lecture!

Exercise
* remove our deployment and cronjob:
```sh
kubectl delete deployment/pingpong cronjob/sleep
```

### 19,000 words
* They say, "a picture is worth one thousand words."
* The following 19 slides show what really happens when we run:
```sh
kubectl run web --image=nginx --replicas=3
```

### Exposing containers
* `kubectl expose` creates a service for existing pods
* A service is a stable address for a pod (or a bunch of pods)
* If we want to connect to our pod(s), we need to create a service
* Once a service is created, CoreDNS will allow us to resolve it by name
  * (i.e. after creating service `hello`, the name `hello` will resolve to something)
* There are different types of services, detailed on the following slides:
  * `ClusterIP`, `NodePort`, `LoadBalancer`, `ExternalName`

### Basic service types
* `ClusterIP`(default type)
  * a virtual IP address is allocated for the service(in an internal, private range)
  * this IP address is reachable only from within the cluster(nodes and pods)
  * our code can connect to the service using the original port number
* `NodePort`
  * a port is allocated for the service(by default, in the 30000-32768 range)
  * that port is made available on all our nodes and anybody can connect to it
  * our code must be changed to connect to that new port number

These service types are always available.

Under the hood:`kube-proxy` is using a userland proxy and a bunch of `iptables` rules.

* `LoadBalancer`
  * an external load balancer is allocated for the service
  * the load balancer is configured accordingly
    * (e.g.: a `NodePort` service is created, and the load balancer sends traffic to that port)
  * available only when the underlying infrastructure provides some "load balancer as as service"
    * (e.g. AWS, Azure, GCE, OpenStack...)
* `ExternalName`
  * the DNS entry managed by CoreDNS will just be a `CNAME` to a provided record
  * no port, no IP address, no nothing else is allocated

### Running containers with open ports
* Since `ping` doesn't have anything to connect to, we'll have to run something else
* We could use the `nginx` offical image, but ...
  * ...we wouldn't be able to tell the backends from each other!
* We are going to use `bretfisher/httpenv`, a tiny HTTP server written in Go
* `bretfisher/httpenv` listens on port 8888
* it serves its environment variables in JSON format
* The environment variables will include `HOSTNAME`, which will be the pod name
  * (and therefore, will be different on each backend)


------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------


### Your First Swarm Service

[Docker Swarm Docs](https://docs.docker.com/swarm/)

[Play with Docker](https://labs.play-with-docker.com/)
* Templates
  * 3 Managers and 2 Workers
```sh
docker service create --name hello --replicas 3 --detach=false --publish 8080:80 nginx
```

### Containers Everywhere = New Problems
* How do we automate container lifecycle?
* How can we easily scale out/in/up/down?
* How can we ensure our containers are re-created if they fail?
* How can we replace containers are-created if they fail?
* How can we control/track where containers get started?
* How can we create cross-node virtual networks?
* How can we ensure only trusted servers run our containers?
* How can we store secrets, keys, passwords and get them to the right container(and only that container)?

### Swarm Mode:Built-In Orchestration
* Swarm Mode is a clustering solution built inside Docker
* Not related to Swarm "classic" for pre-1.12 versions
* Added in 1.12(Summer 2016)via SwarmKit toolkit
* Enhanced in 1.13(January 2017) via Stacks and Secrets
* Not enabled by default, new commands once enabled
  * docker swarm
  * docker node
  * docker service
  * docker stack
  * docker secret

### docker swarm init: What Just Happened?
* Lots of PKI and security automation
  * Root Signing Certificate created  for our Swarm
  * Certificate is issued for first Manager node
  * Join tokens are created
* Raft database created to store root CA, configs and secrets
  * Encrypted by default on disk(1.13+)
  * No need for another key/value system to hold orchestration/secrets
  * Replicates logs amongst Managers via mutual TLS in "control plane" 

### Create Your First Service and Scale It Locally

```sh
docker swarm init
docker node ls
# ...MANAGER STATUS
# ...Leader
docker node help
docker swarm help
docker service help

docker service create alpine ping 8.8.8.8
docker service ls
docker service ps <NAME(service)>
docker container ls
docker service update <ID(service)> --replicas 3
docker service ls
docker service ps <NAME(service)>

docker update --help
docker service update --help

docker container ls
docker container rm -f <name>.1.<ID>
docker service ls

docker service ps <NAME(service)>

docker service rm <NAME(service)>
docker service ls
docker container ls
```

### Creating 3-Node Swarm: Host Options
* A.`play-with-docker.com`
  * Only needs a browser, but resets after 4 hours
* B.docker-machine + VirtualBox
  * Free and runs locally,but requires a machine with 8GB memory
* C.Digital Ocean + Docker install
  * Most like a production setup, but cost $5-10/node/month while learning
  * Use my referral code in section resources to get $10 free
* D.Roll your own
  * docker-machine can provision machines for Amazon, Azure, DO, Google, etc.
  * Install docker anywhere with `get.docker.com`

**play-with-docker.com**
```sh
# node1
# create 3 new instances
docker info
ping node2
```

**docker-machine + VirtualBox**
```sh
docker-machine create node1
docker-machine ssh node1
exit
docker-machine env node1
eval $(docker-machine env node1)
docker info # node1

docker-machine env --unset
eval $(docker-machine env --unset)
docker info
```

**DO**

```sh
# curl -fsSL https://get.docker.com -o get-docker.sh
# sh get-docker.sh

# root@node1
docker swarm init
docker swarm init --advertise-addr <IP address>
# docker swarm init --advertise-addr=192.168.99.100

#I'm going to copy the swarm join command and go over to node2 and add it in.
# root@node2
docker swarm join --token SWMTKN-1-1bn2hsyhjwqn4wztjqd7moftumffk4vwd2e88azwj7u7bg0q6m-c91v8sc6vpsyxw4zsqmrmg4ji 192.168.99.100:2377
# This node joined a swarm as a worker.
docker node ls
#Error response from daemon: This node is not a swarm manager. Worker nodes can't be used to view or modify cluster state. Please run this command on a manager node or promote the current node to a manager.

# go back to node1
# docker node ls
docker node update --role manager node2

# for node3, let's add it as a manager by default.
# We need to go back to our original command of docker swarm, and then we need to get the join-token.
# go back to node1
docker swarm join-token manager
# docker swarm join --token SWMTKN-1-1bn2hsyhjwqn4wztjqd7moftumffk4vwd2e88azwj7u7bg0q6m-dzz4pcg9inzkt9wnft4hskaxn 192.168.99.100:2377
# I'm going to copy this, paste it into node3

# node3
docker swarm join --token SWMTKN-1-1bn2hsyhjwqn4wztjqd7moftumffk4vwd2e88azwj7u7bg0q6m-dzz4pcg9inzkt9wnft4hskaxn 192.168.99.100:2377
# This node joined a swarm as a manager.

# Back on node1
docker node ls
docker service create --replicas 3 alpine ping 8.8.8.8
docker node ps
docker service ps <service name>
```

### Overlay Multi-Host Networking
* Just choose `--driver overlay` when creating network
* For container-to-container traffic inside a single Swarm
* Optional IPSec(AES) encryption on network creation
* Each service can be connected to multiple networks
  * (e.g. front-end, back-end)

```sh
# root@node1
docker network create --driver overlay mydrupal
docker network ls

# https://github.com/bitnami/bitnami-docker-postgresql
docker service create --name psql --network mydrupal -e POSTGRESQL_POSTGRES_PASSWORD=mypass -e POSTGRESQL_DATABASE=progres postgres
docker service ls
docker service ps psql
docker logs psql.1.terabjvf7wkt5j769t04tld02

docker service create --name drupal --network mydrupal -p 80:80 drupal
docker service ls
docker service ps drupal #drupal is actrually running on Node2.

docker service inspect drupal #VIP
```

### Routing Mesh

[Use swarm mode routing mesh](https://docs.docker.com/engine/swarm/ingress/)

![service ingress image](https://docs.docker.com/engine/swarm/images/ingress-routing-mesh.png)

![ingress with external load balancer image](https://docs.docker.com/engine/swarm/images/ingress-lb.png)

* Routes ingress(incoming) packets for a Service to proper Task
* Spans All nodes in Swarm
* Uses IPVS from Linux Kernel
* Load balances Swarm Services across their Tasks
* Two ways this works:
* Container-to-container in a Overlay network(uses VIP)
* External traffic incoming to published ports(all nodes listen)

```sh
docker service create --name search --replicas 3 -p 9200:9200 elasticsearch:2
docker service ps search
curl localhost:9200
curl localhost:9200
curl localhost:9200
```

### Routing Mesh Cont.
* This is stateless load balancing
* This LB is at OSI Layer 3(TCP), not Layer 4(DNS)
* Both limitation can be overcome with:
* Niginx or HAProxy LB proxy, or:
* Docker Enterprise Edition, which comes with built-in L4 web proxy

### Stacks: Production Grade Compose
* In 1.13 Docker adds a new layer of abstraction to Swarm called Stacks
* Stacks accept Compose files as their declarative definition for services, networks, and volumes
* We use `docker stack deploy` ranther then docker service create
* Stacks managers all those objects for us, including overlay network per stack. Adds stack name to start of their name
* New `deploy:` key in Compose file. Can't do `build:`
* Compose now ignores `deploy:`, Swarm ignores `build:`
* `docker-compose` cli not needed on Swarm server

```sh
docker stack deploy -c example-voting-app-stack.yml voteapp

docker stack --help

docker stack ls

docker stack services voteapp

docker stack ps voteapp

docker network ls
# overlay

docker stack deploy -c example-voting-app-stack.yml voteapp #update
```

### Secrets Storage
* Easiest "secure" solution for storing secrets in Swarm
* What is a Secret?
  * Usernames and passwords
  * TLS certificates and keys
  * SSH keys
  * Any data you would prefer not be "on front page of news"
* Supports generic strings or binary content up to 500Kb in size
* Doesn't require apps to be rewritten

### Secrets Storage Cont.
* As of Docker 1.13.0 Swarm Raft DB is encrypted on disk
* Only stored on disk on Manager nodes
* Default is Managers and Workers "control plane" is TLS + Mutual Auth
* Secrets are first stored in Swarm, then assigned to a Service(s)
* Only containers in assigned Services(s) can see them
* They look lik files in container but are actually in-memory fs
* `/run/secrets/<secret_name>` or `/run/secrets/<secret_alias>`
* Local docker-compose can use file-based secrets, but not secure

```sh
docker secret create psql_user psql_user.txt
echo "myDBpassWORD" | docker secret create psql_pass -

docker secret ls
docker secret inspect psql_user

docker service create --name psql --secret psql_user --secret psql_pass -e POSTGRES_PASSWORD_FILE=/run/secrets/psql_pass -e POSTGRES_USER_FILE=/run/secrets/psql_user postgres

docker service ps psql
docker exec -it <container name> bash
cat /run/secrets/psql_user
# mysqluser -> it worked

docker service ps psql
docker service update --secret-rm
```

```sh
docker stack deploy -c docker-compose.yml mydb
docker secret ls

docker stack rm mydb
```

### Using Secrets With Local Docker Compose
```sh
ll
#docker-compose.yml
#psql_password.txt
#psql_user.txt
docker node ls
docker-compose up -d
docker-compose exec psql cat /run/secrets/psql_user
#dbuser
```

### Full App Lifecycle With Compose
* Live The Dream！
* Single set of Compose files for:
* Local `docker-compose up` development environment
* Remote `docker-compose up` CI environment
* Remote `docker stack deploy` production environment

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------


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
  * Use wildcard domains like
    `*.vcap.me` or `xip.io`  
  * Use dnsmasq on macOS/Linux
  * Manually edit hosts file

### VS Code, Debugging, and TypeScript
* VS Code and other editors have some Docker and Compose features built-in
* Debugging works when we enable in nodemon and remote via TCP
* TypeScript compile and other pre-processors go in `nodemon.json`
```sh
# typescript
docker-compose run ts npm i
docker-compose up
```

### Build A Sweet Compose File
* `./assignment-sweet-compose`
* Take all the learning from this section and apply it  to a single compose file!
* Uses Docke's example voting app (Dog vs. Cat)
* Step-by-step in `README.md`

### Avoiding devDependencies in Prod
* Multi-stage can solve this
* prod stages: npm i --only=production
* Dev stage: npm i --only=development
* Use `npm ci` to speed up builds
* Ensure `NODE_ENV` is set
* Sample `./multi-stage-deps/`

### Dockerfile Documentation
* Document every line that isn't obvious
* FROM stage, document why it's needed
* COPY = don't document
* RUN = maybe document
* Add LABELS
* RUN npm config list

### Example Dockerfile Labels
* LABEL has OCI standards now
  * `LABEL org.opencontainers.image.<key>`
* Use ARG to add info to labels like build date or git commit
* Docker Hub has built-in envvars for use with ARGs
* Sample `./dockerfile-labels/`

### Compose File Documentation
* YAML (unlike JSON) supports comments!
* Document objects that aren't obvious
  * Why a volume is needed
  * Why custom CMD is needed
* Template blocks at top
* Override objects and files

### Run Tests During Image Build
* `Run npm test` in a specific build-stage
  * Also good for linting commands
* Only run unit tests in build
* Test stage not default
* Locally, run docker-compose, run node npm test
* Sample `./multi-stage-test/`
```sh
docker build -t testnode --target=test .
docker build -t testnode --target=test --no-cache .
```

### Security Scanning and Audit
* Use test stage in multi-stage, or new
* Or run it once image is built with CI
* Only report at first, no failing (most images have at least one CVE vuln)
* Consider `RUN npm audit`
* `./multi-stage-scanning/`
```sh
docker build -t auditnode --target=audit --build-arg MICROSCANNER_TOKEN=$MICROSCANNER_TOKEN .
```

### CI/CD Automated Builds
* Have CI build images on (some) branches
* Push to registry once build/tests pass
* Lint Dockerfile and Compose/Stack files
* Use `docker-compose run` or `--exit-code-from` for proper exit codes
* Docker Hub can do this

### Image Tagging
* <name>:latest is only a convention
* Use latest for local easy access to current release
* Maybe do this per major branch too for convenience
* Don't repeat tags on CI or servers

### Dockerfile Healthchecks
* Always include `HEALTHCHECK`
* Docker run and docker-compose: info noly
* Docker Swarm: Key for uptime and rolling updates
* Kubernetes: Not used, but helps in others making readiness/liveness probes
* Sample `./healthchecks/`

```yml
# option 1
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

# option 2
HEALTHCHECK CMD curl -f http://localhost/healthz || exit 1

# option 3
HEALTHCHECK --interval=30s CMD node hc.js
```

### Ultimate Node.js Dockerfile
* `./ultimate-node-dockerfile/`
* Use an existing Node.js sample app
* Make a production grade Dockerfile
* Development friendly, testing stage, security, non-root user, labels, minimal prod size
* Requirements in `README.md`
```sh
# security
docker build --build-arg=MICROSCANNER_TOKEN=$MICROSCANNER -t ultimatenode:test --target test .
# buildkit
DOCKER_BUILDKIT=1 docker build --build-arg=MICROSCANNER_TOKEN=$MICROSCANNER -t ultimatenode:test --target test .

DOCKER_BUILDKIT=1 docker build --build-arg=MICROSCANNER_TOKEN=$MICROSCANNER -t ultimatenode:prod --target prod .
```

### Multi-Threaded Concerns
* Node is usually single threaded
* Use multiple replicas, not PM2/forever
* Start with 1-2 replicas per CPU
* Unit testing = single replica.
* Integration testing = multiple replicas

### Why Not Compose In Production?
* Only understands a single server (engine)
* Doesn't understand uptime or headlthchecks
* Swarm is easy and solves most use cases
* Single server? Use Swarm
* Kubernetes not ideal for 1-5 servers. Try cloud hosted

### Node.js With Proxies
* Common: many HTTP containers need to listen on 80/443
* Nginx and HAProxy have lots of options
* Traefik is the new kid, full of cool features
* Think early how your Node apps will communicate on a single server or cluster

### Connections During Container Replacement
* Add SIGTERM Code to all Node.js apps
  * `./sample-graceful-shutdown`
* Prevents killing app, but not graceful connection migration
* Check godaddy/terminus for easier hc + shutdown

### Container Replacement Process
* Shutdown wait defaults: Docker/Swarm: 10s, Kubernetes: 30s
* Kubernetes/Swarm use healthchecks differently for ingress LB
* Give shutdown waits longer than HTTP long polling
* HTTP: Use stoppable to track open connections

### Node.js With Orchestration
* Multi-container, single image
* Startup "ready" state: healthchecks
* Multi-container client state sharing(don't use in-memory state)
* Shutdown cleanup: reconnect clients, close DB, fail readiness (K8s)

### Voting App, Cluster-Ready
* `./sample-result-orchestration`
* Kubernetes and Swarm-ready version
* Healthcheck/Readiness wait for DB
* Readiness re-checks DB connection
* `socket.io` uses redis
* Stoppable for cleanup

### Node.js With Docker Swarm
* `./sample-swarm/`
* Example of Node.js app stack
* Has cluster features under "deploy"
* replicas, update_config
* stop_grace_period

### State of ARM + Docker for Node
* ARM processors are used everywhere
* But it's hard to develop on ARM
* April 2019: docker + ARM partnership
* Docker Desktop runs ARM now!
* Node is great on ARM
* Docker is the easiest way to dev for ARM

### Run Node ARM Containers for Dev
* Easy button: Change the `FROM` image to `arm64v8/node:<tag>`
* This forces macOS/Win to run ARM
* Uses QEMU "proc emulator"
* Build/run like normal
* Mix with x86 in compose
```sh
docker image inspect arm64v8/node:10-alpine | grep Arch
# "Architectrue":"arm64",
docker image inspect node:10-alpine | grep Arch
# "Architectrue":"amd64",

docker build -t arm64node .
docker run -p 8080:3000 -d arm64node
docker ps
```

### Run Node ARM Containers for Prod
* AWS A1 Instances (Graviton Processors)
* Test your IOT/Embedded code
* Docker Hub doesn't build arm64 images
* Or does it?(QEMU hack)
* Build your own CI with QEMU
* Swarm just works!

### The Futrue: Making ARM Easier
* ARM + Docker partnership will make this easier
* Build multi-arch in one command
* Store multi-arch images in single repo
* Easier to know which arch you're running locally
