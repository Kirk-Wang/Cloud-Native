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
docker image ls # 看一眼images
/*
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
kirkwwang/centos-vim    latest              5df29f39aeb1        3 minutes ago       328MB
kirkwwang/hello-world   latest              b3a43698719c        9 hours ago         857kB
centos                  latest              1e1148e4cc2c        6 weeks ago         202MB
*/
docker history 1e1148e4cc2c # 看一下他们的分层
docker history 5df29f39aeb1 # OK, 发现有vim的多了一层，其它的都是共享原来的
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

FROM

**为了安全，尽量使用官方的image作为base image！**

#### LABEL

```sh
LABEL maintainer="kirk.w.wang@gmail.com"
LABEL version="1.0"
LABEL description="This is description"
```

LABEL //类似于注释

**Metadata不可少**

#### RUN

```sh
RUN yum update && yum install -y vim \
    python-dev # 反斜线换行

RUN apt-get update && apt-get install -y perl \
    pwgen --no-install-recommends && rm -rf \
    /var/lib/apt/lists/* # 注意清理cache

RUN /bin/bash -c 'source $HOME/.bashrc;echo 
$HOME'
```

RUN 

**为了美观，复杂的RUN请用反斜线换行！避免无用分层，合并多条命令成一行！**

#### WORKDIR 设定当前工作目录

```sh
WORKDIR /root

WORKDIR /test # 如果没有会自动创建test目录
WORKDIR demo
RUN pwd # 输出结果应该是 /test/demo
```

WORKDIR

**用WORKDIR，不要用 RUN cd！尽量使用绝对目录！**

#### ADD and COPY

```sh
ADD hello /
ADD test.tar.gz / #添加到根目录并解压

WORKDIR /root
ADD hello test/ # /root/test/hello

WORKDIR /root
COPY hello test/
```

ADD or COPY

**大部分情况，COPY 优于 ADD! ADD 除了 COPY 还有额外功能（解压）！添加远程文件/目录请使用curl或者wget!**

#### ENV

