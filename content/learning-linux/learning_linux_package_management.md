Title: 学习 Linux 软件包依赖管理 
Date: 2014-04-21 13:43
Category: Linux
Tags: Linux,Package Management
Slug: learning_linux_package_management
Author: Chien Gu
Summary: 安装软件时遇到依赖库版本过高的问题，学习总结 Linux 软件包管理 。

## Linux 软件包依赖问题
* * *

早期的 Linux 系统上的软件是通过源码方式发布的，大家下载下来，在自己的机器上编译，得到可执行程序 。

但是，任何程序员写程序都有可能会依赖一些别人已经写成的库，所以几乎一定规模的程序必然有依赖 。尤其是对于 Linux 系统，因为它是 **free（自由，not 免费）**，开源软件的开发者不是在一个体系下，软件包的依赖关系就比较伤脑筋了， 尤其是当我们的系统里有成百上千的软件时，软件包管理的必要性就更明显了 。

*比如我们需要安装 package_a，而 package_a  依赖于 package_b 才能运行，但是我们的系统没有安装 package_b，如果强制安装 package_a，软件很可能不能正常运行 。*

**P.S.**  其实在 Windows 下也存在相似的问题，只是因为有微软统一的体系，很多 `dll` 被集成在系统中，所以这个问题不明显 。

不同的系统对于这个问题有不同的处理方法，这也体现出它们不同的处理问题的哲学：

知乎上的问题：[Unix 的包依赖是如何形成的？][question1]

有个回答：

> GNU/Linux：通常这个系统大多数软件是自由软件，换句话说，他们通常依赖的库也是自由的，所以软件开发者认为你可以自由的获取这些依赖库，自然就不需要自己再提供了。由系统“发行版”负责维护属于这个系统的所有依赖库，并且安装软件时确定依赖。
> <br>
> 这个体系的特点是：
> <br>
>   + 系统依赖通常是统一的，如果有多个程序依赖同一个库，在这个系统中通常是同一份。
> <br>
>   + 具有庞大的资源。例如 Debian 系现成的可依赖软件多达 30G，所以通常不可能预先把所有依赖都安装全，但庞大的依赖库给编程人员提供了很多方便。
> <br>
>   + 你安装的软件越多，共同依赖所体现出的价值越高，解决依赖问题就越简单（因为当你安装足够多软件时，主流的依赖已经全部在你系统了）。
> <br>
>   + 由于巨大的共同依赖库存在，软件本身可以很小.
> <br>
> Windows：通常而言，这个系统的软件是商业软件，因此，他们依赖的库也很有可能是商业软件，所以，不可能要求用户自行获取这些依赖，这些依赖通常在发布软件的时候提供。如果你安装的软件少，这个体系很方便。
> <br>
> 不过这造成了一些缺点：
> <br>
>   + 没有一个庞大的公共库，很多功能以及基础库都是每个公司自己实现一套，浪费很多劳动力，编程人员到每个公司得学习一套不同的库，给编程人员带来不便。
> <br>
>   + 所有应用程序都自己带依赖，因此很可能有许多程序同时附带了相同的依赖，并且这些相同依赖还有可能是不同的版本，这会造成许多混乱。
> <br>
>   + 由于所有应用程序都自己提供所有依赖，每个软件体积都很庞大。
> <br>
>   + 系统中安装的软件越多，越容易出问题。
> <br>

[question1]: http://www.zhihu.com/question/20443067

<br>

## Linux 包管理系统
* * *

[Package management system on wikipedia][PMS]:

> A **package management system**, also called **package manager**, is a collection of software tools to automate the process of installing, upgrading, configuring, and removing software packages for a computer's operating system in a consistent manner. It typically maintains a database of software dependencies and version information to prevent software mismatches and missing prerequisites.
> <br>
> <br>
> Package management systems are designed to save organizations time and money through remote administration and software distribution technology that eliminate the need for manual installs and updates. This can be particularly useful for large enterprises whose operating systems are based on Linux and other Unix-like systems, typically consisting of hundreds or even thousands of distinct software packages; in the former case, a package management system is a convenience, in the latter case it becomes essential.

在 Linux 发行版中，几乎每一个发行版都有自己的软件包管理系统 。

### Dpkg

[Dpkg on wiki][dpkg]

Dpkg 是基于 Debian 系统的包管理软件 。`dpg` 可以用来安装、删除、提供`.deb` 格式软件包相关信息的文件 。

