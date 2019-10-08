---
id: webcloud
title: Centos7上搭建wordpress+lighttpd+php+sqlite轻量级博客
sidebar_label: Centos7上搭建wordpress+lighttpd+php+sqlite轻量级博客
---

## 第一步:安装php
由于wordpress要求php最低版本为5.6.20以上，而Centos7默认yum安装的是5.4版本，所以只能通过源码安装：
### 首先安装依赖包
```
yum  install  -y  epel-release
yum install openssl openssl-devel libxml2-devel libxml2 bzip2 bzip2-devel curl-devel php-mcrypt libmcrypt libmcrypt-devel readline-devel
``` 
### 然后安装php
```
1. rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
2. yum install -y --enablerepo=remi --enablerepo=remi-php56 php php-opcache php-devel php-mbstring php-mcrypt php-mysqlnd php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof php-fpm php-bcmath
```
### 测试php版本
```
php -v
```
### 修改/etc/php-fpm.conf
user = lighttpd
group = lighttpd

### 启动php-fpm
systemctl start php-fpm.service
systemctl enable php-fpm.service

## 第二步：安装lighttpd
```
yum  install  -y  epel-release
yum install lighttpd
```

### 配置lighttpd
1. 编辑 modules.conf文件修改路径到wordpress位置，关闭ipv6,去掉"mod_auth"前的#号和 include "conf.d/status.conf"前的#号,去掉include "conf.d/fastcgi.conf前的#号
```
var.server_root = "/var/www/wordpress"
server.use-ipv6 = "disable"
server.document-root = server_root

index-file.names += (
  "index.php","index.xhtml", "index.html", "index.htm", "default.htm"
)

server.modules = (
  "mod_access",
#  "mod_alias",
#  "mod_auth",
#  "mod_authn_file",
#  "mod_evasive",
#  "mod_redirect",
#  "mod_rewrite",
#  "mod_setenv",
#  "mod_usertrack",
)

##
## mod_status
##
include "conf.d/status.conf"
##
include "conf.d/fastcgi.conf
```
2. 编辑status.conf文件，将127.0.0.0/8改成本地需要访问的地址。
```
$HTTP["remoteip"] == "192.168.1.0/24" {
```

3. 修改/etc/lighttpd/conf.d/fastcgi.conf,在最后增加
```
fastcgi.server += ( ".php" =>
((
"host" => "127.0.0.1",
"port" => "9000",
"broken-scriptfilename" => "enable"
))
)
```

### 启动php-fpm
```
systemctl start lighttpd
systemctl enable lighttpd
```

## 第三步：安装sqlite
```
yum install sqlite
yum install sqlite-devel
```

## 第四步：安装wordpress
```
wget https://cn.wordpress.org/latest-zh_CN.tar.gz
tar xvzf wordpress-xxx.tar.gz
```
### 安装sqlite插件
```
wget https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip
unzip *.zip
mv sqlite-integration wordpress/wp-content/plugins
cp wordpress/wp-content/plugins/sqlite-integration/db.php wordpress/wp-content/
cp wordpress/wp-config-sample.php wordpress/wp-config.php
```

### 修改配置文件wp-config.php
```
/** WordPress数据库的名称 */
define('DB_NAME', 'wordpressDB');

/** MySQL数据库用户名 */
define('DB_USER', '');

/** MySQL数据库密码 */
define('DB_PASSWORD', '');

/** MySQL主机 */
define('DB_HOST', 'localhost');

/** 创建数据表时默认的文字编码 */
define('DB_CHARSET', 'utf8');

/** 数据库整理类型。如不确定请勿更改 */
define('DB_COLLATE', '');

//define('WP_ALLOW_REPAIR', true);//数据库修复时使用
define('DB_TYPE', 'sqlite');    //mysql or sqlite`

define('DB_FILE', 'wordpressDB');
define('DB_DIR', '/var/www/html/');
define('USE_MYSQL', false);
```
### 将wordpress拷贝到web服务目录
```
mv wordpress /var/www
```

然后访问一下试试吧

