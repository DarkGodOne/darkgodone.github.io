---
id: extend
title: Openwrt 扩展根分区
sidebar_label: Openwrt 扩展根分区
---

由于项目需要，用了个x86的工控机安装openwrt系统，但是发现刷了系统后磁盘没有全部使用，感觉很浪费，最终找到了openwrt扩展根分区的方法

## 第一步：安装软件
用fdisk对openwrt分区，但是貌似有人说这个分区最大只支持4G以下，超过4G就无法分区了，最终发现cfdisk是可以的，所以用了cfdisk进行磁盘扩展
```
opkg install fdisk
opkg install cfdisk
```
## 第二步：查找根分区
使用命令查找根分区,通过df命令和fdisk命令可以判断根分区为sda2
```
root@OpenWrt:~# df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root                 5.8M      5.8M         0 100% /rom
tmpfs                     1.9G    912.0K      1.9G   0% /tmp
/dev/loop0              111.8G      2.2G    109.6G   2% /overlay
overlayfs:/overlay      111.8G      2.2G    109.6G   2% /
/dev/sda1                15.7M      4.2M     11.2M  27% /boot
/dev/sda1                15.7M      4.2M     11.2M  27% /boot
tmpfs                   512.0K         0    512.0K   0% /dev

root@OpenWrt:~# fdisk -l
Disk /dev/loop0: 111.8 GiB, 120010399744 bytes, 234395312 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

Disk /dev/sda: 111.8 GiB, 120034123776 bytes, 234441648 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x511541b3

Device     Boot Start       End   Sectors   Size Id Type
/dev/sda1  *      512     33279     32768    16M 83 Linux
/dev/sda2  *    33792 234440623 234406832 111.8G 83 Linux
```

## 第三步：扩展根分区
执行cfdisk命令，可以进入分区配置界面
![disk](assets/disk.png)

上下键然后选择sda2,左右键选择Resize，在New Size的地方输入想要扩展的大小，回车确认后再左右键选择Write即可完成分区扩展
![diskover](assets/diskover.png)

