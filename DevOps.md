# DevOps

![DevOps](https://docs.docker.com/get-started/images/laurel-docker-containers.png)

### Docker Engine

![Docker Engine](https://docs.docker.com/engine/images/engine-components-flow.png)

### Docker architecture

![Docker architecture](https://docs.docker.com/engine/images/architecture.svg)

### Docker 能干什么？

* 简化配置
* 代码流水线管理
* 提高开发效率
* 隔离应用
* 整合服务器
* 调试能力
* 多租户
* 快速部署

### 容器时代
* docker & kubernetes(k8s)

### DevOps = 文化 + 过程 + 工具

![devops](./images/devops.png)

### "石器时代"

* 部署非常慢
* 成本非常高
* 资源浪费
* 难于迁移和扩展
* 可能会被限定硬件厂商

### 虚拟化技术出现以后

* 一个物理机可以部署多个app
* 每个app独立运行在一个VM里

### 虚拟化的优点

* 资源池 - 一个物理机的资源分配到不同的虚拟机里面
* 很容易扩展 - 加物理机 Or 加虚拟机
* 很容易云化 - 亚马逊AWS,阿里云 

### 虚拟化的局限性

* 每一个虚拟机都是一个完整的操作系统，要给其分配资源，
当虚拟机资源增多时，操作系统本身消耗的资源势必增多

### 容器解决了什么问题

* 解决了开发与运维之间的矛盾
* 在开发与运维之间搭建了一个桥梁，是实现 devops 的最佳
解决方案

### 什么是容器

* 对软件和其依赖的标准化打包
* 应用之间相互隔离
* 共享同一个OS kernel
* 可以运行在很多主流操作系统之上

### 容器和虚拟机的区别

* 容器是App层面的隔离
* 虚拟化是物理资源层面的隔离

<img alt="Containers" src="https://docs.docker.com/images/Container%402x.png" width="300" height="300">&nbsp;&nbsp;&nbsp;<img alt="virtual machines" src="https://docs.docker.com/images/VM%402x.png" width="300" height="300">

### 虚拟化 + 容器

### Docker 

容器技术的一种实现

### Mac 上 Docker 安装

[Install Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/install/)

**What the install includes: The installation provides Docker Engine, Docker CLI client, Docker Compose, Docker Machine, and Kitematic.**

```sh
docker --version
docker version
```

### Vagrant + VirtualBox搭建实验环境
**Development Environments Made Easy**

先安装 [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

接下看 Vagrant 入门指南->[Getting Started](https://www.vagrantup.com/intro/getting-started/index.html)

[Vagrant Cloud](https://app.vagrantup.com/boxes/search)
* [centos/7 Vagrant box](https://app.vagrantup.com/centos/boxes/7)

```sh
vagrant --help

vagrant init centos/7 # 创建了一个 Vagrantfile

more Vagrantfile # 描述了我们要创建的虚机

vagrant up # 去找 base box(local or cloud)
vagrant ssh # 进入虚机
sudo yum update # 更新虚机
exit # 退出虚机

vagrant status # 查看虚机状态
vagrant halt # 停掉虚机

vagrant status # poweroff

vagrant destroy # 删掉虚机
```

创建一台虚机只需一个 `Vagrantfile` 文件即可

可以 google 搜索 Vagrantfile 如：`Vagrantfile CentOS`

创建一台虚机只需一个 `Vagrantfile` 文件即可

[CentOS 中安装 Docker, 直接看官方文档](https://docs.docker.com/install/linux/docker-ce/centos/) 

```sh
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

sudo yum install -y yum-utils device-mapper-persistent-data lvm2

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce

sudo systemctl start docker

sudo docker version # 查看版本信息

sudo docker run hello-world # 验证一下
```

在 Vagrantfile 中，我们直接可以配置机器启动时自动安装好Docker

```sh
config.vm.provision "shell", inline: <<-SHELL
  sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum install docker-ce
  sudo systemctl start docker
SHELL
```

网络下载太慢，通过 `vagrant up` 我们可以直接拿到 box 的下载地址，然后迅雷下载

离线安装 centos7 box

```sh
cd ~/Vagrant/CentOS7 # 找到一个目录，作为初始化目录
vagrant box add centos/7 ~/Downloads/virtualbox.box # 建议采取离线安装，这样有利于放置虚拟机文件到指定路径
vagrant init centos/7 # 初始化 Vagrantfile
vagrant up #启动
vagrant ssh #进入VM
exit #退出
vagrant status #查看状态
vagrant halt #停掉
vagrant status #查看状态
vagrant destroy #删掉机器
```

查看boxes

```sh
cd ~/.vagrant.d/boxes
```
### Docker Machine

[Docker Machine Overview](https://docs.docker.com/machine/overview/)

mac 默认就已经安装好了

```sh
docker-machine version
```

Docker Machine 能干什么？(如：本地快速在 VirtualBox 环境中创建一台具有 Docker 环境的机器)

```sh
docker-machine --help # 习惯看帮助

docker-machine create demo # 我本地是直接在 VirtualBox 创建一个已经安装好了的虚拟机

docker-machine ls # 看看已经安装好了的机器
docker-machine ssh demo # 进入到机器里面
docker version
exit # 退出

docker-machine help # 查看帮助命令

docker-machine create demo1 # 再创建一台
docker-machine ls # 看一下
docker-machine stop demo1 # 停掉 demo1
docker-machine ls # 再看一下输出
docker-machine stop demo # 停掉 demo
```

### 做个试验，远程管理你的 docker machine

先退出本地 mac 启动 docker server

```sh
docker version #看一下是不是连不上 server
docker-machine start demo #启动下 demo
docker-machine env demo #暴露出环境变量

eval $(docker-machine env demo)
docker version #发现连上了，这种方式可以远程管理 docker machine, 本地只要一个 client 就好了
```

详细文档 [Provision hosts in the cloud](https://docs.docker.com/machine/get-started-cloud/)

### 阿里云上创建一台 Docker Machine

[Drivers for cloud providers](https://docs.docker.com/machine/drivers/)

[3rd-party driver plugins](https://github.com/docker/docker.github.io/blob/master/machine/AVAILABLE_DRIVER_PLUGINS.md)

仓库地址：[Docker Machine Driver of Aliyun ECS](https://github.com/AliyunContainerService/docker-machine-driver-aliyunecs)

`README.md` 有完整使用指南，👇简短说一下：

下载对应的 Driver, Mac OSX 64 bit: [docker-machine-driver-aliyunecs_darwin-amd64](https://docker-machine-aliyunecs-drivers.oss-cn-beijing.aliyuncs.com/docker-machine-driver-aliyunecs_darwin-amd64.tgz)

重命名 binary 档为 `docker-machine-driver-aliyunecs`，然后移动到 `/usr/local/bin`

验证一下，Driver 是否安装成功
```sh
docker-machine create -d aliyunecs --help
```

进入阿里云后台，可以直接进入 `accesskeys` 进行创建用户 AccessKey ID

好的方式还是直接根据提示按照 `使用子用户 AccessKey` 方式创建

![aliyun-access-key](./images/aliyun-accesskey.png)

**注意：要在控制台添加好子账号权限和充值100+**

```sh
docker-machine create -d aliyunecs --aliyunecs-io-optimized=optimized --aliyunecs-access-key-id=<your key> --aliyunecs-access-key-secret=<your secret> --aliyunecs-region=cn-qingdao devops

docker-machine ssh devops # 进入 shell
docker-machine env devops
eval $(docker-machine env devops)
docker version # 看一下有没有连上远端的 server

docker-machine env --help # 查看下帮助
docker-machine env --unset # 去掉刚设的环境变量
eval $(docker-machine env --unset) 

docker version
```

**应用：**，瞬间创 20 台机器去做`啦啦啦😋😝……` ，做完然后销毁🤣

### Online Docker Playground

[Play with Docker](https://labs.play-with-docker.com/)

![Play with Docker](./images/play-with-docker.png)

### Docker 架构和底层技术

Docker Platform

* Docker 提供了一个开发，打包，运行 app 的平台
* 把 app 和底层 infrastructure 隔离开来

Docker Engine

* 后台进程(dockerd)
* REST API Server
* CLI 接口(docker)

```sh
vagrant ssh
sudo docker version
ps -ef | grep docker # 看到有dockerd的进程
```

Docker Architecture

Client
* docker build
* docker pull
* docker run

DOCKER_HOST
* Docker daemon
* Containers
* Images

Registry
* Ubuntu
* Redis
* Niginx
* ...images

底层技术的支持
* Namespaces：做隔离 pid, net, ipc, mnt, uts
* Control groups: 做资源限制
* Union file systems: Container 和 Image 分层

### 什么是 Image

* 文件和 meta data 的集合(root filesystem)
* 分层的，并且每一层都可以添加改变，删除文件，成为一个新的 image
* 不同的 image 可以共享相同的 layer
* Image 本身是 read-only 的

```sh
vagrant ssh
sudo docker image ls #列举出本地有的image
```

Image 的获取

* Build from Dockerfile
* Pull from Registry
  ```sh
  sudo docker image ls
  sudo docker pull ubuntu:14.04
  sudo docker image ls
  ```
### Docker Hub

[Docker Hub Quickstart](https://docs.docker.com/docker-hub/)

[hub.docker.com](https://hub.docker.com/)

### Base Image

在Vagrant中，解决当前用户 `docker` 前要加 `sudo` 的问题

```sh
sudo groupadd docker # 实质上安装好 docker 后，它已经存在了
sudo gpasswd -a vagrant docker # 将当前用户添加这个group里面
sudo service docker restart # 注意之后要重启 docker 进程

exit # 退出,重新登录
vagrant ssh
docker image ls # 现在就不用加 sudo 了
```

首先看一看 `hello-world` 这个 Base Image

```sh
docker pull hello-world #  这也是一个 base image，仅仅包含类似于一个可以执行的文件

docker image ls # 发现这个Image只有1.85kb，非常非常小

docker run hello-world # 这样就相当于创建了一个容器（执行一个Image)
```

### 制作 `Hello-Docker` Base Image

```sh
# vagrant ssh
# 安装一些必要的包
sudo yum install git
sudo yum install vim

mkdir hello-docker
cd hello-docker/
vim hello.c
#   #include<stdio.h>
#   int main()
#   {
#      printf("hello docker\n");
#   }

:wq # 保存退出 Vim 神器

history | grep yum # 看一下安装历史

# 安装编译器和静态版本库
sudo yum install gcc
sudo yum install glibc-static

gcc -static hello.c -o hello # 编译

ls # 发现多了一个可执行文件`hello`
./hello # 执行一次看一下

```

现在，就可以用 Dockerfile 把它弄成一个 Docker Image

```yaml
FROM scratch # 因为是base image,所以这里不能是其它
ADD hello / # 将这个`hello`添加到根目录
CMD ["/hello"] # 执行它
```

```sh
# 构建 然后打 tag，在当前目录下找Dockerfile，因为有三步，所以这个Image有三层
docker build -t kirkwwang/hello-docker .

docker image ls # 看一下,发现这个Image只有857KB

ls -lh # 看一下`hello`这个可执行文件,只有837KB

docker history b3a43698719c # 看一下这个image有几层，发现是两层，因为FROM scratch本身就没有FROM其它Image,可以不算作一层

docker run kirkwwang/hello-docker # 运行看一下，麻雀虽小，五脏俱全
```

### 什么是 Container

* 通过 Image 去创建(copy)
* 在 Image Layer 之上建立一个 container layer(可读写)
* 类比面向对象：类和实例
* Image 负责 app 存储和分发，Container 负责运行 app

```sh
docker container ls # 查看当前正在运行的容器
docker container ls -a # 查看所有的容器（正在运行的以及退出的）

more hello-docker/Dockerfile # 看CMD那一行，当我们 docker run 的时候，默认会去执行 CMD 里面的命令

docker run centos # 默认会用latest版本
docker container ls -a # 它默认执行的是/bin/bash，但也会退出，不是交互式运行，不常驻内存

docker run --help # 注意看帮助 -i，-t

docker run -it centos # 发现我们进入到了容器里面
touch test.txt # 多了一个可读可写的 container layer,我们来创建一个文件
ls
yum install vim # 再执行一条安装命令
```

开个新的terminal

```sh
cd ~/Vagrant/CentOS7
vagrant ssh
docker container ls # 发现有正在运行容器 centos，COMMAND 是 /bin/bash
```

退出容器

```sh
exit # 退出这个容器
docker container ls # 看不到正在运行的容器了
docker container ls -a
```

Docker 的命令分为两大块：Management Commands & Commands

Management Commands ：主要是对Docker里面的具体对象进行管理

```sh
docker image # 看一下image下又有那一些命令
docker image ls
docker container # 看一下container下又有那一些命令
docker container ls -a
docker container rm dfc145ac218f
docker container rm 3e # id 无需写全
```

Commands：提供一些简便方法，不用命令写的太长

```sh
docker ps #  == docker container ls
docker ps -a #  == docker container ls -a
docker rm cf # == docker container rm cf
docker images # == docker image ls
docker rmi fce289e99eb9 # docker image rm fce289e99eb9
```

如何一次性清理掉所有的容器?

```sh
docker run kirkwwang/hello-docker # 先创建5个container
docker run kirkwwang/hello-docker
docker run kirkwwang/hello-docker
docker run kirkwwang/hello-docker
docker run kirkwwang/hello-docker

docker ps -a # 看一下全部

docker container ls -aq # 列举出所有的id
docker container ls -a | awk {'print$1'} # 打印出第一列
docker rm $(docker container ls -aq) # 全部清理 == docker rm $(docker ps -aq)

# 只清理已经退出的
docker run kirkwwang/hello-docker # 先 run 5 个
docker container ls -f "status=exited" # 列出退出的容器
docker container ls -f "status=exited" -q # 列举出所有的id
docker rm $(docker container ls -f "status=exited" -q) # 只清理已经退出的
docker rm $(docker ps -f "status=exited" -q) # 同样的效果
```

### 基于一个 Container 构建 Image

基于某个 Image 创建一个 Container, 然后在这个 Container 里面做一些变化，如：安装了某个软件

把这个已经改变了的 Container， Commit 成一个新的 Image

```sh
# vagrant ssh
docker image ls
docker run -it centos
yum install -y vim
vim # 瞄一眼
exit # 退出
docker container ls -a # 看到一个退出状态的 centos

docker commit # 看一眼这个命令接收哪些参数
docker commit elastic_dewdney kirkwwang/centos-vim # elastic_dewdney 用的NAMES，kirkwwang/centos-vim 这个用的tag默认是latest

docker image ls # 看一眼images

# 比较一下 centos 与 kirkwwang/centos-vim 的分层
docker history centos
docker history kirkwwang/centos-vim # OK, 发现有vim的多了一层，其它的都是共享原来的
```

**不提倡这种方式创建 Image。发布出去，其实并不知道这个 Image 是如何产生的（鬼知道你里面安装啥软件[病毒]），不安全**

### 通过 Dockerfile 去构建一个 Image

```sh
docker image ls
docker image rm kirkwwang/centos-vim # 删掉刚创建的image

mkdir docker-centos-vim
cd docker-centos-vim
vim Dockerfile
```

`Dockerfile` 文件内容

```yml
FROM centos
RUN yum install -y vim
# 会创建一个临时的 Container 运行命令，然后去 Commit 成一个新的 Image
# 最后删掉那个临时的 Container
```

```sh
docker build -t kirkwwang/centos-vim-new . # -t 打 tag, `.`基本于当前目录的Dockerfile构建

docker image ls # 看一眼新生成的 image
```

### Dockerfile 最佳实践

[Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

FROM

```yml
FROM scratch # 制作 Base Image
FROM centos # 使用 Base Image
FROM ubuntu:14.04
```

**为了安全，尽量使用官方的 Image 作为 Base Image！**