ENV MYSQL_VERSION 5.6 # 设置常量
RUN apt-get install -y mysql-server="${MYSQL_VERSION}" \
    && rm -rf /var/lib/apt/lists/* # 引用常量

ENV

**尽量使用ENV增加可维护性**

#### VOLUME and EXPOSE

(存储和网络)后面详细介绍

#### CMD and ENTRYPOINT

后面详细介绍

#### Demo Time & 学习方式

[docker-library](https://github.com/docker-library)

[Dockerfile reference](https://docs.docker.com/engine/reference/builder/)


### RUN vs CMD vs Entrypoint

RUN:执行命令并创建新的Image Layer

CMD:设置容器启动后默认执行的命令和参数

ENTRYPOINT:设置容器启动时运行的命令

#### Shell 和 Exec格式

Shell格式

```sh
RUN apt-get install -y vim
CMD echo "hello docker"
ENTRYPOINT echo "hello docker"
```

Exec格式

```sh
RUN["apt-get", "install", "-y", "vim"]
CMD["/bin/echo", "hello docker"]
ENTRYPOINT["/bin/echo", "hello docker"]
```

Dockerfile1

```sh
FROM centos
ENV name Docker
ENTRYPOINT echo "hello $name"
```

Dockerfile2

```sh
FROM centos
ENV name Docker
ENTRYPOINT ["/bin/echo", "hello $name"]
```

Demo

```sh
mkdir cmd_vs_entrypoint
cd cmd_vs_entrypoint
vim Dockerfile # 放进去Dockerfile1
docker build -t kirkwwang/centos-entrypoint-shell . # shell格式构建
docker image ls
docker run kirkwwang/centos-entrypoint-shell # 运行看一下


vim Dockerfile # 放进去Dockerfile2
docker build -t kirkwwang/centos-entrypoint-exec . # exec格式构建
docker image ls
docker run kirkwwang/centos-entrypoint-exec
# [vagrant@bogon cmd_vs_entrypoint]$ docker run kirkwwang/centos-entrypoint-exec
# hello $name // 发现并没有进行变量替换，因为我们不是在shell里面去执行 echo，只是单纯的执行echo, 怎么改？
# ENTRYPOINT ["/bin/bash","-c","echo","hello $name"] 在 shell 里面执行 echo 命令

vim Dockerfile # 修改一下
docker build -t kirkwwang/centos-entrypoint-exec-new .
docker image ls
docker run kirkwwang/centos-entrypoint-exec-new # 发现打印出来的是空，Why？
# [vagrant@bogon cmd_vs_entrypoint]$ docker run kirkwwang/centos-entrypoint-exec-new
#

vim Dockerfile # 修改一下
# ENTRYPOINT ["/bin/bash","-c", "echo hello $name"] 把后面所有的命令作为一个去执行

docker build -t kirkwwang/centos-entrypoint-exec-new .
docker run kirkwwang/centos-entrypoint-exec-new # 现在就正常了

```

#### CMD

容器启动时默认执行的命令

如果docker run指定了其它命令，CMD命令被忽略

如果定义了多个CMD，只有最后一个会执行

Dockerfile:

```sh
FROM centos
ENV name Docker
CMD echo "hello $name"
```

```sh
docker run [image] #输出?-->hello World
docker run -it [image] /bin/bash # 输出?-->CMD命令被忽略，因为指定了 `/bin/bash`
```

#### ENTRYPOINT

让容器以应用程序或者服务的形式运行

不会被忽略，一定会执行

最佳实践：写一个shell脚本作为entrypoint

```sh
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 27017
CMD ["mongod"]
```

实践(命令改成 shell)

```sh
docker rm $(docker ps -f "status=exited" -q) // 干掉已经退出的容器
docker rmi e2fc56ae6db7 // 删掉那个 none Image

vim Dockerfile # 修改ENTRYPOINT：CMD echo "hello $name"

docker build -t kirkwwang/centos-cmd-shell . # 构建

docker images # 查看一下
#[vagrant@bogon cmd_vs_entrypoint]$ docker run kirkwwang/centos-cmd-shell
#hello Docker

#docker run -it kirkwwang/centos-cmd-shell /bin/bash # 发现直接进入容器里面了

#[vagrant@bogon cmd_vs_entrypoint]$ docker run kirkwwang/centos-entrypoint-shell
#hello Docker

#[vagrant@bogon cmd_vs_entrypoint]$ docker run -it kirkwwang/centos-entrypoint-shell /bin/bash
#hello Docker -->> 还是会运行 ENTRYPOINT
```

### 镜像的发布

[Docker Hub](https://hub.docker.com)

实践

```sh
docker login

docker push kirkwwang/hello-world # kirkwwang 一定是你的 Docker Id

docker rmi kirkwwang/hello-world # 删掉本地的，拉取线上的

docker pull kirkwwang/hello-world
```

这样去发布一个 docker image 是不安全的，因为别人不知道你在系统是不是加了病毒

推荐的方式是关联Github仓库等，里面提供Dockerfile, Docker Hub 自动帮我们根据 Dockerfile 构建

[Create Repository](https://cloud.docker.com/repository/create)

#### 搭建私有的 Registry

[registry](https://hub.docker.com/_/registry)

登录另一台机器：

```sh
docker run -d -p 5000:5000 --restart always --name registry registry:2 # 创建一个容器运行App
```

本地测试一下，是否能连得上我们的伺服器。

```sh
sudo yum install -y telnet
telnet x.x.x.x 5000 # 本地测一下
# Trying xx.xx.xx.xx...
# Connected to xx.x.x.x.
# Escape character is '^]'. 
# 说明连接成功了
```

往私有的服务器去push

```sh
docker rmi kirkwwang/hello-world # 先干掉本地的Image
docker build -t x.x.x.x:5000/hello-world . # x.x.x.x 你自己服务器的ip
docker images
```

配置(因为默认我们的服务器是不可信任的)

```sh
sudo ls /etc/docker/ # 这个目录下，创建一个文件
sudo vim /etc/docker/daemon.json

# [vagrant@bogon hello-world]$ sudo more /etc/docker/daemon.json
# {"insecure-registries":["x.x.x.x:5000"]} 让这个服务器可以信任的

# sudo vim /lib/systemd/system/docker.service 编辑写docker的启动文件，加载刚刚的配置
# EnvironmentFile=-/etc/docker/daemon.json 加这么一行

sudo service docker restart
#[vagrant@bogon hello-world]$ sudo service docker restart
#Redirecting to /bin/systemctl restart docker.service
#Warning: docker.service changed on disk. Run 'systemctl daemon-reload' to reload units.

sudo systemctl daemon-reload

docker push xx.xx.xx.xx:5000/hello-world ## 好，看到成功了
```

如何验证推送成功了呢？

[Docker Registry HTTP API V2](https://docs.docker.com/registry/spec/api/)

[listing-repositories](https://docs.docker.com/registry/spec/api/#listing-repositories)

```sh
[vagrant@bogon hello-world]$ curl x.x.x.x:5000/v2/_catalog
{"repositories":["hello-world"]}
```

另外一种：

```sh
docker rmi x.x.x.x:5000/hello-world # 删掉本地的
docker pull x.x.x.x:5000/hello-world
```

### Dockerfile 实战

```sh
mkdir flask-hello-world
cd flask-hello-world/

vim app.py
# from flask import Flask
# app = Flask(__name__)
# @app.route('/')
# def hello()
#    return "hello docker"
# if __name__== "__main__":
#    app.run()

vim Dockerfile
# FROM python:2.7
# LABEL maintainer="Kirk Wang<kirk.w.wang@gmail.com>"
# RUN pip install flask
# COPY app.py /app
# WORKDIR /app
# EXPOSE 5000
# CMD ["python", "app.py"]

docker build -t kirkwwang/flask-hello-world . # 构建

# ....
# Step 4/7 : COPY app.py /app
# ---> 6e2811783304
# Step 5/7 : WORKDIR /app
# Cannot mkdir: /app is not a directory 尴尬，报错，进去这个中间状态的Image 6e2811783304 去看一眼

docker run -it 6e2811783304 /bin/bash # 发现 app 是个文件

vim Dockerfile # 修改 COPY app.py /app -> COPY app.py /app/

docker build -t kirkwwang/flask-hello-world . # 构建

docker images # 看到了 kirkwwang/flask-hello-world

docker run kirkwwang/flask-hello-world # 创建一个容器，运行我们的 App

docker run -d kirkwwang/flask-hello-world # -d 后台执行

docker ps # 发现正在运行
```

### 容器的操作

对运行中的容器进行操作

```sh
docker ps
docker exec -it fdeee46afa69 /bin/bash # 对正在运行的容器执行/bin/bash，交互式的运行
ps -ef | grep python # 发现有进程在后台运行

exit # 退出
docker exec -it fdeee46afa69 python # 发现我们直接进入到了一个python的shell里面了

docker exec -it fdeee46afa69 ip a # 打印下容器的ip地址

docker stop fdeee46afa69 # ==docker container stop fdeee46afa69 停掉容器

docker rm $(docker ps -aq) # 清理所有的容器
docker rm $(docker ps -f "status=exited" -q) # 清理所有退出的容器

docker run -d --name=demo kirkwwang/flask-hello-world # 重新启动并且加个名字

docker ps # 看到了那个名字，不指定就随机分配一个

docker stop demo # 停掉

docker start demo # 启动

docker inspect demo # 查看下这个容器的详细信息

docker logs demo # 容器运行产生的一些输出
```

### Dockerfile实战(2)

stress 压力测试工具

```sh
mkdir ubuntu-stress
cd ubuntu-stress
docker run -it ubuntu # 运行并进入到容器里面
apt-get update && apt-get install -y stress # 安装 stress

which stress # 在/usr/bin/stress

stress --help

stress --vm 1 --verbose # 分配&释放

stress --vm 1 --vm-bytes 5000000M --verbose # 炸了，超出了 docker host 内存的限制了

top # 看下内存
```

打包 stress 为一个 Image

```sh
vim Dockerfile
/*
FROM ubuntu:16.04
RUN apt-get update && apt-get install -y stress
ENTRYPOINT ["/usr/bin/stress"]
CMD []
*/
docker build -t kirkwwang/ubuntu-stress . # 构建

