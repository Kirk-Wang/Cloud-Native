# DevOps

### Docker 能干什么？
* 简化配置
* 代码流水线管理
* 提高开发效率
* 隔离应用
* 整合服务器
* 调试能力
* 多租户
* 快速部署

### 容器时代的“双城记”
* docker & kubernetes(k8s)

### DevOps = 文化 + 过程 + 工具

![devops](./images/devops.png)

### Long Long Time Ago

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

[aliyun-access-key](./images/aliyun-access-key.png)

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




