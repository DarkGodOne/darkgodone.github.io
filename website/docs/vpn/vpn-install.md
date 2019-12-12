---
id: vpn
title: Centos7上使用StrongSwan部署IPSecVPN
sidebar_label: Centos7上使用StrongSwan部署IPSecVPN
---

StrongSwan是开源的IPsec vpn解决方案。它支持IKEv1和IKEv2密钥交换协议以及Linux内核的本地NETKEY IPsec栈。本教程将向您展示如何使用strongSwan在CentOS 7上设置IPSec VPN服务器。

## 安装
strongSwan包可以在Enterprise Linux (EPEL)存储库的额外包中获得。但是还是建议使用压缩包自行编译，之前用系统自带包windows总是连接失败。
```
# 安装依赖
yum install pam-devel openssl-devel  make  gcc  gmp-devel wget -y

# 下载软件包并编译，我这现在最新版本为5.8.1
wget http://download.strongswan.org/strongswan.tar.gz
tar xzf strongswan.tar.gz
cd strongswan-5.8.1/

# 配置编译
./configure  --enable-eap-identity --enable-eap-md5 \
--enable-eap-mschapv2 --enable-eap-tls --enable-eap-ttls --enable-eap-peap  \
--enable-eap-tnc --enable-eap-dynamic --enable-eap-radius --enable-xauth-eap  \
--enable-xauth-pam--enable-dhcp--enable-openssl--enable-addrblock --enable-unity\
--enable-certexpire --enable-radattr --enable-tools --enable-openssl --disable-gmp \
--enable-kernel-libipsec

# 编译安装
make
make install

# 验证安装
ipsec --version

```
## 生成证书
VPN客户机和服务器都需要一个证书来标识和验证它们自己。我准备了两个shell脚本来生成和签署证书。首先，我们将[server_key.sh](assets/files/server_key.sh),[client_key.sh](assets/files/client_key.sh)这两个脚本下载到/usr/local/etc/ipsec.d文件夹中。

```
cd /usr/local/etc/ipsec.d
wget https://github.darkgod.online/docs/assets/files/server_key.sh
wget https://github.darkgod.online/docs/assets/files/client_key.sh
chmod +x server_key.sh
chmod +x client_key.sh
```
在这两个脚本中，我设置的组织名称为`DARKGODONLINE`。如果你要修改它，就打开`.sh`文件然后把`O=DARKGODONLINE`替换为`O=你的组织名称`,注意脚本中的"C="和"O="的值必须一致。</br>
然后，用`server_key.sh`跟你服务器的IP地址给服务器生成证书颁发机构(CA)密钥和证书。把`SERVER_IP`替换为你服务器的IP地址。
```
./server_key.sh SERVER_IP
```
生成客户端秘钥、证书和P12文件。在这里，我为VPN用户"john"创建了证书和P12文件。
```
./client_key.sh john john@gmail.com
```
运行脚本前，将"john"和他的email替换为你的。</br>
服务端和客户端的证书都生成好了以后，拷贝`/usr/local/etc/ipsec.d/john.p12`或`/usr/local/etc/ipsec.d/cacerts/strongswanCert.pem`到你的本地电脑。

## 配置
打开IPSec的配置文件。
```
vi /usr/local/etc/ipsec.conf
```