docker run -it kirkwwang/ubuntu-stress # 发现打印出了帮助信息

docker run -it kirkwwang/ubuntu-stress --vm 1 # stress 接受了vm等于1的参数

docker run -it kirkwwang/ubuntu-stress --vm 1 --verbose # 打印出所有的过程
```

ENTRYPOINT + CMD 比较典型利用 docker 在容器里面运行命令工具的方法

### 容器的资源限制

限制内存

```sh
docker run help ## --memory --memory-swap 不做限制就等于 memory

docker run --memory=200M kirkwwang/ubuntu-stress --vm 1 --verbose 
# 如果停不了，新开一个 vagrant ssh -->docker stop
# --memory=200M，其实有400M,因为 memory-swap 没指定就等于 memory

docker run --memory=200M kirkwwang/ubuntu-stress --vm 1 --verbose --vm-bytes 500M
## 总共才400M，指定了500M，肯定就炸了

```

限制CPU(注意观察)

shell 1

```sh
top
```

shell 2

```sh
docker run --cpu-shares=5 --name=test1 kirkwwang/ubuntu-stress --cpu 1
```

shell 3

```sh
docker run --cpu-shares=10 --name=test2 kirkwwang/ubuntu-stress --cpu 1
```

cpu-shares 去设置相对权重

### Docker Network (环境搭建)

单机：Bridge Network  Host Network  None Network

多机：Overlay Network

**Vagrant was unable to mount VirtualBox shared folders.错误解决方式**

[解决方案](https://github.com/scotch-io/scotch-box/issues/296)

```sh
vagrant plugin install vagrant-winnfsd
vagrant plugin install vagrant-vbguest
Vagrant up
```

实操：

外面是可以ping的通的
```sh
ping 192.168.205.10
pint 192.168.205.11
```

```sh
vagrant status

