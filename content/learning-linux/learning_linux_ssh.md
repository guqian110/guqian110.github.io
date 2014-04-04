Title: 学习 LInux SSH
Date: 2014-04-04 17:00
Category: Linux
Tags: Linux,SSH
Slug: learning_linux_ssh
Author: Chien Gu
Summary: 学习 SSH、SCP 命令，建立两台电脑相互访问 。

实验室的师兄师姐毕业了，继承了他们的新电脑 。宿舍的笔记本和实验室的电脑出现了相互之间传送同步文件的需求 。想到了两种方法：

1. 云同步
2. SSH / SCP

解决方案 1 是最省事的，也是目前最流行的，目前各大互联网公司都提供各种云服务，比如国外的 Google Drive、Dropbox，国内的百度云、360 网盘什么的。这种方案最大的有点是跨平台，不过这个方案是借助了第三方的服务器，需要连接到互联网才行，而且对网速是有一定要求的。

解决方案 2 相比于方案 1 的优势是：不是必须要连接到互联网，在局域网内也可以同步文件 。一般局域网内传输文件的速度要比连外界的服务器快很多 。

考虑到校园网的环境，明显方案 2 更加好 。

<br>

## 什么是 SSH
* * *

最早的时候，互联网通信都是明文通信，一旦被截获，内容就暴露无疑 。[SSH][SSH] 协议，将登录信息全部加密，成为互联网安全的一个基本解决方案，迅速在全世界获得推广，目前已经成为 Linux 系统的标准配置 。

最初的 SSH 协议是由芬兰的一家公司的研究员 Tatu Ylönen 于 1995 年设计开发的，但是因为受版权和加密算法等等的限制，现在很多人都转而使用 OpenSSH 。OpenSSH 是 SSH 的替代软件包，而且是开放源代码和免费的 。—— Wikipedia

关于 SSH 的原理，找到了一系列 [阮一峰][RYF]的文章，很简洁明了:

### SSH

[SSH原理与运用（一）：远程登录][blog1]

[SSH原理与运用（二）：远程操作与端口转发][blog2]

[SSH]: http://en.wikipedia.org/wiki/Secure_Shell
[RYF]: http://www.ruanyifeng.com/blog/
[blog1]: http://www.ruanyifeng.com/blog/2011/12/ssh_remote_login.html
[blog2]: http://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html

<br>

## SSH 的用法
* * *

最简单明了的教程就是 man page 了

    man ssh
内容为

    NAME
        ssh — OpenSSH SSH client (remote login program)
        
    SYNOPSIS
     ssh [-1246AaCfgKkMNnqsTtVvXxYy] [-b bind_address] [-c cipher_spec]
         [-D [bind_address:]port] [-e escape_char] [-F configfile] [-I pkcs11]
         [-i identity_file] [-L [bind_address:]port:host:hostport]
         [-l login_name] [-m mac_spec] [-O ctl_cmd] [-o option] [-p port]
         [-R [bind_address:]port:host:hostport] [-S ctl_path] [-W host:port]
         [-w local_tun[:remote_tun]] [user@]hostname [command]



进阶的书籍有：[SSH, The Secure Shell: The Definitive Guide][book1], O'reilly

目前已经有两台安装了 Ubuntu 的电脑，实验室的一台 name 是 *lab* ，宿舍的一台 name 是 *dom* ，两台电脑上都有一个用户名为 *chien* 。

**我们的目的是使两台电脑可以相互之间通过 SSH 访问。** 下面就是整个过程：

### 安装 SSH server

SSH 只是一种协议，在 Ubuntu 下，具体实现使用的是 [OpenSSH][OpenSSH] 。Ubuntu 默认是安装了 SSH 客户端 `openssh-client`，而没有安装 SSH 服务程序 `openssh-server`。

检测本机是否已经安装了 SSH server

    ssh localhost

如果结果是

    ssh: connect to host localhost port 22: Connection refused
说明 SSH server 还没有安装 。

安装方法：

    sudo apt-get install openssh-server

### 启动 SSH 服务

启动 SSH server

    sudo /etc/init.d/ssh start 

查询服务是否正确启动

    ps -e | grep ssh

返回结果应该类似于

     4156 ?        00:00:00 ssh-agent
     4606 ?        00:00:00 sshd

则说明服务已经正确启动 。

*因为两台电脑要相互访问，所以它们的角色即使 server，又是 client，所以需要在两台电脑上都执行上面两步 。*

### 远程访问

首先，查询本机 IP 地址

    ifconfig

