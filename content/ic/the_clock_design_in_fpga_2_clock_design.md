Title: FPGA 时钟设计 2 —— 时钟设计
Date: 2014-09-12 12:45
Category: IC
Tags: clock design
Slug: the_clock_design_in_fpga_2_clock_design
Author: Qian Gu
Summary: 总结 FPGA 中的时钟设计方案

> 无论是离散逻辑、可编程逻辑，还是用全定制硅器件实现的任何数字设计，为了成功地操作，可靠的时钟是非常关键的。
>
> 设计不良的时钟在极限的温度、电压或者制造工艺的偏差情况下将导致错误的行为，并且调试困难、花销很大。

总结一下 FPGA 中的时钟设计原则。

<br>

## Clock Design
* * *

> 在 FPGA/CPLD 中通常采用几种时钟类型：
>
> + 全局时钟
> 
> + 门控时钟
>
> + 多级逻辑时钟
>
> + 波动式时钟
>
> 多时钟系统能够包括上述 4 种时钟类型的任意组合。

上面是 [《Xiliinx FPGA 高级设计及应用》](http://book.douban.com/subject/10593491/) 中的分类方法，个人觉得并不是很清晰，我总结了一下，大概可以分为下面的这 4 种：

1. 全局时钟 Global Clock

2. 门控时钟 Gated Clock

3. 逻辑时钟 Logic Clock

4. 分频/倍频时钟 Divied/Multiplied Clock

### Gloabl Clock

关于全局时钟，前面一篇 blog  [FPGA 时钟设计 1 —— 时钟资源总结]() 中有总结。

对于一个项目来说，全局时钟是 **最简单**、**最可预测** 的时钟。

在 PLD/FPGA 项目中 **最好的时钟方案** 是：由专用的全局时钟输入引脚驱动的单个主时钟去钟控设计项目中的每一个触发器。只要可能就应该尽量在设计中采用全局时钟

PLD/FPGA 都具有专门的全局时钟引脚，它直接连接到器件中的每一个寄存器，这种全局时钟提供最短的时钟到输出的延时。

### Gated Clock

门控时钟的意思是通过组合逻辑，控制、禁止或允许时钟输入到寄存器和其他同步原件上的一种方法。因为它能够有效地降低功耗，所以被广泛地应用于 ASIC 设计中。但是，它不符合 `同步设计` 的思想，可能会影响系统设计的实现和验证，所以，**在 FPGA 设计中应该避免使用门控时钟。**

因为 ASIC 和 FPGA 结构设计上的区别，两者对待门控时钟的态度是完全不同的：

[Gated clocks and clock enables in FPGA and ASICS](http://electronics.stackexchange.com/questions/73398/gated-clocks-and-clock-enables-in-fpga-and-asics)

往往可以将门控时钟转化为全局时钟以改善项目设计的可靠性。

**方法一** 

就是使用寄存器 `时钟使能 (clock enable, CE)` 端口。

单纯从功能来看，使用使能时钟代替门控时钟是一个不错的选项，但是使能时钟在使能信号关闭时，时钟信号仍然工作，它无法像门控时钟那样降低系统的功耗。

推译带使能端的触发器的代码：

    #!verilog
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dout <= 0;
        end
        else begin
            if (ce) begin
                dout <= din;
            end
            else begin
                dout <= dout;
            end
        end
    end

得到的结果就是原语 `FDCE`

> // FDCE: Single Data Rate D Flip-Flop with Asynchronous Clear and
>
> //       Clock Enable (posedge clk).

**方法二**

使用 `多路选择器（mux）` 将组合逻辑从时钟通路搬移到数据通路。如下图所示

![mux](/images/the-clock-design-in-fpga-2-clock-design/mux.png)

如果在设计中无法避免门控时钟，那么只要保证满足下面两个条件就可以使门控时钟和全局时钟一样可靠地工作：

1. 驱动时钟的逻辑必须只包含一个与门（或门），而且这个与门（或门）必须只有两个输入端。如果采用任何附加逻辑，则会出现竞争产生的毛刺。

2. 逻辑门的一个输入端为实际时钟。

这些条件的目的就是为了避免组合逻辑中的竞争带来的毛刺。

根据数字电路的知识，我们知道可以通过添加“冗余逻辑”的方法来消除组合逻辑的冒险，但是，FPGA 的编译器在 综合时会去掉这些冗余逻辑，所以不能采用这种方法。

### Logic Clock

有时候会用到组合逻辑的输出作为时钟信号或者复位信号，但是这种时钟信号有两个非常重要的缺陷：

1. 组合逻辑产生的信号不可避免地会出现毛刺，会导致系统运行失败。

2. 组合逻辑产生的时钟信号使用的是通用布线资源，和专用时钟布线相比，延迟长、时钟偏移大，满足时序要求会更加困难。如果大量的逻辑使用了这种时钟，这个问题会更加突出。

（看到书上提出一个解决方案是：使用系统专用的时钟信号，将组合逻辑的输出打一拍，避免组合逻辑的直接输出，达到同步的效果。但是我个人认为这个方案不是非常好。）

综上，对于 FPGA 来说，还是应该**尽量避免使用组合逻辑的输出作为时钟**。

### Divide/Multiplied Clock

**Guideline：** 尽量避免分频时钟

在我们的设计中，一般都不止一个时钟频率。如果不加注意，随意使用分频时钟，这叫做时钟满天飞，是非常不好的设计风格。

如果一定要使用分频时钟：

1. 对于资源比较丰富的 FPGA

    使用内部提供的 PLL/DLL，输出时钟信号可以配置成不同的频率（倍频/分频）和相位，这样的分频时钟是最稳定的。

2. 对于无法使用 PLL/DLL 的 FPGA

    对于这些情况，首先检查是否可以用 `CE` (clock enable) 来代替分频时钟，如果不行，则使用 [时钟分频器][dividers] 中讨论的分频方法。


[dividers]: http://guqian110.github.io/pages/2014/10/13/clock_dividers.html

<br>

## Other Tips
* * *

+ **只使用时钟的单个边沿**

    除了一些特殊的电路（如DDR）外，设计应该只使用单个边沿（上/下边沿）。使用两个边沿的问题是时钟占空比不一定是 50%，这会对电路的正常工作产生影响。

+ **使用差分时钟**

    通常认为频率高于 100 MHz 就属于 `高频`。建议在高频下使用差分时钟，因为差分时钟的抗噪声性能更好。

+ **检测时钟缺失**

    使用 DCM/MMCM 的 `locked` 输出，在使用时钟前先检查时钟是否锁定。
    
<br>

## Reference

[Xilinx FPGA 高级设计及应用](http://book.douban.com/subject/10593491/)

[FPGA 高手设计实战真经 100 则](http://www.amazon.cn/%E5%9B%BE%E4%B9%A6/dp/B00FW1RTZG)

[Xilinx FPGA 开发实用教程](http://book.douban.com/subject/11523088/)

[深入浅出玩转 FPGA](http://book.douban.com/subject/4893454/)