vagrant ssh docker-node1 # 进入第一台机器

docker version

ip a

# [vagrant@docker-node1 ~]$ ping 192.168.205.11 是通的

```

如果实在装不了可以 docker machine

### 网络基础回顾

*基于数据包的通信方式*

*网络的分层*

*路由的概念*

*IP地址和路由*

*公有IP和私有IP*

```sh
A 10.0.0.0 -> 10.255.255.255 (10.0.0.0/8)
B 172.16.0.0 -> 172.31.255.255 (172.16.0.0/12)
C 192.168.0.0 -> 192.168.255.255 (192.168.0.0/16)
```

*网络地址转换NAT*

*Ping和telnet*

Ping(ICMP)：验证IP的可达性

telnet:验证服务的可用性

Wireshart 工具

### Linux网络命名空间(Docker 底层技术)

busybox 是一个非常小的 Linux Image

```sh
sudo docker run -d --name test1 busybox /bin/sh -c "while true; do sleep 3600; done" # 这个 container 会一直在后台运行
# 创建了一个容器，同时也就创建了一个 Linux Network Namespace, 和宿主机或其它容器是完全隔离的
sudo docker run -d --name test2 busybox /bin/sh -c "while true; do sleep 3600; done"
sudo docker ps

sudo docker exec -it ee54bca437fc /bin/sh # 进入Container

ip a # 显示当前容器有的网络接口(命名空间) lo: 本地回环口, eth0:

exit

docker ps

sudo docker exec ee54bca437fc ip a # 直接在外面看一下test1容器的ip命名空间

sudo docker exec -it 79dcebd2cc69 /bin/sh # 进入test2

ping 172.17.0.2 # ping test1 容器，是能够通的

```


*从底层看看---如何创建和删除Linux network namespace*

[vagrant@docker-node1 ~]

```sh
sudo ip netns list # 本机有的network namespace
sudo ip netns delete test1 # 删掉
sudo ip netns add test1 # 添加
sudo ip netns list
sudo ip netns add test1
sudo ip netns list
```

有两个 network namespace 了

刚才用 docker run 创建了两个容器，每个都有自己独立的 network namespace, 可以通过 docker exec 去查看 network namespace 里面的端口和ip地址

同理，我们如何去查看刚刚 linux 创建的 network namespace 它的 ip 呢 ？
```sh
sudo ip netns exec test1 ip a # 在 test1 这个network namespace里面执行 ip a 命令
#1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
# 看到现在有一个本地的回环口，特点：没有127.0.0.1地址，状态是 DOWN 的，没有运行起来
# 还可以在network namespace里面执行 ip link 命令
ip link # 本机看一下

sudo ip netns exec test1 ip link
#1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
# 只有一条lo(本地回环口)

sudo ip netns exec test1 ip link set dev lo up # 好，现在让 lo 这个端口 up 起来

sudo ip netns exec test1 ip link #看一下
#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
#   link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
# 现在变成 UNKNOWN 了，Why
# 这个端口要UP起来，要满足一个条件，需要两端是连起来的
# 就像 eth0 和mac里面的一个虚拟化的端口连起来，就是说单个端口是没法 up 起来的，必须是一对
```

做实验

本机有两个 network namespace , test1 & test2，它们分别有一个looback本地的回环口

想让 test1 和 test2 连起来，显然，我们需要接口（类似于连两台机器需要网线, 必须插到每个计算机的网口上去)

在 Linux Network Namesapce 技术里面,我们有 Veth, 我们可以创建 Veth pair

有了这一对，然后分别放在 test1 与 test2，这样就连起来了，因为这两个端口分别是在两个network namespace 里面

所以说，如果我们给这两个端口都配一个IP地址的话，那么他们两个就是通的了（就如先前创建busybox container，它们能ping通，原理一样）

[vagrant@docker-node1 ~]
```sh
sudo ip link add veth-test1 type veth peer name veth-test2 # 本机添加一对link

