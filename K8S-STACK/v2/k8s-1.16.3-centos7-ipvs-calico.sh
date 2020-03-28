# 备份本地 yum 源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo_bak

# 获取阿里 yum 源配置文件
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

# 清理 yum
yum clean all

# 更新软件版本并且更新现有软件
yum -y update