用下面的内容替换文件内容：
```
config setup
    uniqueids=never #多台设备同时在线

conn iOS_cert
    keyexchange=ikev1
    fragmentation=yes
    left=%defaultroute
    leftauth=pubkey
    leftsubnet=0.0.0.0/0
    leftcert=vpnHostCert.pem
    right=%any
    rightauth=pubkey
    rightauth2=xauth
    rightsourceip=10.31.2.0/24
    rightcert=guoxiaokai527Cert.pem
    auto=add

conn android_xauth_psk
    keyexchange=ikev1
    left=%defaultroute
    leftauth=psk
    leftsubnet=0.0.0.0/0
    right=%any
    rightauth=psk
    rightauth2=xauth
    rightsourceip=10.31.2.0/24
    auto=add

conn networkmanager-strongswan
    keyexchange=ikev2
    left=%defaultroute
    leftauth=pubkey
    leftsubnet=0.0.0.0/0
    leftcert=vpnHostCert.pem
    right=%any
    rightauth=pubkey
    rightsourceip=10.31.2.0/24
    rightcert=guoxiaokai527Cert.pem
    auto=add

conn ios_ikev2
    keyexchange=ikev2
    ike=aes256-sha256-modp2048,3des-sha1-modp2048,aes256-sha1-modp2048!
    esp=aes256-sha256,3des-sha1,aes256-sha1!
    rekey=no
    left=%defaultroute
    leftid="198.13.52.213"
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    leftcert=vpnHostCert.pem
    right=%any
    rightauth=eap-mschapv2
    rightsourceip=10.31.2.0/24
    rightsendcert=never
    eap_identity=%any
    dpdaction=clear
    fragmentation=yes
    auto=add

conn windows
    keyexchange=ikev2
    ike=aes256-sha1-modp1024!
    rekey=no
    left=%defaultroute
    leftauth=pubkey
    leftsubnet=0.0.0.0/0
    leftcert=vpnHostCert.pem
    right=%any
    rightauth=eap-mschapv2
    rightsourceip=10.31.2.0/24
    rightsendcert=never
    eap_identity=%any
    auto=add

```
然后编辑strongSwan的配置文件，strongSwan.conf
```
vi /usr/local/etc/strongswan.conf
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
vi /usr/local/etc/ipsec.secrets
```
添加用户"john"到文件内：
```
: RSA vpnHostKey.pem
: PSK "PSK_KEY"
: XAUTH "XAUTH_KEY"
john %any : EAP "John's Password"
```
将上面的PSK_KEY单词更改为你需要的PSK认证方式的密钥;</br>
将上面的XAUTH_KEY单词更改为你需要的XAUTH认证方式的密码,该认证方式的用户名是随意的;</br>
将上面的john改为自己想要的登录名,“John's Password”改为自己想要的密码,可以添加多行,得到多个用户,这即是使用IKEv2的用户名+密码认证方式的登录凭据;</br>
请注意，':' 两侧都需要有空格。(添加完用户后可以使用ipsec reload重新加载配置)

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
firewall-cmd --permanent --add-port=500/udp
firewall-cmd --permanent --add-masquerade
firewall-cmd --reload
```
## 启动VPN
```
编辑自启动脚本ipsecd.service，保存到/etc/systemd/system/ipsecd.service
[Unit]
Description=ipsec for strongswan Service
After=network.target

[Service]
Type=forking
PIDFile=/run/charon.pid
ExecStart=/usr/local/sbin/ipsec start
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

启动并设置开机启动
systemctl start ipsecd
systemctl enable ipsecd
```
StrongSwan现在就运行在你的服务器上了。在你的设备上安装`strongswanCert.pem`或`.p12`证书文件，你就可以连接你的VPN科学上网啦。

## IOS配置
打开手机设置，进入通用->VPN->添加VPN配置
![iosvpn](assets/vpn/iosvpn.png)
类型 -- 选择IPsec，这个不需要安装证书，会方便一点</br>
描述 -- vpn名称（随便填）</br>
服务器 -- 服务器IP</br>
账户 -- 填写用户名</br>
密码 -- 填写密码</br>
密钥 -- 填写PSK密码</br>
配置完点击完成，然后就可以连接VPN放飞自我了

## Windows10配置
### 安装证书
首先下载之前生成的.P12文件，然后双击P12文件，选择本地计算机，点击下一步：
![import1](assets/vpn/import1.png)

已经选择了要导入的p12文件，然后直接点击下一步
![import2](assets/vpn/import2.png)

输入证书的密码，然后点击下一步
![import3](assets/vpn/import3.png)

选择自行制定存储路径，然后点击浏览选择受信任的根证书颁发机构，点击下一步
![import4](assets/vpn/import4.png)

点击完成，导入成功
![import5](assets/vpn/import5.png)

### 配置VPN
点击网络图标，点击进入网络和Internet
![configvpn1](assets/vpn/configvpn1.png)

点击VPN，添加VPN
![configvpn2](assets/vpn/configvpn2.png)

填入相关信息，点击保存
![configvpn3](assets/vpn/configvpn3.png)
VPN提供商->只有一个选项</br>
连接名称->随便起</br>
服务器名称或地址->填写服务器IP</br>
VPN类型->选择IKEv2</br>
登录信息的类型->默认选择用户名和密码</br>
用户名->填写用户名</br>
密码->填写密码</br>
然后就可以愉快的放飞自我了