dpkg 由 Matt Welsh、Carl Streeter、 Ian Murdock 用 Perl 语言编写，后来在 1994 年。 Ian Jackson 改用 C 重写了大部分内容 。

dpkg 是 “Debian package” 的缩写，它最初是为 Debian 系统编写的，也可以在使用 `.deb` 格式的 Ubuntu 系统上使用 。

#### 常用语法

    dpkg -i peackage.deb        // install
    dpkg -r package.deb         // remove
    dpkg -l [optional pattern]  // list installed package
    dpkg --configure package    // configure package

#### 详细用法

    dpkg --help
    man dpkg

### Apt

[Advanced Packaging Tool on wiki][apt]

> The Advanced Packaging Tool, or APT, is a free software user interface that works with core libraries to handle the installation and removal of software on the Debian GNU/Linux distribution and its variants. APT simplifies the process of managing software on Unix-like computer systems by automating the retrieval, configuration and installation of software packages, either from precompiled files or by compiling source code.

apt 最初是设计为 dpkg 的前端，用来处理 `.deb` 格式的文件，后来它被 `APT-RPM` 组织改造可以支持 RPM 包管理系统 。

apt 由 `apt-get`、`apt-cache` 和 `apt-config` 等小工具组成

#### 常用语法

    apt-get install package             // install
    apt-get remove package              // remove
    apt-cache search package            // search
    apt-get update                      // update source list
    apt-get upgrade                     // upgrade installed software

#### 详细用法

    man apt
    man apt-get
    man apt-update
    man apt-upgrade
    
#### 彩蛋

+ 在 terminal 中输入 `apt-get -h`

    help 内容结束的最后一样会有一句：

    > This APT has Super Cow Powers.

+ 在 terminal 中输入 `apt-get moo`

    会显示一头牛 :-P
        
>               (__) 
>               (oo) 
>         /------\/ 
>        / |    ||   
>       *  /\---/\ 
>          ~~   ~~   
>        ...."Have you mooed today?"...

### Aptitude

[aptitude on wiki][aptitude]

> aptitude is a front-end to the Advanced Packaging Tool (APT). It displays a list of software packages and allows the user to interactively pick packages to install or remove. It has an especially powerful search system utilizing flexible search patterns. It was initially created for Debian, but has appeared in RPM Package Manager (RPM) based distributions as well (such as Conectiva).

aptitude 是 APT 的文本界面客户端，它的交互性比 apt 好，似乎在处理依赖问题上也更好一些（我遇到的问题，用 aptitude 可以很方便地解决而 apt 不行 ）

#### 常用语法

    aptitude install package
    aptitude remove package
    aptitude clean
    aptitude search package
    aptitude show string
    aptitude update
    aptitude dist-update

#### 详细用法

    man aptitude
    aptitude -h

#### 彩蛋

![aptitude](/images/learning-linux-package-management/aptitude.png)

### YUM

[Yellowdog Updater, Modified on wiki][yum]

> The Yellowdog Updater, Modified (yum) is an open-source command-line package-management utility for Linux operating systems using the RPM Package Manager. Though yum has a command-line interface, several other tools provide graphical user interfaces to yum functionality.

YUM 是一个基于 RPM 包管理的字符前端软件包管理器。能够从指定的服务器自动下载 RPM 包并且安装，可以处理依赖性关系，并且一次安装所有依赖的软件包，无须繁琐地一次次下载、安装 。被 Yellow Dog Linux 本身，以及 Fedora、Red Hat Enterprise Linux 采用 。

[PMS]: http://en.wikipedia.org/wiki/Package_management_system
[dpkg]: http://en.wikipedia.org/wiki/Dpkg
[apt]: http://en.wikipedia.org/wiki/Advanced_Packaging_Tool
[aptitude]: http://en.wikipedia.org/wiki/Aptitude_(software)
[yum]: http://zh.wikipedia.org/wiki/Yum

<br>

## 举个栗子
* * *

有些软件要求的库的版本高于(>=)xx.xxx，有些软件要求库的版本必须是(=)xx.xxx，如果我们的库不能满足要求则无法安装软件 。一般 `apt-get` 会处理比较简单的依赖关系，但是有些依赖关系 `apt-get` 并不能解决 。这时候可以试试 `aptitude` 。

### 问题

为新安装的 Ubuntu 安装开发环境时，遇到了库版本过高的问题，执行下面的命令

    sudo apt-get install build-essential

