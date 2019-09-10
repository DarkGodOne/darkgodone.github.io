---
id: vpn
title: Centos7上使用StrongSwan部署IPSecVPN
sidebar_label: Centos7上使用StrongSwan部署IPSecVPN
---

StrongSwan是开源的IPsec vpn解决方案。它支持IKEv1和IKEv2密钥交换协议以及Linux内核的本地NETKEY IPsec栈。本教程将向您展示如何使用strongSwan在CentOS 7上设置IPSec VPN服务器。

## 安装
strongSwan包可以在Enterprise Linux (EPEL)存储库的额外包中获得。我们应该先启用EPEL，然后安装strongSwan。
```
yum install http://ftp.nluug.nl/pub/os/Linux/distr/fedora-epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
yum install strongswan openssl
```
## 生成证书
VPN客户机和服务器都需要一个证书来标识和验证它们自己。我准备了两个shell脚本来生成和签署证书。首先，我们将[server_key.sh](assets/files/server_key.sh),[client_key.sh](assets/files/client_key.sh)这两个脚本下载到/etc/strongswan/ipsec.d文件夹中。

```
cd /etc/strongswan/ipsec.d
wget https://github.darkgod.online/docs/assets/files/server_key.sh
wget https://github.darkgod.online/docs/assets/files/client_key.sh
chmod +x server_key.sh
chmod +x client_key.sh
```
在这两个脚本中，我设置的组织名称为`DARKGOD-ONLINE`。如果你要修改它，就打开`.sh`文件然后把`O=DARKGOD-ONLINE`替换为`O=你的组织名称`。</br>
然后，用`server_key.sh`跟你服务器的IP地址给服务器生成证书颁发机构(CA)密钥和证书。把`SERVER_IP`替换为你服务器的IP地址。
```
./server_key.sh SERVER_IP
```
生成客户端秘钥、证书和P12文件。在这里，我为VPN用户"john"创建了证书和P12文件。
```
./client_key.sh john john@gmail.com
```
运行脚本前，将"john"和他的email替换为你的。</br>
服务端和客户端的证书都生成好了以后，拷贝`/etc/strongswan/ipsec.d/john.p12`和`/etc/strongswan/ipsec.d/cacerts/strongswanCert.pem`到你的本地电脑。

## 配置
打开IPSec的配置文件。
```
vi /etc/strongswan/ipsec.conf
```

用下面的内容替换文件内容：
```
config setup
    uniqueids=never
    charondebug="cfg 2, dmn 2, ike 2, net 0"

conn %default
    left=%defaultroute
    leftsubnet=0.0.0.0/0
    leftcert=vpnHostCert.pem
    right=%any
    rightsourceip=172.16.1.100/16

conn CiscoIPSec
    keyexchange=ikev1
    fragmentation=yes
    rightauth=pubkey
    rightauth2=xauth
    leftsendcert=always
    rekey=no
    auto=add

conn XauthPsk
    keyexchange=ikev1
    leftauth=psk
    rightauth=psk
    rightauth2=xauth
    auto=add

conn IpsecIKEv2
    keyexchange=ikev2
    leftauth=pubkey
    rightauth=pubkey
    leftsendcert=always
    auto=add

conn IpsecIKEv2-EAP
    keyexchange=ikev2
    ike=aes256-sha1-modp1024!
    rekey=no
    leftauth=pubkey
    leftsendcert=always
    rightauth=eap-mschapv2
    eap_identity=%any
    auto=add
```
然后编辑strongSwan的配置文件，strongSwan.conf
```
vi /etc/strongswan/strongswan.conf
```
使用下面的内容替换文件原有内容：
```
charon {
    load_modular = yes
    compress = yes
    plugins {
            include strongswan.d/charon/*.conf
    }
    dns1 = 8.8.8.8
    dns2 = 8.8.4.4
    nbns1 = 8.8.8.8
    nbns2 = 8.8.4.4
}

include strongswan.d/*.conf
```
编辑IPsec密码文件来添加用户名和密码：
```
vi /etc/strongswan/ipsec.secrets
```
添加用户"john"到文件内：
```
: RSA vpnHostKey.pem
: PSK "PSK_KEY"
john %any : EAP "John's Password"
john %any : XAUTH "John's Password"
```
请注意，':' 两侧都需要有空格。

## 允许IPV4转发
编辑`/etc/sysctl.conf`来使能linux内核的转发功能。
```
vi /etc/sysctl.conf
```
添加如下内容到文件末尾：
```
net.ipv4.ip_forward=1
```
保存文件后应用更改，是配置生效。
```
sysctl -p
```
## 配置防火墙
在你的服务器上打开VPN相关端口
```
firewall-cmd --permanent --add-service="ipsec"
firewall-cmd --permanent --add-port=4500/udp
firewall-cmd --permanent --add-masquerade
firewall-cmd --reload
```
## 启动VPN
```
systemctl start strongswan
systemctl enable strongswan
```
StrongSwan现在就运行在你的服务器上了。在你的设备上安装`strongswanCert.pem`和`.p12`证书文件，你就可以连接你的VPN科学上网啦。
