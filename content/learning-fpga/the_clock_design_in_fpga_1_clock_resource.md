Title: FPGA 时钟设计 1 —— 时钟资源总结
Date: 2014-08-28 22:45
Category: FPGA
Tags: FPGA,clock resource
Slug: the_clock_design_fpga_1_summary_of_clock_resource
Author: Chien Gu
Summary: 总结 Xilinx FPGA 中的时钟资源

关于一款芯片，最权威、最新的资料当然是厂家的官方文件。很多大牛都推荐直接阅读原厂的 datasheet 和 user guide。根据我的体验，这确实是最好的途径。原因有两个：

+ 首先，市面上的书一般都落后业界的步伐，我们看到的很多书上的资料都是过时的。

+ 其次，市面上书（尤其是国内）很多都是简单的翻译手册而来的，而且虽然作者标的是某某大学的教授，事实上都是教授手下的研究生替老师干活翻译的，不能保证翻译的正确性。

实验室有的芯片是 Xilinx 的 Virtex-5 系列，Virtex-5 的 User Guide 是 [UG190][ug190]，以下内容都是从中摘抄的笔记。

[ug190]: http://www.xilinx.com/support/documentation/user_guides/ug190.pdf

<br>

## Three Types of clock resource
* * *

### Global Clocks

+ 为了时钟目的，每个 Virtex-5 系列的器件内部都被分成不同的区域（regions），随着器件的尺寸不同，最小的有 8 个区域，最大的有 24 个区域。

+ 全局时钟资源（Global I/O）和局部时钟资源可以完成所有的复杂的/简单的时钟要求。

+ 不推荐使用其他的非时钟资源（比如局部布线资源）来完成时钟功能。

+ 每个 Virtex-5 系列的器件都有 32 条全局时钟线 （global clock line），可以驱动片上的所有时序资源（CLB、BRAM、CMTs、I/O），也可以驱动其他的逻辑信号。

+ 这些全局时钟线可以用在任何一个区域中。

+ 全局时钟线只能由全局时钟缓冲器（global clock buffer）驱动。

+ 全局时钟缓冲器一般由时钟管理块（Clock Management Tile, CMT）驱动，以减少时钟布线延时或者调整和另外一个时钟的相对延时。

+ 全局时钟的个数比 CMTs 多，但是一个 CMT 可以驱动多个全局时钟。

### Regional Clocks

+ 每个区域（region）含有 2 个局部时钟缓冲器（regional clock buffer）和 4 个局部时钟树（regional clock tree）。

+ 除了处于芯片中心列的组（bank）外，一个 Virtex -5 I/O bank 恰好横跨一个区域。大小和区域完全相同的每个组含有 4 个 clock-capable 的时钟输入。

+ 每个输入可以差分驱动或单端驱动同一组或区域中的四个 I/O 时
钟（I/O clocks）和两个区域时钟（regional clock）。

### I/O clocks

+ 第三种时钟资源是 I/O clocks，可以达到非常高的速度，用于局部的 I/O 串行器/解串器。
<br>

## Global Clocking Resources
* * *

+ 全局时钟（global clocks）是个专用网络，是专为覆盖对 FPGA 中各种资源的所有时钟输入设计的。

+ 全局时钟资源包括

	+ Global Clock Inputs
	
    + Global Clock Buffers
	
    + Clock Tree and Nets-GCLK
	
    + Clock Regions

#### Global Clock Inputs

+ Virtex-5 FPGA 包含专用的全局时钟输入位置，这些输入位置即使不用作时钟输入，也可用作常规用户 I/O。

+ 每个器件有 20 个全局时钟输入。

+ 时钟输入可以按任意 I/O 标准配置，包括差分 I/O 标准。每个时钟输入可以是单端输入，也可以是差分输入。

+ **Global Clock Input Buffer Primitives**
    
    + IBUFG，单端输入全局缓冲
    
    + IBUFGDS，差分输入全局缓冲

#### Global Clock Buffers

+ 每个 Virtex-5 器件有 32 个全局时钟缓冲器。

+ 每半个晶片 （上半 / 下半）包含 16 个全局时钟缓冲器。

