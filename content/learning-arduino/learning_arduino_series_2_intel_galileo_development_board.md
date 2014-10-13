Title: 学习 Arduino #2 初识 Intel Galileo 开发板
Date: 2014-05-29 23:27
Category: Arduino
Tags: Arduino, Intel Galileo 
Slug: learing_arduino_series_2_intel_galileo_development_board
Author: Chien Gu
summary: 学习 Arduino，#2 初识 Intel Galileo 开发板

## Preface
* * *

Arduino 有很多开发板，分别针对不同的应用环境含有不同的模块。学习一款 Intel 推出的开发板 —— *Intel Galileo Development Board* 。

Intel Gailileo Development Board 是 Intel 进入 Arduino 领域的试水产品，它含有一颗 Quark Soc X1000 CPU，这是一款 32 位、x86 构架、低功耗的 SoC 芯片，它的主频可以达到 400 MHz，内部有 512 KB 的 SRAM，同时 Galileo 有丰富的接口(USB, JTag, RS232, Ethernet, mPCIE...)，支持很多外围设备。

Galileo 试图达到的目标是融合 Arduino 对硬件操作的便利和 Linux 系统对硬件操作完整支持。所以，Galileo 也兼容 Arduino 接口，你可以很方便的把 Arduino 项目移植到 Galileo 上运行，使用常用的一些 Arduino 库(Ethernet, Wi-Fi, SD, EEPROM...)也可以获得内部 Linux 系统的完整功能(Python, SSH, Telnet， OpenCV...)。

总结一下我学习这块板子的知识，不仅仅为 Arduino 开发做准备，也为后面的一个竞赛(基于Yocto 项目)开发积累知识～

<br>

## Official Arduino Boards
* * *

Arduino 官网上列出所有了官方开发板，其中也包含了官方认证过的开发板(Intel Galileo)，和一些推荐的第三方产品

[Arduino Products][products]

还详细列出了这些开发板上的微控制器的区别

[Compare boards specs][compare]

[compare]: http://arduino.cc/en/Products.Compare
[products]: http://arduino.cc/en/Main/Products

<br>

*官方的开发板的核心都是 Atmel 的微控制器，基于市场战略的需求，看到数莓派、Arduino发展的热火朝天，Intel 也坐不住了(瞎猜的 =.=)，推出了新的基于 Intel 架构(x86)、可以和 Arduino 兼容的开发板。Galileo 是这个家族中的第一款，目前 Intel 又推出了一款新的开发板，取名叫 Edison。(Intel 这是要把所有科学家的名字都取个遍么)*

<br>

## Intel Galileo Board
* * *

### Arduinco.cc

在 Arduino 官网上有一篇简单介绍 Galileo 的网页

[Intel Galileo on arduino.cc][galileo on arduino.cc]

### Intel Official Introduction

Arduino 官网上的介绍只是非常简单的介绍，Intel 自己的官网上有关于 Galileo 全部的详细资料

[Galileo Maker Quark Board][galileo on intel]

关于 Galileo 的全部文档，包括 Datasheet、Schematic、Quick Start、User Guide 等：

[Intel Galileo Development Board Documents][galileo documents]

### Other Introductions 

**首先** 送上一篇非常好的介绍文章（来自 Ifanr.com），介绍了在 Maker 眼中，这个板子到底可以 hack 到什么程度～

[x86 版的 Arduino 来了，Intel Galileo 开发板的体验、分析和应用【超长文多图】][galileo on ifanr]

**再** 附上一篇完爆我的总结的教程～

[Galileo Getting Started Guide][Galileo Getting Started Guide]

这篇教程基本就是按照 Intel 官方的 Getting Started 流程写的，总结一下我遇到的问题 (Windows 7 & Linux Ubuntu)。

Arduino 官方的 IDE 中 `Board` 选项中没有 Galileo，所以我们应该从 Intel 下载定制过的 IDE。

