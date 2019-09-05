---
id: ssh
title: Git 配置SSH方式
sidebar_label: Git 配置SSH方式
---

## 第一步：生成SSH Keys
1. 打开TortoiseGit下的PuttyGen;

![PuttyGen](assets/puttygen.png)

2. 在打开的窗口中点击Generate按钮，会出现绿色进度条，等下生成，生成过程中可以在多晃晃鼠标增加随机性;

![PuttyGenProcess](assets/puttygenprocess.jpg)

3. 生成之后复制生成的全部内容，窗口先留着不关闭;

![sshkey](assets/sshkey.jpg)

4. 登录到github,点击右上方的设置图表，进去设置页面之后选择左边选项中的SSH key之后点击Add SSH key在出现的界面中填写SSH key的名称，随便填写自己喜欢的即可，然后将刚刚复制的内容粘贴到key里面再点击add key就可以了

![gitkey](assets/gitkey.jpg)
![gitkey2](assets/gitkey2.png)

5. 返回到第三步的窗口，点击Save private key按钮保存为适用于TortoiseGit的私钥扩展名为.ppk;

6. 运行TortoiseGit开始菜单中的Pageant程序，程序启动后将自动停靠在任务栏中，双击该图标，弹出key管理列表;

![pageant](assets/pageant.png)  
<br> 
![pageant2](assets/pageant2.jpg)

7. 在弹出的key管理列表中点击add key,将第5步中保存的私钥（.ppk）文件加进来，关闭对话框即可;

![addkey](assets/addkey.jpg)  

8. 经上述配置后，就可以使用TortoiseGit进行push、pull操作了，不用每次都输入密码了。
