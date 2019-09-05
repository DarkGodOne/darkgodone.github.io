---
id: domestic
title: Openwrt 国内源配置
sidebar_label: Openwrt 国内源配置
---

Openwrt 官网在国外，国内访问速度超级慢，简直不能忍，不过可以通过修改软件源到国内解决：

## 第一步：获取国内软件源地址

**中国科技大学教育网官方主镜像网站：**
```
http://mirrors.ustc.edu.cn/
```

**清华大学开源软件镜像站：**
```
https://mirrors.tuna.tsinghua.edu.cn/
```

## 第二步：找到软件包路径
上面提到的两个网站中软件包所在的开源项目名称为lede（清华的那个里面有openwrt，里面只有15.xxx版本的），进入页面后会有[OpenWrt 18.06.4](http://mirrors.ustc.edu.cn/lede/releases/18.06.4/targets)的链接，但是这里有个坑需要跳一下：

1. 进入链接以后默认路径是http://mirrors.ustc.edu.cn/lede/releases/18.06.4/targets ，这里只有一个软件目录在这里
2. 其他的软件包路径在上一级目录（这个地方之前找了好久，还以为不对，原来需要到上一级），在http://mirrors.ustc.edu.cn/lede/releases/18.06.4/packages 里面

## 第三步：替换Openwrt软件源
### 方法一
进入系统直接修改配置文件
```
vim /etc/opkg/distfeeds.conf

对应路径替换为如下：
src/gz openwrt_core http://mirrors.ustc.edu.cn/lede/releases/18.06.4/targets/x86/64/packages
src/gz openwrt_base http://mirrors.ustc.edu.cn/lede/releases/18.06.4/packages/x86_64/base
src/gz openwrt_luci http://mirrors.ustc.edu.cn/lede/releases/18.06.4/packages/x86_64/luci
src/gz openwrt_packages http://mirrors.ustc.edu.cn/lede/releases/18.06.4/packages/x86_64/packages
src/gz openwrt_routing http://mirrors.ustc.edu.cn/lede/releases/18.06.4/packages/x86_64/routing
src/gz openwrt_telephony http://mirrors.ustc.edu.cn/lede/releases/18.06.4/packages/x86_64/telephony
```
### 方法二
进入openwrt的管理页面，选择  系统-->软件包-->配置OPKG，在opkg/distfeeds.conf部分替换对应国内源地址，最后点击保存即可
![openwrt opkg](assets/opkgconfig.jpg)

## 第四步：更新软件包列表
在命令行直接执行：
```
opkg update
```
或者在管理页面点击更新列表
![openwrt opkg](assets/opkgupdate.jpg)
