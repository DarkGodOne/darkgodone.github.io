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
2. 其他的软件包路径在上一级目录（这个地方之前找了好久，还以为不对，擦原来需要到上一级），在http://mirrors.ustc.edu.cn/lede/releases/18.06.4/packages 里面

## 第三步：替换Openwrt软件源
### 方法一




## Mauris In Code

```
Mauris vestibulum ullamcorper nibh, ut semper purus pulvinar ut. Donec volutpat orci sit amet mauris malesuada, non pulvinar augue aliquam. Vestibulum ultricies at urna ut suscipit. Morbi iaculis, erat at imperdiet semper, ipsum nulla sodales erat, eget tincidunt justo dui quis justo. Pellentesque dictum bibendum diam at aliquet. Sed pulvinar, dolor quis finibus ornare, eros odio facilisis erat, eu rhoncus nunc dui sed ex. Nunc gravida dui massa, sed ornare arcu tincidunt sit amet. Maecenas efficitur sapien neque, a laoreet libero feugiat ut.
```

## Nulla

Nulla facilisi. Maecenas sodales nec purus eget posuere. Sed sapien quam, pretium a risus in, porttitor dapibus erat. Sed sit amet fringilla ipsum, eget iaculis augue. Integer sollicitudin tortor quis ultricies aliquam. Suspendisse fringilla nunc in tellus cursus, at placerat tellus scelerisque. Sed tempus elit a sollicitudin rhoncus. Nulla facilisi. Morbi nec dolor dolor. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras et aliquet lectus. Pellentesque sit amet eros nisi. Quisque ac sapien in sapien congue accumsan. Nullam in posuere ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Proin lacinia leo a nibh fringilla pharetra.

## Orci

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin venenatis lectus dui, vel ultrices ante bibendum hendrerit. Aenean egestas feugiat dui id hendrerit. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Curabitur in tellus laoreet, eleifend nunc id, viverra leo. Proin vulputate non dolor vel vulputate. Curabitur pretium lobortis felis, sit amet finibus lorem suscipit ut. Sed non mollis risus. Duis sagittis, mi in euismod tincidunt, nunc mauris vestibulum urna, at euismod est elit quis erat. Phasellus accumsan vitae neque eu placerat. In elementum arcu nec tellus imperdiet, eget maximus nulla sodales. Curabitur eu sapien eget nisl sodales fermentum.

## Phasellus

Phasellus pulvinar ex id commodo imperdiet. Praesent odio nibh, sollicitudin sit amet faucibus id, placerat at metus. Donec vitae eros vitae tortor hendrerit finibus. Interdum et malesuada fames ac ante ipsum primis in faucibus. Quisque vitae purus dolor. Duis suscipit ac nulla et finibus. Phasellus ac sem sed dui dictum gravida. Phasellus eleifend vestibulum facilisis. Integer pharetra nec enim vitae mattis. Duis auctor, lectus quis condimentum bibendum, nunc dolor aliquam massa, id bibendum orci velit quis magna. Ut volutpat nulla nunc, sed interdum magna condimentum non. Sed urna metus, scelerisque vitae consectetur a, feugiat quis magna. Donec dignissim ornare nisl, eget tempor risus malesuada quis.
