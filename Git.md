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

#### gitk

Mac, homebrew 安装
```sh
git --version
# git version 2.17.2 (Apple Git-113), Mac OS 自带的，是没有 gitk 的
brew install git
type -a git
# git is a shell function from /Users/zoot/.zshrc
# git is /usr/local/bin/git
# git is /usr/bin/git

gitk
```

#### 探秘 .git 目录

```sh
ls -al .git
cat .git/HEAD # 切换分支的时候，会变
# ref: refs/heads/master

cat .git/config
#[core]
#        repositoryformatversion = 0
#        filemode = true
#....
#[remote "origin"]
#        url = git@github.com:Kirk-Wang/DevOps.git
#        fetch = +refs/heads/*:refs/remotes/origin/*
#[branch "master"]
#        remote = origin
#       merge = refs/heads/master

ls -al .git/refs
ls -al .git/refs/heads

cat .git/refs/heads/master
# 97d75d2d640dcf100b31c2a023a54f9b947cdc8e

git cat-file -t 97d75d2d640 # 看文件内容类型
# commit

ls -al .git/refs/tags

cat .git/refs/tags/0.0.1
# 9c7f1904f74bde85f01a71101fcd170e31478eb3
git cat-file -t 9c7f1904f74 # 看文件内容类型
# tag
git cat-file -p 9c7f1904f74 # 看 tag 内容
# object eccdc97814db15f44d26d150589d400f5ecb4d48
# type commit
# tag 0.0.1
# tagger Kirk.Wang <kirk.w.wang@gmail.com> 1548921162 +0800
# 
# test tag
git cat-file -t eccdc97814db15f
# commit

ls -al .git/objects

ls -al .git/objects/c5
# drwxr-xr-x    3 zoot  staff    96  1 24 20:03 .
# drwxr-xr-x  128 zoot  staff  4096  1 31 16:12 ..
# -r--r--r--    1 zoot  staff   160  1 24 20:03 ee89f2588b2fbf443d888d1085e5e3bbd987b1
git cat-file -t c5ee89f2588b2fbf443d888d1085e5e3bbd987b1(c5+ee89f2588b2fbf443d888d1085e5e3bbd987b1)
# tree
git cat-file -p c5ee89f2588b2fbf443d888d1085e5e3bbd987b1
# 看内容 blob

#commit & tree & blob

```

#### commit tree blob 对象之间的关系

commit > tree > blob

```sh
git log (commit)
git cat-file -p xxxx (tree)
git cat-file -p xxxx (blob) 
# 可以一层一层的看
```

#### 数一数 tree 的个数
新建的 Git 仓库，有且仅有1个 commit, 仅仅包含 /doc/readme, 请问内含多少个 tree，多少个 blob? 


#### detached HEAD 分离头指针（工作在没有分支的状态下）

```sh
git log (一堆commit)
git checkout xxxx(切到某个具体的 commit)
# detached HEAD
# 坏处：没有 branch 做关联，做完变更厚，chekout 回去^_^,,,git可能会把变更的部分当做垃圾给干掉
# 变更要与 brach 关联
# 好处：只想做尝试性的变更

git commit -am'xxx'

git log

git branch -av # 突然要 hot fix bug，需 checkout master

git checkout master # 注意看 git 提示(git branch <新分支名> 91eb539)
# 不然你的灵感，会在不久就会被 git 扔掉🤣

gitk --all
```

重要的变更一定要和具体分支绑定在一起。

#### 进一步理解 HEAD 和 branch

```sh
git checkout -b fix_readme master(或者某个commit) # 创建并切换分支

gitk --all # 用 gitk 看一下
cat .git/HEAD 

git diff commitA commitB 

git diff HEAD HEAD^ (最新的前两个比较)
git diff HEAD HEAD~

git diff HEAD HEAD^1^1
git diff HEAD HEAD^^
git diff HEAD HEAD~2

```

#### 删掉不要的分支

```sh
gitk -all # 仔细看一下项目中的分支
git branch -d oo # 删不掉用 -D
git branch -D fafa

```

#### 修改最新的 commit 的 message

```sh
git commit --amend
```

#### 修改老旧 commit 的 message

```sh
git rebase # 变基，这里针对自己的分支，不要在团队的集成分支上瞎搞

git log # 找到老的 commit

git rebase -i ca7936381 # 找到要改的 commit 的 父亲节点，交互式操作，选择 reword 模式 step by step

git push --force # 哈哈哈哈
```

#### 把连续的多个 commit 整理成一个

```sh
git branch -av
git log --graph
git rebase -i ca7936381 # 找到父亲节点，交互式操作，选择 s 模式 step by step
#pick xxxx
#s xxxx
#s xxxx
#s xxxx
#pick xxxx
```

#### 把间隔的多个 commit 整理成一个

```sh
git log --graph
git rebase -i ca7936381 # 可能会出现两颗孤独的树
```

#### 比较暂存区和HEAD所含文件的差异

```sh
git add index.html
git status
git diff --cached # 暂存区和HEAD的差异
```

#### 工作区与暂存区的差异
```sh
git diff # 默认比较的是工作区与暂存区的区别

git diff -- readme.md # 只比较 readme.md 文件
git diff -- readme.md style.css # 比较多个文件
```

#### 让暂存区恢复成HEAD
```sh
git status
git reset HEAD
git status
```

#### 让工作区恢复为和暂存区一样
```sh
vi index.html
git add index.html
git diff --cached
vi index.html

git checkout -- index.html
git diff index.html
ls -al
```

#### 取消暂存区部分文件的更改
```sh

git reset HEAD -- style.css # 一个文件
git status

git reset HEAD -- style.css readme.md # 多个文件
git status

```

#### 消除最近的几次提交
```sh
gitk --all

git reset --hard 5bfcca1ca6 # 慎用，比较危险
```

#### 不同提交的指定文件的差异
```sh
git log -n8 --all --graph

git diff temp master -- index.html # 比较两个分支当中某个文件的差异

```

#### 正确删除文件的方法
```sh
git rm readme # 直接放到暂存区
```

#### 开发中临时加塞了紧急任务(暂存区有东西，工作区有变更，现在要 hot fix)
```sh
git stash
git stash list

git stash pop # 丢掉 stash 里面的东西
git stash apply # 不丢掉
```

#### 指定不需要 Git 管理的文件

.gitignore

[gitignore](https://github.com/github/gitignore)