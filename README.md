# DevOps = 文化 + 过程 + 工具

### 配置加速器！配置加速器！配置加速器！🤦‍♀️

[一行命令，镜像万千](https://www.daocloud.io/mirror)

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

### Docker的持久化存储和数据共享

Thin R/W layer ----> Container Layer

Data Volume

*Docker持久化数据的方案*

*基于本地文件系统的Volume。可以在执行Docker create或Docker run 时, 通过-v参数将主机的目录作为容器的数据卷。这部分功能便是基于本地文件系统的volume管理。

*基于plugin的Volume,支持第三方的存储方案，比如NAS,aws

*Volume的类型*

受管理的 data Volume，由docker后台自动创建

绑定挂载的Volume,具体挂载位置可以由用户指定

*vagrant scp* 拷贝本地文件到虚拟主机

```sh
vagrant plugin list

vagrant plugin install vagrant-scp

vagrant scp ./projects docker-node1:/home/vagrant/labs
```

文件拷贝到了 /home/vagrant/c5/labs

### 数据持久化：Data Volume

```sh
sudo docker run -d --name mysql1 -e MYSQL_ALLOW_EMPTY_PASSWORD mysql # 创建一个container

sudo docker ps # 没有，不正常

sudo docker logs mysql1 # 排错，看日志
# error: database is uninitialized and password option is not specified
#  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD

sudo docker rm mysql1 # 干掉容器

sudo docker volume ls # 没事，我们先看一下volume

sudo docker volume rm xx # 删掉

sudo docker run -d --name mysql1 -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql # 重新创建

sudo docker ps # 有了

sudo docker volume ls
# DRIVER              VOLUME NAME
# local               63c5ba3cbdf42473487f687b7da9ad70f0d7248d61026d4118c961a450019415
# 也多了个 volume

sudo docker volume inspect 63c5ba3cbdf42473487f687b7da9ad70f0d7248d61026d4118c961a450019415 # 看详细

sudo docker run -d --name mysql2 -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql # 加一个

sudo docker volume ls
#DRIVER              VOLUME NAME
#local               63c5ba3cbdf42473487f687b7da9ad70f0d7248d61026d4118c961a450019415
#local               c993a819fc22665408568951a2894f80bfad2c1f92fc443fd0a97c5ab1b50e18

sudo docker volume inspect c993a819fc22665408568951a2894f80bfad2c1f92fc443fd0a97c5ab1b50e18

sudo docker stop mysql1 mysql2

sudo docker rm mysql1 mysql2 # 删掉

sudo docker volume ls # volume还在，数据不会丢，但 data volume 名字不友好

sudo docker volume rm xx # 删掉

sudo docker run -d -v mysql:/var/lib/mysql --name mysql1 -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql # 重新创建

sudo docker volume ls
# DRIVER              VOLUME NAME
# local               mysql

```

验证是否生效

```sh
sudo docker exec -it mysql1 /bin/bash

mysql -u root
show databases;
create database docker;

exit
exit

sudo docker ps

sudo docker rm -f mysql1 # 强删

docker ps -a
sudo docker volume ls # volume 还在

sudo docker run -d -v mysql:/var/lib/mysql --name mysql2 -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql # 重新创建

sudo docker exec -it mysql2 /bin/bash

mysql -u root
# mysql> show databases;
# +--------------------+
# | Database           |
# +--------------------+
# | docker             |
# | information_schema |
# | mysql              |
# | performance_schema |
# | sys                |
# +--------------------+
# docker database 存在

```

### 数据持久化：Bind Mounting

```sh
#[vagrant@docker-node1 docker-nginx]$ pwd
#/home/vagrant/c5/labs/docker-nginx

more Dockerfile

docker build -t kirkwwang/my-nginx . # 构建

docker images

docker run -d -p 80:80 --name web kirkwwang/my-nginx

dokcer ps

curl 127.0.0.1

docker rm -f web

docker run -d -v $(pwd):/usr/share/nginx/html -p 80:80 --name web kirkwwang/my-nginx #创建一个新的容器

docker exec -it web /bin/bash

ls #有映射目录里面的文件

touch test.txt

exit

#[vagrant@docker-node1 docker-nginx]$ ls
#Dockerfile  index.html  test.txt
#正常，是同步的

vim test.txt

#[vagrant@docker-node1 docker-nginx]$ docker exec -it web /bin/bash
#root@350a4d996767:/usr/share/nginx/html# more test.txt
#iiiii
#进去了，发现是同步的

```

### 开发者利器-Docker+Bind Mount

```sh
# /home/vagrant/c5/labs/flask-skeleton
# [vagrant@docker-node1 flask-skeleton]$

docker build -t kirkwwang/flask-skeleton . #构建

docker images

docker run -d -p 80:5000 --name flask kirkwwang/flask-skeleton # 映射目录

docker rm -f flask

docker run -d -p 80:5000 -v $(pwd):/skeleton --name flask kirkwwang/flask-skeleton # 创建容器

docker ps

vim skeleton/client/templates/main/home.html

# 刷新页面，更新了

```

*使用 Docker 作为本地开发环境，是 DevOps 的第一步。*

### Docker Compose多容器部署

利用先前的知识部署WordPress

[The server requested authentication method unknown to the client](https://github.com/laradock/laradock/issues/1392)

```sh
docker run -d --name mysql -v mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress mysql
# 创建 mysql 容器并且持久化
# 这里需要配置

docker exec -it mysql /bin/bash

mysql -u root -p
root # login
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
exit

docker ps # mysql container 已经运行了

docker run --name wordpress --link mysql -p 80:80 -d  wordpress # 构建容器，环境变量用默认值
```

直接就可以访问我本地的 vagrant 虚拟机 [192.168.205.10](http://192.168.205.10) 进行安装，如此方便。


### Docker Compose到底是什么

*多容器的 App 太恶心*

要从Dockerfile build image 或者 Dockerhub 拉取 image

要创建多个 container

要管理这些 container(启动停止删除)

*Docker Compose "批处理"*

Docker Compose 是一个工具

这个工具可以通过一个yml文件定义多容器的docker应用

通过一条命令就可以根据yml文件的定义去创建或者管理多个容器

*docker-compose.yml*

三大概念：Services Networks Volumes

[Compose file versions and upgrading](https://docs.docker.com/compose/compose-file/compose-versioning/)

version 2：单机

version 3: 多机

*Services*

一个 service 代表一个 container，这个 container 可以从 dockerhub 的 image 来创建，或者从本地的Dockerfile build出来的image来创建

Service 的启动类似于 docker run，我们可以给其指定 network 和 volume，所以可以给 service 指定 network 和 Volume 的引用

实操 & 拷贝文件

```sh
vagrant scp ./projects docker-node1:/home/vagrant/labs
```

*Docker Compose的安装和基本使用*

[Install Docker Compose](https://docs.docker.com/compose/install/)

```sh
docker rm $(docker ps -aq) # 清理掉所有容器
docker volume ls -qf dangling=true
docker volume rm $(docker volume ls -qf dangling=true) # 干掉所有volume

docker-compose

docker-compose --version

#[vagrant@docker-node1 wordpress]$ ls
#docker-compose.yml

docker-compose up # dokcer-compose -f docker-compose.yml up 本地 debug

docker-compose up -d # 后台运行

docker-compose ps

docker-comopse stop

docker-comopse start

docker-compose ps

docker-compose down

docker-compose images
```

[Quickstart: Compose and WordPress](https://docs.docker.com/compose/wordpress/), 工具一直在迭代，主意看官方文档

docker-compose 会给我们加前缀

```sh
docker-compose up -d

docker-compose exec db bash # 进入 mysql 容器里面去

exit

docker-compose exec wordpress bash

exit 

docker-compose down
```

实验2 

[vagrant@docker-node1 flask-redis]

```sh
docker-compose up

docker-compose down
```

### 水平扩展和负载均衡 

[vagrant@docker-node1 flask-redis]

```sh
docker-compose up -d

docker-compose ps

docker-compose
# scale              Set number of containers for a service

docker-compose up --help
# --scale SERVICE=NUM        Scale SERVICE to NUM instances. Overrides the
#                               `scale` setting in the Compose file if present.

# [vagrant@docker-node1 flask-redis]$ docker-compose up --scale web=3 -d
# Creating network "flask-redis_default" with the default driver
# WARNING: The "web" service specifies a port on the host. If multiple containers for this service are created on a single host, the # # port will clash.
# Creating flask-redis_web_1   ... error
# Creating flask-redis_web_2   ... done
# Creating flask-redis_web_3   ... error
# Creating flask-redis_redis_1 ...

# 我们删掉一行配置
# ports:
#      - 8080:5000

docker-compose down

docker-compose up --scale web=3 -d

#[vagrant@docker-node1 flask-redis]$ docker-compose ps
#       Name                      Command               State    Ports
#-----------------------------------------------------------------------
#flask-redis_redis_1   docker-entrypoint.sh redis ...   Up      6379/tcp
#flask-redis_web_1     python app.py                    Up      5000/tcp
#flask-redis_web_2     python app.py                    Up      5000/tcp
#flask-redis_web_3     python app.py                    Up      5000/tcp

docker-compose up --scale web=10 -d # 瞬间弄10台

docker-compose down

```

HAPROXY

```sh
[vagrant@docker-node1 lb-scale]$
docker-compose up -d
```

我的 Mac 机

```sh
curl 192.168.205.10:8080
# Hello Container World! I have been seen 1 times and my hostname is 714b7f810b58.
curl 192.168.205.10:8080
# Hello Container World! I have been seen 2 times and my hostname is 714b7f810b58. 
# 没负载，相同的容器
```

[vagrant@docker-node1 lb-scale]$

```sh
docker-compose up --scale web=3 -d # scale 到三台
```

我的 Mac 机
```sh
curl 192.168.205.10:8080
# Hello Container World! I have been seen 4 times and my hostname is 714b7f810b58.

curl 192.168.205.10:8080
# Hello Container World! I have been seen 5 times and my hostname is 5bc0cc1bca02.

curl 192.168.205.10:8080
# Hello Container World! I have been seen 6 times and my hostname is e212f997c701.

curl 192.168.205.10:8080
# Hello Container World! I have been seen 7 times and my hostname is 714b7f810b58.

# 一直轮询，cool
```

[vagrant@docker-node1 lb-scale]$

```sh
docker-compose up --scale web=5 -d # scale 到5台
```

MAC

```sh
for i in `seq 10`; do curl 192.168.205.10:8080; done
#Hello Container World! I have been seen 18 times and my hostname is 714b7f810b58.
#Hello Container World! I have been seen 19 times and my hostname is 5bc0cc1bca02.
#Hello Container World! I have been seen 20 times and my hostname is e212f997c701.
#Hello Container World! I have been seen 21 times and my hostname is 68345533f0f2.
#Hello Container World! I have been seen 22 times and my hostname is 210a67502b17.
#Hello Container World! I have been seen 23 times and my hostname is 714b7f810b58. ##
#Hello Container World! I have been seen 24 times and my hostname is 5bc0cc1bca02.
#Hello Container World! I have been seen 25 times and my hostname is e212f997c701.
#Hello Container World! I have been seen 26 times and my hostname is 68345533f0f2.
#Hello Container World! I have been seen 27 times and my hostname is 210a67502b17.
```

过了高峰期，缩小：

```sh
docker-compose up --scale web=3 -d # 回到三台
#lb-scale_redis_1 is up-to-date
#Stopping and removing lb-scale_web_4 ... done
#Stopping and removing lb-scale_web_5 ... done
#Starting lb-scale_web_1              ... done
#Starting lb-scale_web_2              ... done
#Starting lb-scale_web_3              ... done
```

*但是，这只是单机，一台机器的资源始终是有限的*

### 部署一个复杂的投票应用

[vagrant@docker-node1 example-voting-app]$

```sh
docker-compose up
```

*docker-compose build*，当我们 app 的 Dockerfile 发生了变化，它只是本地开发用的一个工具，不是部署生产的工具

### 开发环境和生产环境完全是两个不同的概念

### 容器编排：Swarm mode

到处都使用容器=麻烦来了

* 怎么去管理这么多容器？
* 怎么能方便的横向扩展？
* 如果容器down了，怎么能自动恢复？
* 如何去更新容器而不影响业务？
* 如何去监控追踪这些容器？
* 怎么去调度容器的创建？
* 保护隐私数据？

*Swarm 内置于 Docker 的一个工具*

*Docker Swarm Mode Architecture*

Swarm 是一种集群的架构，集群就有节点，节点就有角色

有两种角色：Manager，Worker

Manager： 是整个集群的大脑，为了避免单点故障，至少要有两个，那么就会涉及到状态同步的问题

一个Manager做的事情，如何同步到另外的 Manager 节点上，这里就会用到一个内置的分布式的存储数据库

数据是通过Raft协议做的一个同步，它能确保Manager节点之间的信息是对称的，同步的

Worker：干活的节点，Worker的节点信息同步，会通过 Gossip network 来通信

*Service & Replicas*

### 创建一个三节点的swarm集群

```sh
vagrant status
# Current machine states:
# swarm-manager             running (virtualbox)
# swarm-worker1             running (virtualbox)
# swarm-worker2             running (virtualbox)

vagrant ssh swarm-manager

docker swarm --help # 看下帮助
# init        Initialize a swarm

docker swarm init --help # 看下帮助
# --advertise-addr string                  Advertised address (format: <ip|interface>[:port])
# 要启一个 cluster，首先得宣告一个地址

ip a #看下地址 192.168.205.13

docker swarm init --advertise-addr=192.168.205.13 # 先运行的节点将会成为 master
#Swarm initialized: current node (9wpz0pnb3bwlau9kvgm7vsbfk) is now a manager.
#To add a worker to this swarm, run the following command:
#   docker swarm join --token SWMTKN-1-0mzs1n1oik1aykjq1f3bj06ev6gowls8l4qhy19x4yr15moyot-9ipfy6r48lz8dv7ps0ws689kt 192.168.205.13:2377
#To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

```

[vagrant@swarm-worker1 ~]$

```sh
docker swarm join --token SWMTKN-1-0mzs1n1oik1aykjq1f3bj06ev6gowls8l4qhy19x4yr15moyot-9ipfy6r48lz8dv7ps0ws689kt 192.168.205.13:2377
# This node joined a swarm as a worker.

```

[vagrant@swarm-manager ~]$

```sh
docker node
# ls          List nodes in the swarm

docker node ls
#ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
#9wpz0pnb3bwlau9kvgm7vsbfk *   swarm-manager       Ready               Active              Leader              18.09.1
#j4ufrije1qijn38o7vckisxrt     swarm-worker1       Ready               Active                                  18.09.1
```

[vagrant@swarm-worker2 ~]$

```sh
docker swarm join --token SWMTKN-1-0mzs1n1oik1aykjq1f3bj06ev6gowls8l4qhy19x4yr15moyot-9ipfy6r48lz8dv7ps0ws689kt 192.168.205.13:2377
# This node joined a swarm as a worker.

```

[vagrant@swarm-manager ~]$
```sh
docker node ls
# 9wpz0pnb3bwlau9kvgm7vsbfk *   swarm-manager       Ready               Active              Leader              18.09.1
# j4ufrije1qijn38o7vckisxrt     swarm-worker1       Ready               Active                                  18.09.1
# exhtin48g55q98vzwapw7ebt3     swarm-worker2       Ready               Active                                  18.09.1

# OK，具有三个节点的 swarm cluster 就创建完成了
```

*docker-machine create swarm-manager* 也是一样的

### Service的创建维护和水平扩展

vagrant@swarm-manager
```sh
docker service

docker service create --help
# docker run 是本地开发用的

docker service create --name demo busybox sh -c "while true;do sleep 3600;done" # 创建一个 service 容器

docker service ls

docker service ps demo # 详细信息

docker service ls
#kr1lvphl1un4        demo                replicated          1/1                 busybox:latest
# replicated 1/1 --> 表明可以水平扩展的

docker service scale # 看下帮

docker service scale demo=5

docker service ls
# ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
# kr1lvphl1un4        demo                replicated          5/5                 busybox:latest
# 看到了没 REPLICAS 变成了 5 个 (5[5个都Ready了]/5[总共5个])

docker service ps demo 
# kxke0280pdfb        demo.1              busybox:latest      swarm-manager       Running             Running 12 minutes ago
# wu60mazz91xf        demo.2              busybox:latest      swarm-worker2       Running             Running 3 minutes ago
# jhcv9335qfn3        demo.3              busybox:latest      swarm-worker1       Running             Running 3 minutes ago
# j6if990ns5m4        demo.4              busybox:latest      swarm-manager       Running             Running 3 minutes ago
# 2zr6sh6stb1q        demo.5              busybox:latest      swarm-worker2       Running             Running 3 minutes ago
# 平均分布到各个节点

#[vagrant@swarm-worker1 ~]$ docker ps 
#CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
#7cefefd13862        busybox:latest      "sh -c 'while true;d…"   6 minutes ago       Up 6 minutes       
# worker1 看一下, 1 个，没问题

#[vagrant@swarm-worker2 ~]$ docker ps
#CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
#48485cefc502        busybox:latest      "sh -c 'while true;d…"   8 minutes ago       Up 8 minutes                            #demo.5.2zr6sh6stb1quxihmcqg5q0wx
#9d74f97c7d2b        busybox:latest      "sh -c 'while true;d…"   8 minutes ago       Up 8 minutes                            #demo.2.wu60mazz91xfrw3aksq3u4gis
# worker2 看一下, 2 个，没问题

```

vagrant@swarm-worker2 强删一个
```sh
docker rm -f 9d74f97c7d2b
```

vagrant@swarm-manager 看一下
```sh
docker service ls # 快速看一下 4/5

docker service ls # 5/5 ，又有5个ready 了

```

*这个功能就非常有用了，它能确保我们的节点是有效存在的*

删掉 service

```sh
docker service rm demo # 这个过程会去遍历各台机器，然后删掉各台机器上的 service, 过程会比较慢

docker service ps demo
# no such service: demo

```

### 在swarm集群里通过serivce部署wordpress

swarm-manager
```sh
docker network create -d overlay demo # 让多个节点容器连接到 overlay 网络

docker network ls # 查看一下

```

swarm-worker1
```sh
docker network ls # 查看一下, 发现没有 demo 网络
```

操作一下

swarm-manager(失败)
```sh
# 创建一个 mysql service
docker service create --name mysql --env MYSQL_ROOT_PASSWORD=root --env MYSQL_DATABASE=wordpress --env MYSQL_USER=wordpress --env MYSQL_PASSWORD=wordpress --network demo --mount type=volume,source=mysql-data,destination=/var/lib/mysql mysql:5.7

docker service create --name mysql --env MYSQL_ROOT_PASSWORD=root --env MYSQL_DATABASE=wordpress --env MYSQL_USER=wordpress --env MYSQL_PASSWORD=wordpress --network demo --mount type=volume,source=mysql-data,destination=/var/lib/mysql mysql

#[vagrant@swarm-manager ~]$ docker service ps mysql
#ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
#om17xfbaahhe        mysql.1             mysql:latest        swarm-worker1       Running             Running 40 seconds ago

# 发现这个 service 运行在了 swarm-worker1

#[vagrant@swarm-worker1 ~]$ docker ps
#CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                 NAMES
#7804582448f1        mysql:latest        "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes        3306/tcp, 33060/tcp   #mysql.1.om17xfbaahhe6bjan205fnhuq
# 的确有

# 创建一个 wordpress service
docker service create --name wordpress -p 80:80 --env WORDPRESS_DB_HOST=mysql --env WORDPRESS_DB_USER=wordpress --env WORDPRESS_DB_PASSWORD=wordpress --network demo wordpress

```

[docker-swarm-mysql-masterslave-failover](https://github.com/robinong79/docker-swarm-mysql-masterslave-failover)

swarm-manager(成功)
```sh
docker network create -d overlay demo

docker service create --name mysql --env MYSQL_ROOT_PASSWORD=root --env MYSQL_DATABASE=wordpress --network demo --mount type=volume,source=mysql-data,destination=/var/lib/mysql mysql

# 这里要进行操作
docker exec -it 77167e80b5d6 /bin/bash

mysql -u root -p
root # login
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
exit

docker service create --name wordpress -p 80:80 --env WORDPRESS_DB_PASSWORD=root --env WORDPRESS_DB_HOST=mysql --network demo wordpress

# http://192.168.205.13 
# http://192.168.205.14
# http://192.168.205.15
# 我们发现这个节点都能访问到 wordpress

# overlay 网络，swarm 分配 service 节点的时候会自动创建
```

### 集群服务间通信之RoutingMesh

*DNS服务发现(overlay网络)*

*VIP*

*实验*

swarm-manager
```sh
docker network create -d overlay demo # 让多个节点容器连接到 overlay 网络

docker service create --name whoami -p 8000:8000 --network demo -d jwilder/whoami

docker service ps whoami # 看看运行在那个节点

# [vagrant@swarm-manager ~]$ curl 192.168.205.14:8000
# I'm 7389f68ec50e --> 完美

docker service create --name client -d --network demo busybox sh -c "while true; do sleep 3600; done"

docker service ps client # swarm-worker2
```

swarm-worker2(client)

```sh
docker ps
docker exec -it 477bc60123e0 sh # 进去容器
#/ # ping whoami
#PING whoami (10.0.0.6): 56 data bytes
#64 bytes from 10.0.0.6: seq=0 ttl=64 time=0.349 ms
#64 bytes from 10.0.0.6: seq=1 ttl=64 time=0.226 ms
#通的
```

swarm-manager，扩展 whoami
```sh
docker service scale whoami=2
docker service ps whoami # 看下 whoami service 的部署节点 swarm-manager & swarm-worker1
```

swarm-worker2(client)

```sh
#/ # ping whoami
#PING whoami (10.0.0.6): 56 data bytes
#64 bytes from 10.0.0.6: seq=0 ttl=64 time=0.349 ms
#64 bytes from 10.0.0.6: seq=1 ttl=64 time=0.226 ms
#通的，还是 10.0.0.6
# 这个地址不是 whoami 任何一个容器的地址，它是一个VIP

```

nslookup 命令，mac 演示

```sh
#nslookup www.tanwan.com
#Server:		172.26.9.10
#Address:	172.26.9.10#53

#Non-authoritative answer:
#www.tanwan.com	canonical name = www.tanwan.com.w.kunlunpi.com.
#Name:	www.tanwan.com.w.kunlunpi.com
#Address: 163.177.63.105
#Name:	www.tanwan.com.w.kunlunpi.com
#Address: 163.177.63.104
#Name:	www.tanwan.com.w.kunlunpi.com
#Address: 163.177.63.106
#Name:	www.tanwan.com.w.kunlunpi.com
#Address: 163.177.63.103
#Name:	www.tanwan.com.w.kunlunpi.com
#Address: 163.177.63.101
#Name:	www.tanwan.com.w.kunlunpi.com
#Address: 163.177.63.98
#Name:	www.tanwan.com.w.kunlunpi.com
#Address: 163.177.63.100
#Name:	www.tanwan.com.w.kunlunpi.com
#Address: 163.177.63.102
```

swarm-worker2(client)
```sh
docker exec -it 477bc60123e0 sh
nslookup tasks.whoami
```

swarm-manager
```sh
docker service scale whoami=3
docker service ps whoami
```

swarm-worker1
```sh
docker exec -it 7389f68ec50e /bin/sh

ping whoami
# PING whoami (10.0.0.6): 56 data bytes
# 64 bytes from 10.0.0.6: seq=0 ttl=64 time=0.172 ms
# 64 bytes from 10.0.0.6: seq=1 ttl=64 time=0.185 ms

nslookup tasks.whoami
#nslookup: can't resolve '(null)': Name does not resolve
#Name:      tasks.whoami
#Address 1: 10.0.0.7 7389f68ec50e
#Address 2: 10.0.0.11 whoami.2.q1h49rlqd54r2zcinurn0n5m5.demo
#Address 3: 10.0.0.12 whoami.3.5vqr7leyj4tvxh53q2twczyce.demo

exit

docker ps

docker exec -it 7389f68ec50e ip a
```

swarm-worker2(client)

```sh
[vagrant@swarm-worker2 ~]$ docker exec -it 477bc60123e0 /bin/sh
/ # wget whoami:8000
Connecting to whoami:8000 (10.0.0.6:8000)
index.html           100% |************|    17  0:00:00 ETA
/ # more index.html
I'm b1a25ee9e7ce 
/ # rm -rf index.html
/ # wget whoami:8000
Connecting to whoami:8000 (10.0.0.6:8000)
index.html           100% |************|    17  0:00:00 ETA
/ # more index.html
I'm 44f909aaf2ab # 不同的 container 响应请求了
```

*这些是怎么实现的了*

*Routing Mesh的两种体现*

*Internal--Container 和 Container之间的访问通过overlay网络（通过VIP虚拟IP)
*Ingress--如果服务有绑定接口，则此服务可以通过任意swarm节点的相应接口访问

*自动负载均衡*

*Internal Load Balancing*

*DNS+VIP+iptables+LVS*


### Routing Mesh之Ingress负载均衡

*外部访问的负载均衡
*服务端口被暴露到各个swarm节点
*内部通过IPVS进行负载均衡

swarm-manager
```sh
docker service scale whoami=2

docker service ps whoami
# b8ky62namcj8        whoami.1            jwilder/whoami:latest   swarm-worker1
# q1h49rlqd54r        whoami.2            jwilder/whoami:latest   swarm-manager

# [vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
# I'm 44f909aaf2ab
# [vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
# I'm 7389f68ec50e
# [vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
# I'm 44f909aaf2ab
# [vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
# I'm 7389f68ec50e
# [vagrant@swarm-manager ~]$ curl 127.0.0.1:8000
# I'm 44f909aaf2ab
# 不断的去访问，swarm cluster 会自动负载均衡到不同节点的 container，Ingress 的作用
```

为啥本地没有 whoami service,但是我们又能访问呢，现在一步一步看一下：

swarm-worker2
```sh
# 比较复杂，后面待续……🤣

sudo iptables -nL -t nat # 主要看DOCKER-INGRESS
```

*Ingress Network的数据包走向详情*(后面补充)

### DockerStack部署wordpress

[Compose file](https://docs.docker.com/compose/compose-file/)
*version 3
*`deploy` 
*`endpoint_mode` vip | dnsrr ,默认是 vip

```sh
docker node ls

docker stack # 看一下帮助信息
```

[Wordpress](https://hub.docker.com/_/wordpress)

准备一下 stack.yml
```sh
version: '3.1'

services:

  web:
    image: wordpress
    ports:
      - 8080:80
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
    networks:
      - my-network
    depends_on:
      - db
    deploy:
      mode: replicated
      replicas: 3
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      update_config:
        parallelism: 1
        delay: 10s

  db:
    image: mysql:5.7
    environment:
      MYSQL_DATABASE: exampledb
      MYSQL_USER: exampleuser
      MYSQL_PASSWORD: examplepass
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - my-network
    deploy:
      mode: global
      placement:
        constraints:
          - node.role == manager
volumes:
  mysql-data:

networks:
  my-network:
    driver: overlay
```

```sh
docker stack deploy -c stack.yml wordpress # docker-compose -f stack.yml up
# Creating network wordpress_my-network
# Creating service wordpress_db
# Creating service wordpress_web
# 会自动加上 wordpress 的前缀

docker stack ls
#NAME                SERVICES            ORCHESTRATOR
#wordpress           2                   Swarm

docker stack ps

docker stack ps wordpress # 查看细节
#qiz6uv3qrm4s        wordpress_db.9wpz0pnb3bwlau9kvgm7vsbfk   mysql:5.7           swarm-manager       Running             Running 4 #minutes ago
#k6a09c80xll8        wordpress_web.1                          wordpress:latest    swarm-manager       Running             Running 4 #minutes ago
#p5f5vzpnqee5        wordpress_web.2                          wordpress:latest    swarm-worker2       Running             Running 2 #minutes ago
#reerieqjc9xr        wordpress_web.3                          wordpress:latest    swarm-worker1       Running             Running 4 #minutes ago

# 完美，4 个 service 运行在不同的节点

docker stack rm wordpress # 清理环境
```


### 部署投票应用