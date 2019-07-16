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

### Vagrant
**Development Environments Made Easy**

先安装 [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

接下看 Vagrant 入门指南->[Getting Started](https://www.vagrantup.com/intro/getting-started/index.html)






