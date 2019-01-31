### 重修 Git(一切为了更好的 DevOps🤦‍♀️)

#### 安装完后，配置 user 信息
```sh
git config --global user.name 'your_name'
git config --global user.email 'your_email@domain.com'
```

##### config 的三个作用域

缺省等同于 local
```sh
git config --local #local只对某个仓库有效
git config --global #global对当前用户所有仓库有效(工作常用)
git config --system #sytem对系统所有登录的用户有效
```

显示 config 的配置，加 --list
```sh
git config --list --local
git config --list --global
git config --list --system
```

#### 建 Git 仓库
两种场景：
1. 把已有的项目代码纳入 Git 管理
```sh
cd 项目代码所在的文件夹
git init
```

2. 新建的项目直接用Git管理
```sh
cd 某个文件夹
git init your_project # 会在当前路径下创建和项目名称同名的文件夹
cd your_project
```