比如 lab 的 IP 地址是 `10.105.55.155`, dom 的 IP 地址是 `10.210.111.116` 。（因为是校园网，所以分配到的都是内网地址）

然后，在宿舍用 dom 访问 lab 这台机器

    ssh chien@10.105.55.155

实际结果如下图

![login1](/images/learning-linux-ssh/login1.png)

在执行命令前，提示符显示目前的用户是在 dom 这台机器上的用户 chien，本机 home 目录下有 `dom` 文件，但是没有 `lab` 文件 。执行了登录命令以后，就会切换到以 chien 身份登录到 lab 机器，远程机器 home 目录下有 `lab` 文件，但是没有 `dom` 文件 。

同理，在实验室用 lab 访问 dom 这台机器

    ssh chien@10.210.111.116

实际结果如下图

![login2](/images/learning-linux-ssh/login2.png)

在执行命令前，提示符显示目前的用户是在 lab 这台机器上的用户 chien，本机 home 目录下有 `lab` 文件，但是没有 `dom` 文件 。执行了登录命令以后，就会切换到以 chien 身份登录到 dom 机器，远程机器 home 目录下有有 `dom` 文件，但是没有 `lab` 文件 。

### 省去 IP 地址

每次登录都需要记忆、手动输入 IP 地址，其实只需要改 `/etc/hosts` 文件，就能省去手动输入 IP 地址的烦恼。

    vim /etc/hosts

在 dom 的 hosts 文件后面添加

    lab    10.105.55.155

在 lab 的 hosts 文件后面添加

    dom     10.210.111.116

以后，登录时只需要输入

    // from dom to lab
    ssh lab
    
    // from lab to domm
    ssh dom

就可以登录了。

### 公钥登录

上一步解决了 IP 地址的问题，但是还是需要手动输入密码 。我们可以用公钥登录的方法，免去输密码的烦恼。

**首先，什么是数字签名 Digital Signature**

[数字签名是什么？][blog3]

[What is a Digital Signature?][blog4]

**其次，生成数字签名**

Ubuntu 默认安装了 `ssh-keygen`，可以生成公钥和私钥

    ssh-keygen

命令执行过程中会询问保存密钥文件的路径，还可以为密钥文件设置口令（passphrase）。运行结束以后，在 `$HOME/.ssh/` 目录下，会新生成两个文件：`id_rsa.pub` 和 `id_rsa` 。前者是你的公钥，后者是你的私钥。

**然后，发布数字签名**

使用 `ssh-copy-id` 命令可以把公钥复制到远程机器中 。

将 dom 的公钥发送到 lab 中

    ssh-copy-di chien@lab
    
将 lab 的公钥发送到 dom 中

    ssh-copy-di chien@dom

**最后，使用公钥登录**

此时，远程登录时就不再需要输入密码了

    // from dom to lab
    ssh lab
    
    // from lab to dom
    ssh dom

[OpenSSH]: http://www.openssh.com/
[book1]: http://docstore.mik.ua/orelly/networking_2ndEd/ssh/index.htm
[blog3]: http://www.ruanyifeng.com/blog/2011/08/what_is_a_digital_signature.html
[blog4]: http://www.youdzone.com/signature.html

<br>

## 使用 SCP 传输文件
* * *

SSH 提供了一些命令和 shell 用来登录远程服务器 。在默认情况下它不允许你拷贝文件,但是还是提供了一个 "scp" 命令 。scp 命令是 SSH 中最方便有用的命令了，试想，在两台服务器之间直接传送文件。仅仅用 scp 一个命令就完全解决了 。

man page

    man scp

内容为

    NAME
     scp — secure copy (remote file copy program)
     
    SYNOPSIS
     scp [-12346BCpqrv] [-c cipher] [-F ssh_config] [-i identity_file]
         [-l limit] [-o ssh_option] [-P port] [-S program]
         [[user@]host1:]file1 ... [[user@]host2:]file2

scp 可以实现把 [[user@]host1:]file1 复制到 [[user@]host2:]file2 的功能。所以

### 上传 dom 本地文件至服务器 lab

    scp ~/dom chien@lab:~/

### 下载 lab 服务器文件至本地 dom

    scp chien@lab:lab ~/

若发送文件夹则添加参数 `-r` 即可

    scp -r ~/test chien@lab:~/

<br>

至此，就实现了两台电脑的之间相互远程访问的功能 。

<br>

## Reference
* * *

[数字签名是什么？][blog1]

[What is a Digital Signature?][blog2]

[SSH原理与运用（一）：远程登录][blog3]

[SSH原理与运用（二）：远程操作与端口转发][blog4]