结果 apt-get 提示有不满足依赖关系的包

> Reading package lists... Done
> <br>
> Building dependency tree
> <br>
> Reading state information... Done
> <br>
> Some packages could not be installed. This may mean that you have
> <br>
> requested an impossible situation or if you are using the unstable
> <br>
> distribution that some required packages have not yet been created
> <br>
> or been moved out of Incoming.
> <br>
> The following information may help to resolve the situation:
> <br>
> <br>
> The following packages have unmet dependencies:
> <br>
> **build-essential : Depends: dpkg-dev (>= 1.13.5) but it is not going to be installed**
> <br>
> E: Unable to correct problems, you have held broken packages.

于是我们手动安装特定的库

    sudo apt-get install dpkg-dev
    
结果提示我们库版本过高

> Reading package lists... Done
> <br>
> Building dependency tree
> <br>
> Reading state information... Done
> <br>
> Some packages could not be installed. This may mean that you have
> <br>
> requested an impossible situation or if you are using the unstable
> <br>
> distribution that some required packages have not yet been created
> <br>
> or been moved out of Incoming.
> <br>
> The following information may help to resolve the situation:
> <br>
> <br>
> The following packages have unmet dependencies:
> <br>
>  **dpkg-dev : Depends: libdpkg-perl (= 1.16.10ubuntu1) but 1.16.12ubuntu1 is to be installed**
> <br>
> Recommends: build-essential but it is not going to be installed
> <br>
>            Recommends: fakeroot but it is not going to be installed
> <br>
>            Recommends: libalgorithm-merge-perl but it is not going to be installed
> <br>
> E: Unable to correct problems, you have held broken packages.

### 解决问题 —— 使用 `aptitude`

**解决方法就是降级** 。

方法有两个：

1. apt-get 直接指定安装特定的版本

    首先查询是否提供低版本的包

        apt-cache showpkg package_name
    
    若有则指定安装某个版本
    
        sudo apt-get install package_name=version

2. 使用 aptitude 自动处理

我采用的第二种方法：

    sudo aptitude install build-essential

结果如下

> The following NEW packages will be installed:
> <br>
>  build-essential dpkg-dev{ab} 
> <br>
> The following packages are RECOMMENDED but will NOT be installed:
> <br>
> fakeroot libalgorithm-merge-perl 
> <br>
> 0 packages upgraded, 2 newly installed, 0 to remove and 18 not upgraded.
> <br>
> Need to get 718 kB of archives. After unpacking 1,636 kB will be used.
> <br>
> The following packages have unmet dependencies:
> <br>
>  dpkg-dev : Depends: libdpkg-perl (= 1.16.10ubuntu1) but 1.16.12ubuntu1 is installed.
> <br>
> The following actions will resolve these dependencies:
> <br>
> <br>
> Keep the following packages at their current version:
> <br>
> 1)     build-essential [Not Installed]
> <br>
> 2)     dpkg-dev [Not Installed]
> <br>
> <br>
> Accept this solution? [Y/n/q/?]

当然不是中止安装，选择 `n`， aptitude 给出另外一个解决方案：

> The following actions will resolve these dependencies:
> <br>
>  Downgrade the following packages:
> <br>
> <br>
> 1)     libdpkg-perl [1.16.12ubuntu1 (now) -> 1.16.10ubuntu1 (raring)]
> <br>
> <br>
> Accept this solution? [Y/n/q/?]

这正是我们需要解决的版本过高的问题，将库软件版本降级

> The following packages will be DOWNGRADED:
> <br>
> libdpkg-perl 
> <br>
> The following NEW packages will be installed:
> <br>
>  build-essential dpkg-dev{a} 
> <br>
> The following packages are RECOMMENDED but will NOT be installed:
> <br>
> fakeroot libalgorithm-merge-perl 
> <br>
> 0 packages upgraded, 2 newly installed, 1 downgraded, 0 to remove and 18 not upgraded.
> <br>
> Need to get 904 kB of archives. After unpacking 1,632 kB will be used.
> <br>
> Do you want to continue? [Y/n/?] 

选择 `y`。然后 aptitude 会完成剩余的工作 。

问题解决啦！

<br>

## 参考

[Unix 的包依赖是如何形成的？](http://www.zhihu.com/question/20443067)

[apt-get install安装软件问题(安装包的依赖库版本过高问题)](http://daway320.blog.163.com/blog/static/3878369920107331733393/)