+ 全局时钟缓冲器允许各种时钟源 / 信号源接入全局时钟树和网。可以输入全局时钟缓冲器的源包括：

    + Global clock inputs
    
    + Clock Management Tile (CMT) outputs including:
    
        + Digital Clock Managers (DCMs)
    
        + Phase-Locked Loops (PLLs)
    
    + Other global clock buffer outputs
    
    + General interconnect

+ 全局时钟缓冲器只能由同半个晶片 （上半 / 下半）中的源驱动。

+ 但是，在一个时钟区域中仅能驱动十个不同的时钟。

+ 一个时钟区域 （20 个 CLB）是由上十个 CLB 行和下十个 CLB 行组成的时钟树的一个
枝。

+ 一个时钟区域仅横跨器件的一半。

+ **Global Clock Buffer Primitives**
    
    + BUFGCTRL、BUFG、BUFGCE、BUFGCE_1、BUFGMUX、BUFGMUX_1、BUFGMUX_CTRL
    
    + 其他所有原语均出自 **BUFGCTRL** 的软件预设置。
    
    + **BUFG** 全局缓冲
    
    + **BUFGCE** 带有时钟使能（CE）的全局缓冲（BUFG）
    
    + **BUFGMUX** 全局时钟选择缓冲
    
    + **BUFGP** = IBUFG + BUFG
    
    + **BUFGDLL** 全局缓冲延迟锁相环（舍，被 DCM 代替）

#### Clock Tree and Nets - GCLK

+ Virtex-5 时钟树是为低歪斜和低功耗操作设计的。

+ 任何未用分枝都不连接。

+ 当所有逻辑资源都使用时，时钟树还管理负载 / 扇出。

+ 所有全局时钟线和缓冲器都以差分形式实现，这有助于大大改善占空比和共模噪声抑制能力

+ 在 Virtex-5 架构中，全局时钟线的引脚接入不仅限于逻辑资源的时钟引脚。全局时钟线不用局部互连即可接入 CLB 中的其他引脚。

#### Clock Regions

+ Virtex-5 器件通过使用时钟区域改善时钟控制分配。

+ 每个时钟区域最多可有十个全局时钟域。

+ 这十个全局时钟可以由 32 个全局时钟缓冲器的任意组合驱动。

### How to use global clock

Xilinx 芯片全局时钟资源的使用方法主要有 5 种：

1. **IBUFG + BUFG**

    最基本的全局时钟资源使用方法，也称为 “ BUFGP 法 ”
    
2. **IBUFGDS + BUFG**

    当时钟信号为差分形式时，需要用 IBUFGDS 代替 IBUFG
    
3. **IBUFG + DCM + BUFG**

    最灵活的使用方法（一般外部提供的时钟都需要倍频、分频、移相等操作以后才可以使用，所以中间需要 DCM）
    
4. **Logic + BUFG**

    BUFG 的输入可以是普通信号，当某个信号（时钟、使能、快速路径）的扇出非常大、要求抖动延迟最小时，可以使用 BUFG 来驱动这个信号，使这个信号利用全局时钟资源。
    
5. **Logic + DCM + BUFG**

    DCM 的输入也可以是普通信号，所以上面的例子中的信号需要倍频、分频等操作时，需要在中间添加 DCM 。
    
在具体使用这些组合方式时，有两种例化方式：

1. 在设计中直接例化全局时钟资源

    比较简单，按照需求例化上面 5 种组合方式即可。
    
2. 在综合阶段/实现阶段通过约束文件的方式实现

    随着综合工具/布局布线工具的不同而变化，大多数综合工具会自动分析时钟信号的扇出数目，在全局时钟资源富裕的情况下，使扇出数目最大的信号自动指定使用全局时钟资源。这时候我们必须保证满足下面的原则，否则会报错。如果不能满足，则必须在约束文件中明确声明该信号不使用全局时钟资源。
    
        NET "CLK" CLOCK_DEDICATED_ROUTE = FALSE;

### Principle in Using global clock

**原则：** 使用 IBUFG / IBUFGDS 的必要条件是信号从全局时钟引脚输入。

也就是说，如果某个信号从全局时钟引脚输入，不管它是否为时钟信号，必须使用 IBUFG/IBUFGDS；如果对某个信号使用了 IBUFG/IBUFGDS，则这个信号必须从全局时钟引脚输入。

