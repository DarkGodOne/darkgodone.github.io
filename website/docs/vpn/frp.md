---
id: frp
title: 一款很好用的内网穿透工具--FRP
sidebar_label: 一款很好用的内网穿透工具--FRP
---

## 废话
之前提到了zerotier-one可以实现点对点私网穿透，但是实际使用你会发现，当你需要私网穿透的时候你必须安装客户端而且需要做一些配置(简单配置),总归有点不方便，最主要的问题是这个工具在手机上貌似有点问题，iphone的国区水果商店没有zerotier的客户端，据我亲测就是使用外服账号下载了也没有办法接入网络，这是一个硬伤，而且这个网络是依赖于zerotier的官方网络的，所以你被别人监控了你都不知道，没有安全感。
正好我有用到云服务器，所以想到了使用代理中转的方式实现私网穿透，这其中发现frp是真的超级简单实用，下面就来感受下吧。

##介绍
FRP项目地址：[https://github.com/fatedier/frp](https://github.com/fatedier/frp)
frp 是一个可用于内网穿透的高性能的反向代理应用，支持 tcp, udp 协议，为 http 和 https 应用协议提供了额外的能力，且尝试性支持了点对点穿透。

## 安装
FRP 采用 Go 语言开发，支持 Windows、Linux、MacOS、ARM等多平台部署。安装非常简单，只需要下载对应平台的压缩包然后解压就可以了。
```
#树莓派即使4b已经是64位的CPU了，但是系统仍然是32位的哦，所以别下载错了
wget https://github.com/fatedier/frp/releases/download/v0.29.1/frp_0.29.1_linux_arm.tar.gz
tar xvzf frp_0.29.1_linux_arm.tar.gz
cd frp_0.29.1_linux_arm
```

## 服务配置
由于是中转模式的私网穿透，所以首先你需要有一台具有公网IP的服务器。服务器可以是任何 Windows、Linux、MacOS、ARM 的系统，因为frp都支持，我这里用的Centos7。
压缩包内的配置文件有两个，一个是简化版frps.ini和frpc.ini，一个是完全版frps_full.ini和frpc_full.ini。

### 服务端配置
```
$ cat frps_full.ini

# [common] is integral section
[common]
# bind_addr是服务端绑定的地址默认0.0.0.0
bind_addr = 0.0.0.0

# bind_port是绑定的TCP端口，默认7000
bind_port = 7000

# 用于udp打洞用的端口，默认7001
bind_udp_port = 7001

# kcp协议使用的端口，可以跟bind_port使用相同的端口，如果没有设置默认是关闭的
# kcp_bind_port = 7000

# 代理服务地址，暂时不用
# proxy_bind_addr = 127.0.0.1

# 如果你要使用自己的web服务，那么必须打开该配置
# http和https的端口可以跟bind_port相同
vhost_http_port = 8080
#vhost_https_port = 8080

# web服务http请求超时时间，单位是秒，默认60s
# vhost_http_timeout = 60

# frps拥有的仪表板，可以查看frps的相关信息，透传情况
# 默认监听地址与bind_addr一样
# 只有当dashboard_port字段设置了以后，才会启用仪表板功能
dashboard_addr = 0.0.0.0
dashboard_port = 7500

# 仪表板的登录名和密码，如果不设置的话，默认都是admin
dashboard_user = admin
dashboard_pwd = admin

# 仪表板资产目录(只有debug模式使用)
# assets_dir = ./static

# 日志文件存储位置
log_file = ./frps.log

# 日志级别：trace, debug, info, warn, error
log_level = info

# 日志最大保存天数
log_max_days = 3

# 当时用终端运行时，禁用日志颜色，默认是false(就是不禁用，花花绿绿看的多好看)
disable_log_color = false

# 鉴权token
token = xxxxxxx

# 心跳配置，这个最好不要修改默认值,默认心跳超时90秒
# heartbeat_timeout = 90

# 只允许客户单绑定如下端口，如果不设置则不限制
#allow_ports = 2000-3000,3001,3003,4000-50000

# 每个代理的最大连接池
max_pool_count = 5
 
# 每个客户端最多可以绑定多少个端口，默认0是不限制
max_ports_per_client = 0

# 通过在 frps 的配置文件中配置 subdomain_host，就可以启用该特性。之后在 frpc 的 http、https 类型的代理中可以不配置 custom_domains，而是配置一个 subdomain 参数。例如subdomain为test，则路由为test.frps.com
#subdomain_host = frps.com

# tcp多路复用, 默认true
tcp_mux = true

# custom 404 page for HTTP requests
# custom_404_page = /path/to/404.html

$ ./frps -c ./frps.ini
2019/11/07 06:57:38 [I] [service.go:139] frps tcp listen on 0.0.0.0:7000
2019/11/07 06:57:38 [I] [root.go:205] Start frps success
#这里可以看到服务端已经成功启动并监听7000端口

```

### 客户端配置
frp客户端有许多功能，需要查看完整版配置文件，我这里就只写两个常用实例，具体其他实例可以参考frpc_full.ini配置文件。
#### 实例一：TCP
通过代理访问ssh
```
[common]
# server_addr 为 FRP 服务端的公网 IP
server_addr = 4.3.2.1
# server_port 为 FRP 服务端监听的端口
server_port = 7000

# 名字自己起
[ssh]
# 协议类型，tcp | udp | http | https | stcp | xtcp, 默认 tcp
type = tcp
# 本地服务地址
local_ip = 127.0.0.1
# 本地服务端口
local_port = 22
# 远端注册端口
remote_port = 6000

#这样我们就可以使用公网地址的6000端口访问私网内的ssh服务了

```

#### 实例二：HTTP
```
[common]
# server_addr 为 FRP 服务端的公网 IP
server_addr = 4.3.2.1
# server_port 为 FRP 服务端监听的端口
server_port = 7000

# 名字自己起
[web]
# 协议类型，tcp | udp | http | https | stcp | xtcp, 默认 tcp
type = http
# 本地服务端口
local_port = 8080
# 访问域名
custom_domains = aa.bbb.com
# 自定义二级域名，可以根据不同的前缀指向不同的服务
subdomain = test

```

## frp仪表板
frp提供了简单的仪表板用于监控和查看服务状态，只需要在frps配置文件中配置
```
dashboard_addr = 0.0.0.0
dashboard_port = 7500
```
即可通过7500端口访问仪表板，非常方便。
![dashboard](assets/vpn/dashboard.png)



