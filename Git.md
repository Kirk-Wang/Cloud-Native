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

#### 往仓库里添加文件

4 次提交，一个像模像样的静态页面生成了

1. 加入 index.html 和 git-logo
2. 加入 style.css
3. 加入 script.js
4. 修改 index.html 和 style.css

工作目录---git add files--->暂存区----git commit---->版本历史

```sh
git add xxx
git status
git commit -m'xxx'
git log
```

#### 文件重命名

```sh
# git reset --hard # 危险命令
git mv readme readme.md 
```

#### 查看版本历史

```sh
git help log # 看帮助
git help --web log # 看帮助
git log # 只看当前分支历史的信息
git log --all # 看所有分支
git log --graph # 图形化展示
git log --oneline # 只显示一行
git log -n4 # 最近4次历史
git log --all --graph --oneline -n4 # 自由组合
git branch -v # 看分支
git checkout -b temp 73023f399627 # 基于某一次提交创建一个分支
git commit -am'xxx' # 工作区的东西直接弄到版本历史里面
git branch -av
```