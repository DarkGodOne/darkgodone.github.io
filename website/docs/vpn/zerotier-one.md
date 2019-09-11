---
id: zerotier
title: 简单好用的点对点私网穿越工具：Zerotier-one
sidebar_label: 简单好用的点对点私网穿越工具：Zerotier-one
---

ZeroTier将整个世界转换为一个单一的数据中心或云区域。将所有设备、虚拟机和应用程序联网，就像它们都插在同一个交换机上一样。而且这个工具安装、部署、配置都超级简单，不需要太多操作即可完成组网。甚至都不要你自己搭建公网服务器（如果需要提高网络速度，还是建议搭建一个moon服务器）。

## 注册
登录[官网](https://www.zerotier.com/),点击登录
![zerotierpages](assets/vpn/zerotierpages.png)

继续点击登录进入zerotier
![zerotierpages2](assets/vpn/zerotierpages2.png)

注册按钮在这里
![zerotierpages3](assets/vpn/zerotierpages3.png)

填入邮箱和密码点击注册即可，稍后会发送验证码到邮箱内
![register](assets/vpn/register.png)

收到邮件后，点击邮件内的连接即可完成注册
![email](assets/vpn/email.png)

登录后就可以看到自己的管理页面了，这个页面只需要关注两个点
1. 自己得到的内部ID，基本用不上，知道有这个东西就行
2. 选择服务版本，免费版本支持100个设备完全够用
![account](assets/vpn/account.png)

## 创建网络
点击菜单项中的网络
![network](assets/vpn/networks.png)

点击创建网络按钮即可创建属于你的网络
![createnetwork](assets/vpn/createnetwork.png)

右侧可以看到创建的网络id，然后点击进入网络配置页面，网络id很重要，设备加入时会用到
![networkid](assets/vpn/networkid.png)

新创建的网络成员是空的，后续添加后这里会显示网络成员的状态
![membernull](assets/vpn/membernull.png)

## 安装客户端
### windows
回到官网，点击菜单中的下载按钮，进入下载页（控制台页面的下载地址可能有问题，不能用了），[传送门](https://www.zerotier.com/download/)
![download](assets/vpn/download.png)

在这里可以找到所有平台的下载地址，我们要用的是windows，直接下载安装包即可
![downloadwindows](assets/vpn/downloadwindows.png)

双击安装包，无脑下一步即可完成安装，安装完成以后，可以在开始菜单找到启动程序
![application](assets/vpn/application.png)

启动程序后，右下角会出现托盘程序，右键选择加入网络
![joinnetwork](assets/vpn/joinnetwork.png)

输入之前创建的网络ID点击加入
![joinnetwork2](assets/vpn/joinnetwork2.png)

### linux
我用的是centos7，在linux下安装有两种方法
1. 命令行安装，即可完成安装
```
curl -s https://install.zerotier.com | sudo bash
```
2. 源码安装
```
在官方git上下载源码,并解压
wget https://github.com/zerotier/ZeroTierOne/archive/1.4.6.tar.gz
tar xvzf 1.4.6.tar.gz

进入目录中直接make以及make install即可
cd ZeroTierOne-1.4.6
make
make install
```

设置后台启动
```
systemctl enable zerotier-one
systemctl start zerotier-one

树莓派上
zerotier-one -d
然后把这个命令加到/etc/rc.local里面即可开机自动启动
```

加入指定网络，将"网络id"替换为你的网络id即可
```
zerotier-cli join 网络id
```

## 配置允许连接
此时打开控制台web或者直接点击托盘程序右键菜单中的Zerotier Central按钮进入控制中心，此时成员列表中就出现了我们的电脑
![joinmember](assets/vpn/joinmember.png)

但是此时该设备还没有启用，前面还是虚线，我们需要点击设备列表前面的复选框启用该设备才算完成，启用后可以看到设备分配的ip地址以及在线状态，还可以添加设备备注用于区分多个设备
![joinmember2](assets/vpn/joinmember2.png)

## 测试是否成功
由于网络中最少需要两个设备才可以，这里我已经有了一个网络
![memberfull](assets/vpn/memberfull.png)

我们来做一下测试
![ping](assets/vpn/ping.png)

甚至可以连VNC哦，速度也不错
![vnc](assets/vpn/vnc.png)

## 加速节点zerotier moon部署
由于zerotier的官方服务器都在国外，墙内的子民表示连接会出现卡顿以及高演示的情况，但是官方提供部署moon节点的方式可以优化网络环境，下面我们就来搞一下。说明一下，moon的搭建是为了补充根节点在国外,速度慢, 且不稳定的一个方案,它并不能替代官方服务器单独运行。

1. 在公网服务器上安装zerotier
```
 curl -s https://install.zerotier.com/ | sudo bash
```
2. 生成moon配置文件
```
cd /var/lib/zerotier-one  #安装好zerotier后,自动会安装到此目录

sudo zerotier-idtool initmoon identity.public > moon.json         #该命令将id文件转换为能用于配置的json
```
3. 修改配置文件moon.json中的stableEndpoints，需要将其修改为公网ip，9993为默认端口
```
"stableEndpoints": [ "23.23.23.23/9993" ]

注：23.23.23.23一定要是公网ip，一定要配置正确,Zerotier依靠此配置去连接moon.
后面的端口若没有改变则默认都是9993端口, 此处在防火墙上需要开放9993端口,否则是连接不上Moon的.
```
**该配置里面,有一个id字段,10个字符,如: ["id": "18fasd2319"],  就是moon的id, 在客户端连接时,需要用到它.**

4. 生成moon文件
```
sudo zerotier-idtool genmoon moon.json 
```
执行该命令后,会在在/var/lib/zerotier-one目录下生成一个类似00000018fasd2319.moon的文件..这个文件非常重要,所有的客户端要连接上moon都是依靠该文件关联的.

5. 使moon配置生效
在/var/lib/zerotier-one目录下,新建一个 moons.d 文件夹，并将刚生成的moon配置文件放到该文件夹下
```
mv 000000xxxxxxxxxx.moon moons.d/
```
6. 重新启动moon服务器
```
systemctl restart zerotier-one
```
经过以上配置,服务器上的moon即配置并应用完闭.

7. 客户端安装

**方法一**

在zerotier安装目录中新建moods.d目录，并将之前生成的000000xxxxxx.moon文件拷贝进去，重启服务即可。
```
linux路径：/var/lib/zerotier-one/
windows路径: C:\ProgramData\ZeroTier\One
```

**方法二**

只需执行此命令即可,**此处需要输入两遍id**:
```
zerotier-cli orbit 18fasd2319 18fasd2319
```
8. 验证moon是否成功
```
只需要执行命令：
zerotier-cli listpeers
```
在打印内容中如果有我们配置的网络id即可
![moon](assets/vpn/moon.png)