**原因：** 由 Xilinx FPGA 内部结构决定的，IBUFG/IBUFGDS 的输入端仅和芯片的全局时钟引脚有物理连接，与普通的 I/O 和其他内部 CLB 等没有物理连接。


### P.S. 第二全局时钟资源

在看其他资料时，看到一种新的时钟资源 —— 第二全局时钟资源。官方的文档我还没有找到，所以就直接摘抄书上的笔记了 =.=

+ 第二全局时钟资源属于长线资源，长度和驱动能力仅次于全局时钟资源，也可以驱动芯片内部的任何一个逻辑，抖动和延时仅次于全局时钟。

+ 在设计中，一般将高频率、高扇出的时钟使能信号以及高速路径上的关键信号指定为全局第二时钟信号。

+ 使用全局时钟资源并不占用逻辑资源，也不影响其他布线资源；第二时钟资源占用的是芯片内部的资源，占用部分逻辑资源，各个部分的布线会相互影响，所以建议在设计中逻辑占用资源不超过70%时使用。

+ **使用方法**

    可以在约束编辑器中的专用约束Misc选项中，指定所选信号使用低抖动延迟资源“Low Skew”来指定，也可以在ucf文件中添加“USELOWSKEWLINES"约束命令。
    
        NET “s1" USELOWSKEWLINES;
        NET “s2" USELOWSKEWLINES;
        NET “s3" USELOWSKEWLINES;

<br>

## Regional Clocking Resources
* * *

+ 区域时钟网络是一组独立于全局时钟网络的时钟网络。

+ 与全局时钟不同，区域时钟信号 (BUFR) 的跨度限于三个时钟区域，而 I/O 时钟信号只驱动一个区域。

+ Virtex-5 时钟控制资源和网络由以下通路和组件构成：

    + Clock Capable I/O

    + I/O Clock Buffer (BUFIO)

    + Regional Clock Buffer (BUFR)

    + Regional Clock Nets

### Clock Capable I/O

+ 典型时钟区域中有四个 clock-capable I/O 引脚对 （中心列有例外）。

+ 有些全局时钟输入也是 clock capable I/O。

+ 每个组中有四个专用 clock capable I/O 区。

+ 当用作时钟输入时，clock-capable 引脚可以驱动 BUFIO 和 BUFR。

+ 这些引脚不能直接连接到全局时钟缓冲器。

### I/O Clock Buffer - BUFIO

+ I/O 时钟缓冲器 (BUFIO) 是可以在 Virtex-5 器件中使用的一种时钟缓冲器。

+ BUFIO 驱动 I/O 列内一个独立于全局时钟资源的专用时钟网。

+ BUFIO 只能由位于同一时钟区域的 clock capable I/O 驱动。

+ 典型的时钟区域中有四个 BUFIO。

+ BUFIO 不能驱动逻辑资源 （CLB、Block RAM 等），因为 I/O 时钟网络只能覆盖同一组或时钟区域内的 I/O 列。

+ **BUFIO Primitive**

    + BUFIO 其实就是一个时钟输入和时钟输出缓冲器。输入与输出之间有一个相位延迟。

### Regional Clock Buffer - BUFR

+ 区域时钟缓冲器 (BUFR) 是可以在 Virtex-5 器件中使用的另一种时钟缓冲器。

+ BUFR 将时钟信号驱动到时钟区域内一个独立于全局时钟树的专用时钟网。

+ 每个 BUFR 可以驱动其所在区域中的四个区域时钟和相邻区域 （最多三个时钟区域）中的四个时钟网。

+ 与 BUFIO 不同，BUFR 不仅可以驱动其所在时钟区域和相邻时钟区域中的 I/O 逻辑，还可以驱动其中的逻辑资源 （CLB、Block RAM 等）。

+ 典型的时钟区域 （四个区域时钟网络）中有两个 BUFR。中心列没有 BUFR。

+ **BUFR Primitive**

    + BUFR 是一个具有输入时钟分频功能的时钟输入 / 时钟输出缓冲器。

### Regional Clock Nets

+ 除了全局时钟树和网（global clock trees and nets），Virtex-5 器件还包含区域时钟网（Regional Clock Nets）。

