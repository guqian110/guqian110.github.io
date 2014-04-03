Title: Install ISE & ModelSim
Date: 2014-03-27 20:52
Category: FPGA
Tags: FPGA,Linux
Slug: install-ise-modelSim
Author: Chien Gu
Summary: 从 Windows 平台转移到 Linux，于是把 FPGA 的开发平台也搬过来，总结一下 ISE 的安装配置过程。

从 Windows 平台转移到 Linux，于是把 FPGA 的开发平台也搬过来。

*软件版本：*

Ubuntu 13.10 Desktop amd64 

ISE 14.7 for Linux

ModelSim 6.5b for Linux
##Download
* * *

### ISE Design Suit for Linux
Xilinx 官方网站上有[下载链接][ise-download]，但是在校园网内下载速度实在是蛋疼，还好有校内 bt 资源。

我下载下来的 ISE 版本为 **14.7**，tar 包大小为 6.5 G 。

### ModelSim for Linux

网上的教程（2011 年前）都说是 [ModelSim 官方网站][modelsim] 上提供 ftp 下载链接，但是好像现在官网上不再提供下载链接了，我只找到 ModelSim PE Student Edition，而且还是 Windows 平台的...

花费了一下午的时间，不停地在各个论坛注册下载附件，终于把 ModelSim_6.5b for Linux 下载下来了,结果安装时提示找不到 `libxp.so.6` 库，于是 `apt-get` 到一些 `libxp` 的库，安装后仍然提示找不到，无奈放弃了，准备老老实实用 `ism` 了（以后有时间了再慢慢折腾 T_T）

[ise-download]: https://secure.xilinx.com/webreg/register.do?group=dlc&htmlfile=&emailFile=&cancellink=&eFrom=&eSubject=&version=14.7&akdm=1&filename=Xilinx_ISE_DS_Lin_14.7_1015_1.tar
[modelsim]: http://www.mentor.com/products/fpga/model

<br>

##Installation
* * *

### ISE DS 14.7

首先解压

    tar -xvf Xilinx_ISE_DS_Lin_14.7_1015_1.tar

接着进入解压出来的目录并给安装文件赋予执行的权限

    cd Xilinx_ISE_DS_Lin_14.7_1015_1/
    sudo chmod +x xsetup

然后执行 xsetup

    sudo ./xsetup

然后熟悉的图形界面就出来，和 Windows 下一样，同意安装许可协议，不停地下一步就可以安装成功。

安装完成以后，运行

    cd /opt/Xilinx/14.7/ISE_DS
    source settings64.sh
    
此时，已经可以从终端运行 ISE 了

    nohup ise&

熟悉的图形界面出来了：

![ise](/images/install-ise-modelsim/ise_start.png)

P.S.

1. 选择安装版本时，选择 `System Edition`，因为这个版本功能最全

2. 选择安装组件时，不要勾选 `Install Cable Drivers`，我们自己编译安装另外一个驱动（因为此驱动只能在 Linux 内核 < 2.6的版本中使用，所以即使勾选了最后安装完成时会提示 *Driver installation failed*）

**Crack**

又到了该和谐的地方了 =.=

第一次打开 ISE 时，会自动弹出 License Management Tools 提示我们添加 License 。网上有一大堆破解包，我使用以前在 Windows 中生成的 Lincese，直接就可以使用了～

再次声明：仅供技术交流，请支持正版软件


**installing Cable Drivers**

正如前面所说，因为 ISE 自带的驱动程序依赖于一个叫 windrvr 的文件。 而该文件目前只有 Linux 内核 2.4 的二进制版本，因此遇到高于 2.4 内核的 Linux发布版，如我使用的Ubuntu 13.10（Linux version 3.11.0-12-generic ） 就不工作了。

好在一个叫 Michael Gernoth 的德国人，大公无私地写了一个 windrvr 的替代版本，并且开放源码，这样，无论碰到什么版本的内核，现场编译一个驱动并安装， 就能解决 Linux 内核版本匹配的问题。

[XILINX JTAG tools on Linux without proprietary kernel modules][JTAG]

[JTAG]: http://rmdir.de/~michael/xilinx/

所以按照说明

首先安装 usb 驱动开发包，在 64 位系统下

    sudo apt-get install libusb-dev libc6-dev-i386 fxload

接着下载驱动程序的源代码

    cd /opt/Xilinx
    sudo git clone git://git.zerfleddert.de/usb-driver

然后编译驱动程序

    cd usb-driver/
    sudo make

下载下来的源代码中有个脚本可以设置好一切，我们只需要运行脚本就 ok

    ./setup_pcusb /opt/Xilinx/14.7/ISE_DS/ISE/
    
把 Xilinx 路径添加到系统 PATH 中

    echo "PATH=\$PATH:/opt/Xilinx/13.2/ISE_DS/ISE/bin/lin64/" >> ~/.bashrc
    echo "export PATH" >> ~/.bashrc
    
这时候，写个小测试的程序，`Systhesize` -> `Implement` -> `Generate Programming File`，打开 `iMPACT`, 如图所示，可以看到已经识别出 JTAG 链上的芯片

![jtag](/images/install-ise-modelsim/jtag.png)

### ModelSim

待续...

<br>

## Configure ISE & ModelSim
* * *

### ISE

其实也没有特殊配置的地方，主要是自定义代码编辑器，目前我的主要使用的是 `sublime text 2`，正在向 `vim` 过度ing

具体步骤 Edit -> Preferences -> Editors，选择 `custom`，在右侧的 “Command line syntax” 中写自定义编辑器的执行路径

配置自定义编辑器为 vim

    gnome-terminal --maximize -x vim $1

### ModelSim
ModelSim 编译 Xilinx库，ISE 关联 ModelSim

待续...

<br>

* * *
**Reference**

[XILINX JTAG tools on Linux without proprietary kernel modules](http://rmdir.de/~michael/xilinx/)

[Xilinx JTAG Linux](http://www.george-smart.co.uk/wiki/Xilinx_JTAG_Linux)

[【Linux软件安装】Ubuntu12.04: Xilinx ISE 14.6](http://blog.csdn.net/yunz1994/article/details/12350071)