ip link # 看一下
#9: veth-test2@veth-test1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
#    link/ether 32:e1:cb:c9:e7:c1 brd ff:ff:ff:ff:ff:ff
#10: veth-test1@veth-test2: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
#    link/ether ea:7e:66:4b:31:f4 brd ff:ff:ff:ff:ff:ff

sudo ip link set veth-test1 netns test1 # 把 veth-test1 接口添加到 test1 network namespace 里面去

sudo ip netns exec test1 ip link #看一下

#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#10: veth-test1@if9: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
#    link/ether ea:7e:66:4b:31:f4 brd ff:ff:ff:ff:ff:ff link-netnsid 0
# 看一下添加进去了

sudo ip link # 看眼本地，10 不见了

sudo ip link set veth-test2 netns test2 # 同理 ,test2

sudo ip link # 看眼本地，9 也不见了，好，完美

sudo ip netns exec test2 ip link 
#1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#9: veth-test2@if10: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
#    link/ether 32:e1:cb:c9:e7:c1 brd ff:ff:ff:ff:ff:ff link-netnsid 0

sudo ip netns exec test1 ip addr add 192.168.1.1/24 dev veth-test1 # 为 dev veth-test1 分配一个IP地址，掩码是24
sudo ip netns exec test2 ip addr add 192.168.1.2/24 dev veth-test2

sudo ip netns exec test1 ip link set dev veth-test1 up # 把这个veth-test1端口up起来
sudo ip netns exec test2 ip link set dev veth-test2 up # 把这个veth-test2端口up起来

sudo ip netns exec test1 ip link
#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
# 10: veth-test1@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
#    link/ether ea:7e:66:4b:31:f4 brd ff:ff:ff:ff:ff:ff link-netnsid 1
# test1 已经up 了

sudo ip netns exec test1 ip a # 看下test1 ip

sudo ip netns exec test2 ip a # 看下test2 ip

sudo ip netns exec test1 ping 192.168.1.2 # 在 test1 里面去 ping test2
# PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
# 64 bytes from 192.168.1.2: icmp_seq=1 ttl=64 time=0.161 ms
# 完美，通了

sudo ip netns exec test2 ping 192.168.1.1 # 同理
```

*和前面为什么 busybox 会互动的原理是一样的*

### Docker bridge0详解

```sh
sudo docker exec -it test1 /bin/sh # 进入容器

ping www.baidu.com # 是能 ping 通的， Why?
```

实验：

```sh
docker ps
docker stop test2
docker rm test2 # 删掉test2，只保留test1

docker network ls # 列举出来当前机器docker 有哪些网络
# NETWORK ID          NAME                DRIVER              SCOPE
# a5a19bc16353        bridge              bridge              local
# 70660570dd52        host                host                local
# e92557f82b05        none                null                local

docker ps
#CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
#ee54bca437fc        busybox             "/bin/sh -c 'while t…"   4 hours ago         Up 4 hours                              test1
#test1 是连接到 bridge 这个网络上面的

docker network inspect a5a19bc16353 #查看bridge详细信息,发现test1是连接到了bridge这个网路上面的

ip a 
# 看到  docker0 和 vethc44fcf8@if5
# 我们的 test1 container 要连接到 docker0 这个 bridge 上面
# docker0这个network namespace 是本机，busybox 有自己的 network namespace, 这两个要连接在一起，就需要一个 veth 的 pair
# vethc44fcf8@if5 就负责连到 docker0 上面

docker exec test1 ip a # 发现
#...
#5: eth0@if6: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue
#    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
#    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
#       valid_lft forever preferred_lft forever
# 这个 eth0@if6 和外面的 vethc44fcf8@if5 是一对，这样我们busybox就连到了 docker0 上了

# 如何验证是连到了 docker0 上的？

sudo yum install bridge-utils

brctl

