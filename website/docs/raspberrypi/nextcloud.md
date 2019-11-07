---
id: nextcloud
title: 树莓派架设私有网盘--NextCloud
sidebar_label: NextCloud
---

## 安装
1. 依赖库
```
sudo apt install apache2
sudo apt install phpmyadmin php7.0-xml php7.0-curl php7.0-mcrypt
sudo apt install marriadb-server
sudo service apache2 restart
sudo service marriadb restart
```

2. 下载NextCloud软件包
[NextCloud官网](https://nextcloud.com/install/#instructions-server)
```
wget https://download.nextcloud.com/server/releases/nextcloud-17.0.0.zip
```

3. 安装到web目录
```
unzip nextcloud-17.0.0.zip
sudo mv nextcloud /var/www/html
```

4. 创建数据目录
```
sudo cd /var/www/html/nextcloud
sudo mkdir data
```

5. 修改权限
```
cd ../
sudo chown -R www-data:www-data nextcloud
```

6. 修改apache配置文件
```
sudo vim /etc/apache
```
