# DevOps = 文化 + 过程 + 工具

### CentOS 7测试环境准备
1. 安装VirtualBox
2. 安装Vagrant
3. 重要的 Vagrantfile (centos, ubuntu etc.)
[官方 centos/7 box 描述](https://app.vagrantup.com/centos/boxes/7)

```sh
vagrant --help
mkdir centos7
vagrant init centos/7 // 初始化Vagrantfile
more Vagrantfile // more Vagrantfile
vagrant up // 去找image(local or network) 
```

Vagrantfile, 可以配置机器启动时自动安装好docker

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
cd ~/Vagrant/CentOS7 // 找到一个目录，作为初始化目录
vagrant box add centos/7 ~/Downloads/virtualbox.box // 建议采取离线安装，这样有利于放置虚拟机文件到指定路径
vagrant init centos/7 // 初始化 Vagrantfile
vagrant up // 启动
vagrant ssh // 进入VM
exit // 退出
vagrant status //查看状态
vagrant halt // 停掉
vagrant status //查看状态
vagrant destroy //删掉机器
```

查看boxes

```sh
cd ~/.vagrant.d/boxes
```

[CentOS 中安装 Docker, 直接看官方文档](https://docs.docker.com/install/linux/docker-ce/centos/)

[Docker Machine Overview](https://docs.docker.com/machine/overview/)

mac 默认就已经安装好了

```sh
docker-machine  version
```

Docker Machine 能干什么？(本地还是用 Vagrant+VirtualBox 快速搭建，原因是因为系统功能不是精简过的)

```sh
vagrant halt // 停掉
vagrant destroy // 删掉机器
docker-machine --help // 习惯看帮助
docker-machine create demo // 我本地是直接在 VirtualBox 创建一个已经安装好了的虚拟机
/*
* Creating CA: /Users/zoot/.docker/machine/certs/ca.pem
* Creating client certificate: /Users/zoot/.docker/machine/certs/cert.pem
* Running pre-create checks...
* (demo) Image cache directory does not exist, creating it at /Users/zoot/.docker/machine/cache...
* (demo) No default Boot2Docker ISO found locally, downloading the latest release...
* (demo) Latest release for github.com/boot2docker/boot2docker is v18.09.1
* (demo) Downloading /Users/zoot/.docker/machine/cache/boot2docker.iso from https://github.com/boot2docker/boot2docker/releases/download/v18.09.1/boot2docker.iso...
*/
docker-machine ls // 看看已经安装好了的机器
docker-machine ssh demo // 进入到机器里面
docker-machine create demo1 // 再创建一台
docker-machine ls
docker-machine stop demo1 // 停掉
docker-machine ls // 再看一下输出
docker-machine stop demo // 停掉
```

### 做个试验，远程的管理 docker machine

先退出本地 mac 启动 docker server

```
docker version // 看一下是不是连不上 server
docker-machine start demo // 启动下 demo
docker-machine env demo // 暴露出环境变量
eval $(docker-machine env demo) // 输出到本地
docker version // 发现连上了，这种方式可以远程管理 docker machine, 本地只要一个 client 就好了
```

详细文档 [Provision hosts in the cloud](https://docs.docker.com/machine/get-started-cloud/)

### 阿里云上创建 Docker Machine

[Drivers for cloud providers](https://docs.docker.com/machine/drivers/)

[3rd-party driver plugins](https://github.com/docker/docker.github.io/blob/master/machine/AVAILABLE_DRIVER_PLUGINS.md)

[Docker Machine Driver of Aliyun ECS](https://github.com/AliyunContainerService/docker-machine-driver-aliyunecs)

下载对应的 Driver, Mac OSX 64 bit: [docker-machine-driver-aliyunecs_darwin-amd64](Mac OSX 64 bit: docker-machine-driver-aliyunecs_darwin-amd64)

重命名 binary 档为 `docker-machine-driver-aliyunecs`，然后移动到 `/usr/local/bin`

验证一下，Driver 是否安装成功

```sh
docker-machine create -d aliyunecs --help

// 注意：要在控制台添加账号权限 和 充值100+
docker-machine create -d aliyunecs --aliyunecs-io-optimized=optimized --aliyunecs-access-key-id=<your key> --aliyunecs-access-key-secret=<your secret> --aliyunecs-region=cn-qingdao devops

docker-machine ssh devops // 进入 shell
docker-machine env devops
eval $(docker-machine env devops)
docker version // 看一下有没有连上远端的 server
docker-machine env --help // 查看下帮助
docker-machine env --unset // 去掉刚设的环境变量
eval $(docker-machine env --unset) 
docker version
```

### Docker 架构和底层技术简介

```sh
vagrant ssh
sudo docker version
ps -ef | grep docker // 看到有dockerd的进程

sudo docker image ls // 列举出本地有的image
```

### DIY 个Base Image

首先解决这个问题，避免每次加 sudo：

[vagrant@bogon ~]$ docker image ls
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.39/images/json: dial unix /var/run/docker.sock: connect: permission denied

```sh
sudo groupadd docker // 实质上安装好 docker 后，它已经存在了
sudo gpasswd -a vagrant docker // 将当前用户添加这个group里面
sudo service docker restart // 注意之后要重启 docker 进程
exit // 退出,重新登录
vagrant ssh
docker image ls // 现在就不用加 sudo 了

docker pull hello-world // 这也是一个 base image，仅仅包含类似于一个可以执行的文件
docker image ls // 发现这个Image只有1.85kb，非常非常小
docker run hello-world // 这样就相当于创建了一个容器（执行一个Image)
```

开始制作 base image

安装一些必要的包:
```
sudo yum install git
sudo yum install vim
```

```
mkdir hello-world
cd hello-world/
vi hello.c
/*
#include<stdio.h>
int main()
{
    printf("hello docker\n");
}
*/

history | grep yum // 看一下安装历史

sudo yum install gcc // 要编译 C 文件
sudo yum install glibc // 可以先不装
sudo yum install locate // 可以先不装
sudo yum install glibc-static 

gcc -static hello.c -o hello
ls // 发现多了一个可执行文件`hello`
./hello //执行一次看一下
```

现在，就可以用 Dockerfile 把它弄成一个 Docker Image

```sh
vim Dockerfile
/*
FROM scratch //因为是base image,所以这里不能是其它
ADD hello / // 将这个`hello`添加到根目录
CMD ["/hello"] // 执行它
*/
docker build -t kirkwwang/hello-world . //构建 然后打 tag，在当前目录下找Dockerfile，因为有三步，所以这个Image有三层

docker image ls // 看一下,发现这个Image只有857KB
ls -lh // 看一下`hello`,只有837KB

docker history b3a43698719c // 看一下这个image有几层，发现是两层，因为FROM scratch本身就没有FROM其它Image,可以不算作一层

docker run kirkwwang/hello-world // 运行看一下，麻雀虽小，五脏俱全

```


### 什么是Container

```sh
docker container ls // 查看当前正在运行的容器

docker container ls -a // 查看所有的容器（正在运行的以及退出的）

more hello-world/Dockerfile // 看CMD那一行，当我们 docker run 的时候，默认会去执行 CMD 里面的命令

docker run centos // 默认会用latest版本

docker container ls -a // 它默认执行的是/bin/bash，但也会退出，不是交互式运行，不常驻内存
```

交互式运行

```sh
docker run --help //注意看帮助 -i，-t

docker run -it centos // 发现我们进入到了容器里面
touch test.txt // 多了一个可读可写的 container layer,我们来创建一个文件
ls
yum install vim // 再执行一条安装命令

```

开个新的terminal

```sh
cd ~/Vagrant/CentOS7
vagrant ssh
docker container ls // 发现有正在运行容器 centos，COMMAND 是 /bin/bash
```

退出容器

```sh
exit // 退出这个容器
docker container ls // 看不到正在运行的容器了
docker container ls -a
```

Docker 的命令分为两大块：Management Commands & Commands

Management Commands ：主要是对Docker里面的具体对象进行管理

```sh
docker image // 看一下image下又有那一些命令
docker image ls
docker container // 看一下container下又有那一些命令
docker container ls -a
docker container rm dfc145ac218f
docker container rm 3e // id 无需写全
```

Commands：提供一些简便方法，不用命令写的太长

```sh
docker ps //  == docker container ls
docker ps -a //  == docker container ls -a
docker rm cf // == docker container rm cf
docker images // == docker image ls
docker rmi fce289e99eb9 // docker image rm fce289e99eb9
```

如何一次性清理掉所有的容器?

```sh
docker run kirkwwang/hello-world // 先创建5个container
docker run kirkwwang/hello-world
docker run kirkwwang/hello-world
docker run kirkwwang/hello-world
docker run kirkwwang/hello-world

docker ps -a // 看一下全部

docker container ls -aq // 列举出所有的id
docker container ls -a | awk {'print$1'} // 打印出第一列
docker rm $(docker container ls -aq) // 全部清理 == docker rm $(docker ps -aq)

// 只清理已经退出的
docker run kirkwwang/hello-world //先 run 5 个
docker container ls -f "status=exited" // 列出退出的容器
docker container ls -f "status=exited" -q // 列举出所有的id
docker rm $(docker container ls -f "status=exited" -q) // 只清理已经退出的
docker rm $(docker ps -f "status=exited" -q) // 同样的效果
```


### 构建自己的Docker镜像

两个命令：

#### docker container commit // 可以简写成 docker commit

Create a new image from a container's changes

基于某个image创建一个container, 然后在这个container里面做一些变化， 如：安装了某个软件

把这个已经改变了的 container commit成一个新的image

#### docker image build // 可以简写成 docker build

Build an image from a Dockerfile

-----

#### 实验

```sh
docker run -it centos // 进入到容器，做一些变化
yum install -y vim // 安装一个vim
vim // 瞄一眼
exit // 退出
docker container ls -a // 看到一个退出状态的 centos
/*
Usage:  docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]
*/
docker commit // 看一眼这个命令接收哪些参数
docker commit nostalgic_wiles kirkwwang/centos-vim // nostalgic_wiles 用的NAMES，kirkwwang/centos-vim 这个用的tag默认是latest
// OK,我们弄了一个新的Image
docker image ls // 看一眼images
/*
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
kirkwwang/centos-vim    latest              5df29f39aeb1        3 minutes ago       328MB
kirkwwang/hello-world   latest              b3a43698719c        9 hours ago         857kB
centos                  latest              1e1148e4cc2c        6 weeks ago         202MB
*/
docker history 1e1148e4cc2c // 看一下他们的分层
docker history 5df29f39aeb1 // OK, 发现有vim的多了一层，其它的都是共享原来的
```

**不提倡这种方式创建Image，发布出去，其实并不知道这个Image是如何产生的（鬼知道你里面安装啥软件），不安全**

#### 通过Dockerfile去构建一个Image

```sh
docker image ls
docker image rm 5df29f39aeb1 // 删掉刚创建的image
mkdir docker-centos-vim
cd docker-centos-vim
vim Dockerfile
/*
FROM centos
RUN yum install -y vim
*/
docker build -t kirkwwang/centos-vim-new . // -t 打 tag, `.`基本于当前目录的Dockerfile构建
/*
Step 1/2 : FROM centos
 ---> 1e1148e4cc2c // 直接引用 centos 这一层
Step 2/2 : RUN yum install -y vim
 ---> Running in 080a3634317e // 在build的过程中，生成了一个新的，临时的 container layer(可读写)，然后在这里安装
 ....
 ....
 Complete!
Removing intermediate container 080a3634317e // 删掉那个临时的
 ---> 11f4cb05df0f // 基于那个临时的container 去 commit 成一个新的Image
Successfully built 11f4cb05df0f
Successfully tagged kirkwwang/centos-vim-new:latest
*/

docker image ls // 看一眼新生成的 image
```

### Dockerfile语法梳理及最佳实践

#### FROM

```sh
FROM scratch # 制作 base image
FROM centos # 使用base image
FROM ubuntu:14.04
```






