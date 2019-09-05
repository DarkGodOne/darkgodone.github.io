---
id: local
title: Openwrt 本地源配置
sidebar_label: Openwrt 本地源配置
---

## 第一步：搭建HTTP服务
### Windows
使用hfs搭建HTTP服务
```
下载地址
http://www.rejetto.com/hfs/?f=dl
```
下载完成后直接双击即可使用，打开后将生成的软件包拖入到hfs中即可生成本地地址
![hfs](assets/hfs.png)

### Ubuntu
使用Apache来搭建HTTP服务,首先安装apache
```
sudo apt-get install apache2
```
如需修改端口，可以编辑/etc/apache2/ports.conf
```
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

#Listen 80
Listen 8001

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```
然后进入/var/www/html目录，将软件包拷贝到该目录或新建一个软连接即可
![apache](assets/apache.jpg)

然后重启服务
```
sudo /etc/init.d/apache2 restart
```

然后就可以访问文件路径了
![filelist](assets/filelist.png)

## 第二步：更新包签名
### 1. 生成一对公钥和私钥，公钥用于路由对签名文件进行校验，私钥用于我们生成签名文件
```
hokamyuen@hokamyuen-linux:~/lede-sdk-ar71xx-generic_gcc-5.4.0_musl.Linux-x86_64/staging_dir/host/bin$ ./usign -G -s mime.key -p mime.pub
```
### 2. 利用生成的私钥对服务器上的Packages文件生成签名文件，Packages文件不在当前目录的话要加上路径
```
hokamyuen@hokamyuen-linux:~/lede-sdk-ar71xx-generic_gcc-5.4.0_musl.Linux-x86_64/staging_dir/host/bin$ ./usign -S -m Packages -s mime.key -x Packages.sig
```

### 3. 将公钥上传到openwrt上，在路由上新增我们生成的公钥
```
root@LEDE:~# scp hokamyuen@192.168.1.150:~/lede-sdk-ar71xx-generic_gcc-5.4.0_musl.Linux-x86_64/staging_dir/host/bin/mime.pub /tmp
hokamyuen@192.168.1.150's password: 
mime.pub                                                                                                        100%  104     0.1KB/s   00:00    
root@LEDE:~# cd /tmp
root@LEDE:/tmp# opkg-key add mime.pub
root@LEDE:/tmp# 
```

### 4. 在openwrt上设置本地源地址
```
vim /etc/opkg/distfeeds.conf

对应路径替换为如下：
src/gz openwrt_core http://127.0.0.1/packages/packages
src/gz openwrt_base http://127.0.0.1/packages/base
src/gz openwrt_luci http://127.0.0.1/packages/luci
src/gz openwrt_packages http://127.0.0.1/packages/packages
src/gz openwrt_routing http://127.0.0.1/packages/routing
src/gz openwrt_telephony http://127.0.0.1/packages/telephony
```

### 5.在openwrt内更新软件包
```
opkg update
```
本地源配置完成

## 第三步：软件包签名更新脚本
这里写了一个脚本用于对软件包内容进行更新以及签名,脚本路径在openwrt源码根目录
```
#!/bin/bash
BASEDIR=`pwd`
SCRIPT=$BASEDIR/scripts/ipkg-make-index.sh
cd bin/packages/x86_64/base/
# Generates package manifest
$SCRIPT . 2>/dev/null > Packages.manifest
grep -vE '^(Maintainer|LicenseFiles|Source|Require)' Packages.manifest > Packages
gzip -9nc Packages > Packages.gz
$BASEDIR/staging_dir/host/bin/usign -S -m Packages -s $BASEDIR/mime.key -x Packages.sig
```