brctl show
#bridge name	bridge id		STP enabled	interfaces
#docker0		8000.024271ff8c33	no		vethc44fcf8
#发现我们这台机器上只有一个 Linux Bridge docker0
#它有一个接口 vethc44fcf8 ，正好就对标vethc44fcf8@if5，也就是说这个接口是连上了 linux bridge 上的

#创建 test2 container
sudo docker run -d --name test2 busybox /bin/sh -c "while true; do sleep 3600; done"

docker network inspect bridge # 看到Containers部分多了一个

ip a # 再看，发现多了一个veth，Why?因为我们多了个容器，它又需要一对（一根线）去连这个 docker0
#6: vethc44fcf8@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
#12: veth2b064cc@if11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default

brctl show # 发现 docker0 连了两个接口了
# bridge name	bridge id		STP enabled	interfaces
#docker0		8000.024271ff8c33	no		veth2b064cc
#							                      vethc44fcf8

容器之间互访
Contianer Test1 <-> docker 0 <-> Contianer Test1 

Internet
Contianer Test1 -> docker 0 -> NAT -> eth0 -> Internet
```

### 容器之间的link(docker 之间的关系)

```sh
docker ps
docker stop test2
docker rm test2

docker run -d --name test2 --link test1 busybox /bin/sh -c "while true; do sleep 3600; done" # 加上link参数

docker exec -it test2 /bin/sh #进入容器

ping 172.17.0.2 # 通
ping test1 # 通，相当于本地添加了一条DNS记录，只有 test2 能连 test1
exit
```

恢复
```sh
docker stop test2
docker rm test2
docker run -d --name test2 busybox /bin/sh -c "while true; do sleep 3600; done"
```

在创建容器的时候可以指定network

```sh
docker ps
docker network ls
```

自己创建一个 bridge
```sh
docker network create

docker network create -d bridge my-bridge # -d：指定 driver

docker network ls ## 看到了my-bridge

brctl show # 也能看到

docker run -d --name test3 --network my-bridge busybox /bin/sh -c "while true; do sleep 3600; done" # 连接到 my-bridge

brctl show # 看到my-bridge 有接口了

docker network inspect my-bridge # Containers部分也能看得到
```

对于已经存在的容器，也可以连接到my-bridge
```sh
docker network connect my-bridge test2

docker network inspect my-bridge # 有 test2 容器

docker network inspect bridge # 有 test2 容器

# test2 连到了两个 bridge 上面了

docker exec -it test3 /bin/sh # 进入 test3 容器

ping 172.18.0.3 # test2 能通
ping test2 # 也能通，并没有指定link,原因是因为test2和test3连的是用户自己创建的bridge(它们相互都可以通过名字ping 通)

exit

docker exec -it test2 /bin/sh 
ping test3 # 也能通
ping test1 # 不能通，它没有连接到my-bridge上面
exit

docker network connect my-bridge test1 # 把 test1 加进去
docker exec -it test2 /bin/sh
ping test1 # 通了
```

*这就是自定义bridge与docker0的区别*

### 容器的端口映射(对外提供服务)

```sh
docker run --name web -d -p 80:80 nginx # -p 80:80-->>容器里面的80映射到本地的80

curl 127.0.0.1 # 有数据，绑定成功
```

Mac 打开 http://192.168.205.10/ --> 有数据

*Aliyun 实操一下*

我的本地 Mac 

```sh
docker-machine create -d aliyunecs --aliyunecs-io-optimized=optimized --aliyunecs-access-key-id=<your key> --aliyunecs-access-key-secret=<your secret> --aliyunecs-region=cn-qingdao devops

docker-machine ls
NAME     ACTIVE   DRIVER      STATE     URL                         SWARM   DOCKER     ERRORS
devops   -        aliyunecs   Running   tcp://xx.xx.xx.xx:2376           v18.09.1

docker-machine env devops

eval $(docker-machine env devops)

docker version # 现在连上的是aliyun的主机

#docker login # 注意这里配置一下Aliyun 镜像加速器，不然unauthorized: incorrect username or password.

docker run --name web -d -p 80:80 nginx # 提供一个服务

x.x.x.x # 完美可以访问云

docker-machine stop devops
docker-machine rm devops # 避免扣钱
```

配置 [Aliyun 镜像加速器](https://cr.console.aliyun.com/cn-qingdao/mirrors)

```sh
docker-machine ssh devops
```


### 容器网络之host和none

*none network*

```sh
docker run -d --name test1 --network none busybox /bin/sh -c "while true; do sleep 3600; done"

