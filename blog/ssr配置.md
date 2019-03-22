## ssr配置

### 参考链接：

* https://blog.csdn.net/breeze915/article/details/7924367

### 步骤：
#### 1. 升级内核

```bash
# 载入公钥
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# 安装ELRepo
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# CentOS6 系统使用el6的包
# rpm -Uvh http://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm
# 载入elrepo-kernel元数据
yum --disablerepo=\* --enablerepo=elrepo-kernel repolist
# 查看可用的rpm包
yum --disablerepo=\* --enablerepo=elrepo-kernel list kernel*
```

![img](https://yixing.github.io/img/k1-1024x412.png)

```bash
# 安装最新版本的kernel
yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml.x86_64
 
#CentOS6 系统不再提供ml（主线）版本的kernel，只有lt（长期维护）版本4.4的内核
```
![img](https://yixing.github.io/img/k2-1024x551.png)

最后一步，需要将内核工具包一并升级

```bash
# 删除旧版本工具包
yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64
# 安装新版本工具包
yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml-tools.x86_64
```

#### 2. 更新grub

```bash
#查看当前的启动列表
awk -F \' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg 

0 : CentOS Linux 7 Rescue 86367c64acce45faa9614c6ae7fdcddb (4.20.7-1.el7.elrepo.x86_64)
1 : CentOS Linux (4.20.7-1.el7.elrepo.x86_64) 7 (Core)
2 : CentOS Linux (3.10.0-957.1.3.el7.x86_64) 7 (Core)
3 : CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)
4 : CentOS Linux (0-rescue-84d6e1c3c43d427ab345edad898ac223) 7 (Core)
grub2-editenv list #查看当前default启动项
saved_entry=CentOS Linux (3.10.0-957.1.3.el7.x86_64) 7 (Core)
grub2-set-default 1 #设置新的default启动项
grub2-editenv list #查看新的启动项
saved_entry=1
reboot #重启
#--------------------------------------------
uname -r #检查新的内核版本
4.20.7-1.el7.elrepo.x86_64
```

#### 3. 开启BBR

```bash
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
```
```bash
[root@zion ~]# /sbin/sysctl net.ipv4.tcp_available_congestion_control
net.ipv4.tcp_available_congestion_control = reno cubic bbr
[root@zion ~]# /sbin/sysctl net.ipv4.tcp_congestion_control
net.ipv4.tcp_congestion_control = bbr
```

#### 4. 配置SSR

```bash
yum -y install wget
wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh
chmod +x shadowsocksR.sh .
./shadowsocksR.sh 2>&1 | tee shadowsocksR.log
```

![img](https://yixing.github.io/img/ssr.png)

配置完成后shadowsocks添加到启动列表

```bash
`chkconfig --list`
```