1. Windows IDE 闪退

    这个 IDE 在部分 Windows 下有闪退的现象。
    
    原因 是 Intel 的 IDE 版本采用的是未发布的 1.5.3, 它会检测系统的语言设置，当系统不是 En/US 时，就会退出。
    
    解决方法 更改系统语言设置 或者 使用一款名为 Locale Emulator 的软件。
    
2. IDE 解压路径

    Windows 下的解压路径 *必须是顶层目录*，比如 `D:\arduino-1.5.3`，否则在 `Verify` 时会提示找不到特定的文件/目录。Linux 下无此问题。
    
3. Linux 连接板子和 PC

    在 Windows 下第一次连接系统自动安装驱动肯定会失败的，需要我们手动指定驱动文件的路径。
    
    在 Linux 终端下，必须以 `sudo` 权限运行 IDE，否则即使板子已经连接了 PC，在 IDE 下的 `Tools\Serial Port` 是 disable 的，不能选择端口
    
        #!Shell
        $ sudo ./arduino &
        
4. Linux 下 disable modem manager

    前面的教程中提到，在大多数 Linux 发行版下，都需要 disable modem manager 才能 `Upload` 成功，不过我在 Ubuntu 下没有遇到这个问题...
    
**然后** 扯几句

1. 硬件配置

    从 Board Guide 中找到的截图如下
    
    ![key_componets_1](/images/learning-arduino-series-2-intel-galileo-development-board/key_components_1.png)

    ![key_componets_2](/images/learning-arduino-series-2-intel-galileo-development-board/key_components_2.png)

    从它的配置中可以看到，Galileo 并不是一款简单的 Arduino 开发板，它的硬件系统其实是按照 PC 来设计的，如果我们只是简单的把它当作 Arduino 开发板来应用，有点大材小用了，这样子完全没有体现出 Galileo 的优势，只是一个速度更快的 Arduino 罢了。
    
    事实上，如果功能上没有比传统的 Arduino 更强大的功能，估计 Intel 也不会推出这个产品了～Galileo 的真正强大的地方在于：

    > 背后基于 UEFI/Linux 的软件平台以及 Galileo 自身的硬件配置。为此，Intel 提供了丰富的开发文档、软件代码支持，方便开发人员真正的发挥出 Galileo 的所有潜力。
    
2. 软件构架

    Galileo 不仅仅是硬件上按照 PC 设计的，事实上，它的软件构架也和 PC 一样。和普通的单片机不同，它并不是简单的运行用户开发的程序那么简单。它实际上运行着一个操作系统 —— 包含 UEFI(BIOS 的替代者)、Grub、嵌入式 Linux 系统，用户编写的 `Sketch` 只是一个在 Linux 上面运行的应用而已。
    
    Galileo 启动时可以从 ISP Flash 中启动一个微型的 Linux 系统，也可以从 MicroSD 卡中启动一个完整版的 Linux 系统。我们 `Upload` 时，Arduino IDE 将程序编译链接成一个标准的 Linux ELF 文件，并且下载到 Arduino 板子上运行，如图所示
    
    ![target_software](/images/learning-arduino-series-2-intel-galileo-development-board/target_software.png)
    
3. 开发嵌入式 Linux 设备

    或许这才是 Galileo 的 "正经" 用途吧...基于 Yocto Project，我们可以开发属于自己的 Linux 系统。

最后，送上一个别人的 Galileo 开箱视频

<embed src="http://player.youku.com/player.php/sid/XNjQ0NTMzMjYw/v.swf" allowFullScreen="true" quality="high" width="480" height="400" align="middle" allowScriptAccess="always" type="application/x-shockwave-flash"></embed>

[galileo on arduino.cc]: http://arduino.cc/en/ArduinoCertified/IntelGalileo
[galileo on intel]: http://www.intel.cn/content/www/cn/zh/do-it-yourself/galileo-maker-quark-board.html
[galileo documents]: https://communities.intel.com/community/makers/documentation/galileodocuments
[Galileo Getting Started Guide]: https://learn.sparkfun.com/tutorials/galileo-getting-started-guide
[galileo on ifanr]: http://www.ifanr.com/388835