docker network inspect none # 注意Containers部分
# 发现ip地址，mac地址都没有
docker exec -it test1 /bin/sh # 进去

ip a
#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#    inet 127.0.0.1/8 scope host lo
#       valid_lft forever preferred_lft forever

# 只有本地的一个回环口，它是一个孤立network namespace

exit

docker stop test1
docker rm test1
```

*none network*

```sh
docker run -d --name test1 --network host busybox /bin/sh -c "while true; do sleep 3600; done"

docker network inspect host # 注意Containers部分
# 发现ip地址，mac地址都没有
docker exec -it test1 /bin/sh # 进去

ip a # 发现看到的接口和外面宿主机是共享的，没有自己的network namespace
# 会存在端口冲突的问题
```

### 多容器复杂应用的部署

```sh
# [vagrant@docker-node1 flask-redis]$ pwd
# /home/vagrant/labs/flask-redis
# 实操

docker run -d --name redis redis 
# 部署一个redis容器, 没有加 -p 6379:6379，为了安全
# 它不是给外面人访问的，只是给 app 内部访问来着
# 要解决 redis:6379 可访问

docker ps

docker build -t kirkwwang/flask-redis . # 构建应用 image

docker images # 瞄一眼镜像

docker run -d --link redis --name flask-redis -e REDIS_HOST=redis kirkwwang/flask-redis

docker exec -it flask-redis /bin/sh # 进入容器

env
#看到了 REDIS_HOST=redis

ping redis # 也是没有问题的

curl 127.0.0.1:5000 # 没有问题
curl 127.0.0.1:5000 # 没有问题

exit

# flask-redis 端口没暴露，重新弄一下

docker stop flask-redis
docker rm flask-redis
docker run -d -p 5000:5000 --link redis --name flask-redis -e REDIS_HOST=redis kirkwwang/flask-redis

# [vagrant@docker-node1 flask-redis]$ curl 127.0.0.1:5000
# Hello Container World! I have been seen 3 times and my hostname is b267774005fa.
# [vagrant@docker-node1 flask-redis]$ curl 127.0.0.1:5000
# Hello Container World! I have been seen 4 times and my hostname is b267774005fa.
# 没有问题

# 启动容器时可以设置环境变量 -e 这个参数
# 程序会去对环境变量，传递配置的一种方式

```

### overlay和underlay的通俗解释

多机器通信

[VXLAN](https://www.evoila.de/de/blog/2015/11/06/what-is-vxlan-and-how-it-works/)

192.168.205.10  -> 192.168.205.11   
```sh
vagrant ssh docker-node1
ip a
exit
vagrant ssh docker-node2
ip a

# 两台主机之间是可以通信的(underlay)
```

### Docker Overlay网络和etcd实现多机容器通信

docker-node1

```sh
wget https://github.com/etcd-io/etcd/releases/download/v3.3.11/etcd-v3.3.11-linux-amd64.tar.gz
tar zxvf etcd-v3.3.11-linux-amd64.tar.gz
cd etcd-v3.3.11-linux-amd64

nohup ./etcd --name docker-node1 --initial-advertise-peer-urls http://192.168.205.10:2380 \
--listen-peer-urls http://192.168.205.10:2380 \
--listen-client-urls http://192.168.205.10:2379,http://127.0.0.1:2379 \
--advertise-client-urls http://192.168.205.10:2379 \
--initial-cluster-token etcd-cluster \
--initial-cluster docker-node1=http://192.168.205.10:2380,docker-node2=http://192.168.205.11:2380 \
--initial-cluster-state new&
```

docker-node2

```sh
wget https://github.com/etcd-io/etcd/releases/download/v3.3.11/etcd-v3.3.11-linux-amd64.tar.gz
tar zxvf etcd-v3.3.11-linux-amd64.tar.gz
cd etcd-v3.3.11-linux-amd64

nohup ./etcd --name docker-node2 --initial-advertise-peer-urls http://192.168.205.11:2380 \
--listen-peer-urls http://192.168.205.11:2380 \
--listen-client-urls http://192.168.205.11:2379,http://127.0.0.1:2379 \
--advertise-client-urls http://192.168.205.11:2379 \
--initial-cluster-token etcd-cluster \
--initial-cluster docker-node1=http://192.168.205.10:2380,docker-node2=http://192.168.205.11:2380 \
--initial-cluster-state new&
```

检查cluster状态(etcd)

```sh
[vagrant@docker-node1 etcd-v3.3.11-linux-amd64]$ ./etcdctl cluster-health