+ 这些时钟树也是为低歪斜和低功耗操作设计的。

+ 未用分枝都不连接。

+ 当所有逻辑资源都使用时，时钟树还管理负载 / 扇出。

+ 区域时钟网的传播并非遍及整个 Virtex-5 器件，而是仅限于一个时钟区域。

+ 一个时钟区域包含四个独立的区域时钟网。

+ 要接入区域时钟网，BUFR 必须例化。

+ 一个 BUFR 最多可以驱动两个相邻时钟区域中的区域时钟。

<br>

## Clock Management Technology
* * *

+ Virtex-5 系列的芯片内部含有的时钟管理模块（Clock Management Tiles，CMTs）可以提供灵活的、高性能的时钟信号。

+ 每个 CMT 由 2 个 DCM 和 1 个 PLL 组成。

### DCM

+ DCM 原语有两个：DCM_BASE、DCM_ADV

+ DCM_BASE 提供基本的功能，比如去歪斜、频率合成、固定相移；DCM_ADV 提供更高级的功能，比如动态重配置。

+ 两个原语都有各自的输入输出端口、属性设置和状态标识

+ DCM 可以连接到芯片上的其他时钟资源，包括专用时钟 I/O，时钟缓冲器和PLL

### PLL

+ Virtex-5 芯片最多包含了 6 个 CMT 模块，每个 CMT 模块包含一个 PLL，PLL 主要用来广谱频率的合成，并且与 DCM 配合最为外部/内部时钟的抖动滤波器。

+ PLL 也有两个原语：PLL_BASE、PLL_ADV

+ PLL_BASE 提供基本的功能，比如时钟去歪斜、频率合成、精确相移、占空比调整；PLL_ADV 提供更高级的功能，比如时钟切换、动态重配置等。

### MMCM

不同系列的芯片内部的时钟管理模块是不同的，比如在 Virtex-5 系列后的芯片就含有了 混合模式时钟管理器 MMCM 。

具体实现时该如何选择 DCM、DLL、PLL、MMCM ？找到一篇介绍 Xilinx 时钟资源的文章：

[如何正确使用FPGA的时钟资源][article]

[article]: http://www.ednchina.com/ART_8800512846_18_20010_TA_25f01c24.HTM

<br>

## Other Tips
* * *

1. 一般来说，外部提供的时钟信号都需要进行倍频/分频才可以使用，这时候需要组合各种时钟缓冲器和 DCM、PLL 等模块，我们有两种方法：

    1. 代码中例化原语，手动组合各种时钟缓冲器和 DCM、PLL

    2. 使用 IP core 向导，创建时钟管理器（可以发现 IP core 生成的代码就是上面 5 种组合方式）

    个人感觉使用第二种方法应该更加简洁、方便，不容易出错吧。（如果在代码中没有明确声明使用buffer，ISE 综合属性、IP core 属性设置里面默认会给所有的输入输出自动加上缓冲器）
    
2. 对 FPGA 设计而言，全局时钟是最简单最可预测的时钟，最好的时钟方案是：由专用的全局时钟输入引脚驱动单个全局时钟，并用后者去控制设计中的每个触发器。全局时钟资源是专用布线资源，存在与全铜布线层上，使用全局时钟资源不影响芯片的其他布线资源，因此在可以使用全局时钟的时候尽可能使用。

<br>

## Summary
* * *

虽然各个芯片都不尽相同，但是了解相关的基本知识有利于我们快速掌握芯片的时钟资源、快速上手。

Xilinx 的所有器件上的时钟资源可以分为前面说的 3 类：全局时钟（global clock）、局部时钟（regional clock）、I/O 时钟（I/O clock），但是不同的器件内部含有的时钟管理模块是不同的，具体到每一款芯片，应该以对应的 User Guide 为准。

<br>

## Reference

[Virtex 5 User Guide][ug190]

[Xilinx FPGA 开发使用教程](http://book.douban.com/subject/11523088/)

[Xilinx FPGA 高级设计及应用](http://book.douban.com/subject/10593491/)

[FPGA 高手设计实战真经 100 则](http://www.amazon.cn/%E5%9B%BE%E4%B9%A6/dp/B00FW1RTZG) 

[如何正确使用FPGA的时钟资源][article]
