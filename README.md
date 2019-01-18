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

Docker Machine 能干什么？

```sh
vagrant halt // 停掉
vagrant destroy // 删掉机器
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
```