[vagrant@docker-node2 etcd-v3.3.11-linux-amd64]$ ./etcdctl cluster-health
```

重启docker服务

在docker-node1上
```sh
sudo service docker stop

sudo /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://192.168.205.10:2379 --cluster-advertise=192.168.205.10:2375&

docker version

exit # 防止有日志产生，退出重进

vagrant ssh docker-node1
```

在docker-node2上

```
sudo service docker stop
sudo /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://192.168.205.11:2379 --cluster-advertise=192.168.205.11:2375&

docker version

exit # 防止有日志产生，退出重进

vagrant ssh docker-node2

```

*创建overlay网络*

在docker-node1上

```sh
sudo docker network ls

sudo docker network create -d overlay demo

sudo docker network ls // 有了 overlay demo
```

在docker-node2上

```sh
sudo docker network ls // 发现也有 overlay demo，说明etcd是正常的
#NETWORK ID          NAME                DRIVER              SCOPE
#8f8fcbe3f24d        bridge              bridge              local
#8884b80afd97        demo                overlay             global
#7c2c351e01fc        host                host                local
#6099ffea8ebd        none                null                local

# 看一下
#[vagrant@docker-node2 etcd-v3.3.11-linux-amd64]$ ./etcdctl ls /docker/nodes
#/docker/nodes/192.168.205.10:2375
#/docker/nodes/192.168.205.11:2375

#[vagrant@docker-node2 etcd-v3.3.11-linux-amd64]$ ./etcdctl ls /docker/network/v1.0/network
#/docker/network/v1.0/network/8884b80afd973e915b2cabc6d633901d819a850944b6607145349584f3e3f8dd #对标8884b80afd97

```

接下来在这个 overlay demo 之上创建 Container

docker-node1
```sh
sudo docker network inspect demo # 看下这个 overlay 网络的基本信息

sudo docker run -d --name test1 --net demo busybox /bin/sh -c "while true; do sleep 3600; done"

sudo docker ps # 正常
```

docker-node2
```sh
sudo docker run -d --name test1 --net demo busybox /bin/sh -c "while true; do sleep 3600; done"

#[vagrant@docker-node2 etcd-v3.3.11-linux-amd64]$ sudo docker run -d --name test1 --net demo busybox /bin/sh -c "while true; do sleep 3600; done"
#docker: Error response from daemon: Conflict. The container name "/test1" is already in use by container #"11d477dc33ca572c8e97a475c8e9e656c686b0fcceb404e116d34fac98613586". You have to remove (or rename) that container to be able to reuse that name.
# 正常，因为 node1 创建 test1 已经存在 etcd 的 cluster 里面了

sudo docker run -d --name test2 --net demo busybox /bin/sh -c "while true; do sleep 3600; done" # 这样就没问题了

sudo docker ps

sudo docker exec test2 ip a # 看下它的ip 10.0.0.3
```

docker-node1

```sh
sudo docker exec test1 ip a # 看下它的ip 10.0.0.2

sudo docker network inspect demo
#"Containers": {
#    "ae1d753219ae27f1e9a2b249a0d0a7478f23cc7a760bac97a48342b77c65c738": {
#        "Name": "test1",
#        "EndpointID": "f489e1e5499d690a64cd786d125a01d5ca76e13828d5f68d2fa1882393f9d2a4",
#        "MacAddress": "02:42:0a:00:00:02",
#        "IPv4Address": "10.0.0.2/24",
#        "IPv6Address": ""
#    },
#    "ep-35b7ca2ad98a6f9ae88fd66ac8b28dfb9949eb1f0f6436da46af11b88369482a": {
#        "Name": "test2",
#        "EndpointID": "35b7ca2ad98a6f9ae88fd66ac8b28dfb9949eb1f0f6436da46af11b88369482a",
#        "MacAddress": "02:42:0a:00:00:03",
#        "IPv4Address": "10.0.0.3/24",
#        "IPv6Address": ""
#    }
#}, 完美

sudo docker exec test1 ping 10.0.0.3 # 能通，成功

sudo docker exec test1 ping test2 # 能通，成功
```

可以做多机基于 overlay 网络，部署flask-redis

深入了解，[Overlay Driver Network Architecture](https://github.com/docker/labs/blob/master/networking/concepts/06-overlay-networks.md)