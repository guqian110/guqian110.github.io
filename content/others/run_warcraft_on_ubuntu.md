Title: 在 Ubuntu 下运行 WarCraft
Date: 2014-04-10 10:58
Category: Others
Tags: Wine,WarCraft 
Slug: run_warcraft_on_ubuntu
Author: Chien Gu
Summary: 闲来无聊，在 Ubuntu 下 wine 了一个 WarCraft 3 玩

闲来无聊，在 Ubuntu 下 wine 了一个 WarCraft 3 玩

在实验室的 ”老爷车“ 电脑上运行。稍微有一点卡，在5年前买的笔记本（core 2 T6600, 4G RAM）上运行就感觉不到卡了 。

实验室电脑配置：

Processor: Pentium(R) Dual-Core CPU E5200 @ 2.50GHz × 2 

Graphics: Gallium 0.4 on NV86

Memory: 2.0 GiB

OS type: 32-bit

<br>

## 安装 Wine
* * *

[Wine][wine] 是 wine is not an emulator 的缩写，它可以在 x86、x86-64 上容许类 Unix 操作系统在 X Window System 下运行 Microsoft Windows 程序的软件 .它的官方网址：http://www.winehq.org/

方法一：

Ubuntu 软件仓里搜索 Wine，就可以找到 `Wine Windows Program Loader`，直接安装即可

方法二：

使用 `apt-get`

    apt-cache search wine
    suod apt-get install wine

P.S. 若是其他系统，找不到对应的二进制包，可以直接从官网上下载源码，自己编译（官网上有详细的 [FAQ][FAQ]）

[wine]: http://en.wikipedia.org/wiki/Wine_(software)
[FAQ]: http://wiki.winehq.org/FAQ_zhcn

<br>

## 拷贝 WarCraft
* * *

如果是双系统，则不必拷贝 WarCraft 文件夹，因为我电脑上只有 Ubuntu，所以从同学那里拷贝了一个，放在了 `～/` 目录下 。

<br>

## 配置 Wine & WarCraft
* * *

### CD key 注册表问题

直接以 wine 运行 `war3.exe` 时提示没有 CD key，在 WarCraft 目录下找到了两个注册表文件，`War3.reg` 和 `一键导入.reg` 。

在终端下导入注册表

    wine regedit

然后导入这两个文件，再次尝试，还是不行...

不急，游戏目录下还有一个程序叫 `War3RegFixer.exe`，看名字就知道是我们需要的

    wine War3RegFixer.exe
    
因为我的 Ubuntu 是英文版的，打开后是乱码...

![war3regfixer](/images/run-warcraft-on-ubuntu/war3regfixer.png)

找了一台 Windows 电脑，运行了一下，按照向导就可以修复 CD key 的问题 。

### 分辨率问题

第一次运行的结果一般不会全屏，处女座的强迫症犯了，还好比较简单 ：D

    wine regedit

找到 `HKEY_CURRENT_USER/Software/Blizzard Entertainment/Warcraft III/Video`，里面有两个注册表值 `resheight` 和 `reswidth`，将他们设为和当前分辨率相同的十进制数值就可以了。

### 画面卡

因为 Wine 对 DirectX 的支持还不够好，如果电脑配置比较低，运行的时候添加参数 `-opengl` 就可以了，为了避免每次运行都要输入参数，可以在注册表 `HKEY_CURRENT_USER/Software/Blizzard Entertainment/Warcraft III/` 下新建整数（DWORD），名为 `Gfx OpenGL`，值为 1 。

<br>

## 运行

### 终端下

现在就可以在终端下运行 war3.exe 了

    wine war3.exe

熟悉的画面就出来了～

这样子运行如果切出游戏，有时会导致 war3 崩溃或者切换不出去。一个解决方法是以窗口模式运行，只需要添加参数 `-window` 即可

    wine war3.exe -window

效果如下

![war3window](/images/run-warcraft-on-ubuntu/war3window.png)

不过个人不是很喜欢，因为鼠标总是超出窗口，及其不方便，影响游戏操作和感受 ：D


### 桌面启动器

我们可以为 war3 添加一个桌面启动器，这样就不用进入终端启动了

新建文件 `frozen-throne.desktop` 文件，添加以下内容

    [Desktop Entry]
    Version = 1.0
    Name = Frozen Throne
    Exec = /home/chien/WarCraft/war3.exe
    Terminal = false
    Icon = /home/chien/WarCraft/war3.jpg
    Type = Application

然后把这个文件移动到 `/usr/share/applicants/` ，这时在 unity 中搜索 `froz`，就能看到我们刚才新建的启动器了～

![war3desktop](/images/run-warcraft-on-ubuntu/war3desktop.png)

<br>

至此，就可以在 Ubuntu 下享受 War3 了

gl hf！

<br>

## 参考

[用Wine运行魔兽争霸III](http://linux-wiki.cn/wiki/zh-hans/%E7%94%A8Wine%E8%BF%90%E8%A1%8C%E9%AD%94%E5%85%BD%E4%BA%89%E9%9C%B8III)

[Wine 魔兽争霸3的一些设置](http://blog.ubuntusoft.com/wine-warcraft-3.html#.U0Xt11SSx38)

[Wine魔兽争霸3，流畅运行+键盘操作+窗口化](http://hi.baidu.com/chenwzox/item/4e6346f1575a7ab231c199b4)
