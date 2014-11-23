Title: FPGA 中的延时
Date: 2014-11-23 14:03
Category: FPGA
Tags: FPGA, delay
Slug: delay_in_fpgas
Author: Chien Gu
Summary: 总结电路中的时延及其 FPGA 中的实现

## Delay in circuits

从模拟电路的知识，我们可以知道 **电路中存在很多类型不同的延时。** 比如：

1. **propagation delay**

    我们通常假设信号在电平之间变化时瞬间完成的，但是实际情况并不是瞬间完成，电路需要花费一段时间才能完成电平的转化。晶体管的开关特性对于不同的变化有不同的表现：
    
    + 上升延时 (`rising delay`)，输出变为 1
    
    + 下降延时 (`falling delay`)，输出变为 0
    
    + 关闭延时 (`turn-off delay`)，输出变为高阻 Z
    
    + 输出变为 X 的时延
    
    原因就是（[Digital Design (Verilog): An Embedded Systems Approach Using Verilog][book1]）：
    
    > One factor that causes signal changes to occur over a nonzero time
interval is the fact that the switches in the output stage of a digital component, illustrated in Figure 1.15, do not open or close instantaneously. Rather, their resistance changes between near zero and a very large value over some time interval. However, a more significant factor, especially in CMOS circuits, is the fact that logic gates have a significant amount of capacitance at each input.

    这个答案也解释了为什么在设计中要避免大扇出信号：因为大扇出意味着输出端并联着很多电容，电容负载较大时造成连接信号转换相对较慢的原因。
    
    > The total capacitive load is thus the sum of the individual capacitive loads. The effect is to make transitions on the connecting signal correspondingly slower. For CMOS components, this effect is much more significant than the static load of component inputs.
    
    我们可以把对晶体管的讨论推广到其他的数字元件：
    
    > A similar argument regarding time taken to switch transistors on and off and to charge and discharge capacitance also applies within a digital component. Without going into the details of a component’s circuit, we can summarize the argument by saying that, due to the switching time of the internal transistors, it takes some time for a change of logic level at an input to cause a corresponding change at the output. We call that time the `propagation delay`, denoted by `tpd`, of the component.

2. **wire delay**

    另外一种延时是信号在导线上传播时产生的延时，一般我们都把这种延时假设也 0，也就是说导线时理想的导体，信号经由导线的传输没有任何延迟。如果导线很短，或者芯片上不超过 1mm 的导线来说，这种假设是合理的。但是当设计高速电路时，不能忽略这种导线存在的寄生电容和电感，这时候导线应该被视为传输线，必须精心设计。
    
    至于如何设计应该属于模拟电路的部分，这里不讨论。

关于上面的两种延时，[FPGA-Based System Design][book2] 里面有详细讨论如何建模、如何计算具体时延的值。

即使对于同一种信号跳变，延时也分为不同的类型：

+ 最小值 (`minimum`)

+ 典型值 (`typical`)

+ 最大值 (`maximum`)

[book1]: http://www.amazon.cn/Digital-Design-An-Embedded-Systems-Approach-Using-Verilog-Ashenden-Peter-J/dp/0123695279
[book2]: http://www.amazon.com/FPGA-Based-System-paperback-Prentice-Semiconductor/dp/0137033486

<br>

## Models in Verilog HDL

为了对电路中的时延现象进行建模，Verilog HDL 定义了延时语法。

+ 对于上升、下降、关闭时延，可以使用逗号按照顺序将三者分开：

        #!verilog
        assign #(1, 2) A_xor_wire = eq0 ^ eq1;
        assign #(1, 2, 3) A_xor_wire = eq0 ^ eq1;

    第一句表示一个异或门上升时延为 1，下降时延为 2，关闭和X时延为两者中的最小值，即 1；
    
    第二句表示一个异或门的上升、下降、关闭时延分别是 1，2，3，X时延为 3 者中的最小值，即 1。
    
+ 对于最小值、典型值、最大值可以使用分号按照 min:typ:max 的顺序，将 3 者分开：

        #!verilog
        assgin #(2:3:4, 3:4:5) A_xor_wire = eq0 ^ eq1;

    表示上升时延的 min:typ:max = 2:3:4，下降时延的 min:typ:max = 3:4:5。
        

需要注意到一点是，**当延时出现在 wire 信号的定义处时，会和普通的赋值语句中的延时稍有不同。**

    #!verilog
    wire #10 wireA;
    
这个叫做 `net delay`，它是和 wireA 绑定的，对 wireA 进行的任何赋值必须延迟 10 个时间单位之后才有效。当在连续赋值语句中，延时是属于连续赋值语句的一部分，而不属于 net，所以只在这一句中有效，对其他赋值语句没有影响。

**一般来说，assign 语句中的延时特性会被综合工具忽略。**因为综合工具需要完成的功能就是将代码描述映射为逻辑电路，而逻辑电路中的延时是由最基本的单元库和走线延时决定的，用户是无法对逻辑单元指定延时长度的，只能在综合、实现时添加时序约束条件，使工具尽量满足要求。

<br>

## Implement

Verilog HDL 中的延时语法不可综合并不代表就不能在实际电路中实现延时。

在实际电路中，不同的情况下需要采用不同的方法来实现延时：一般来说，异步电路的时延通过门延时来完成，比较难预测，而同步电路的时延通过触发器或者计数器来实现。

### in ASICs

在早期的逻辑电路图设计阶段，有且设计者养成了手工加入 Buffer 或者非门调整数据
延时的习惯，以保证本级模块的时钟对上级模块数据的建立及保持时间的要求。这些做法目
前主要应用于两种场合：

1. 分离电路

    使用分立逻辑单元（如 74 系列）搭建数字电路一般为复杂度比较低、系统灵活性比较低的场合。使用分立元件时，由于可以使用的元件比较少，而且一般设计频率比较低，时序裕量比较大，所以采用 Buffer、非门等单元来调整时延时可以接受的。
    
2. ASIC 领域

    在 ASIC 中采用这种方法，是以严格的仿真和时序约束为前提的。
    
### in FPGAs

在 ASIC 中采用的添加 Buffer、非门的设计方法并不适合 FPGA/CPLD 等可编程逻辑，在 FPGA 中应该尽量避免这种设计。

[The Art of Hardware Architecture][book3]：

> Delay chains occur when two or more consecutive nodes with a single fan-in and a single fan-out are used to cause delay. Often inverters are chained together to add delay. Delay chains generally result from asynchronous design practices, and are sometimes used to resolve race conditions created by other combinational logic. In both FPGA and ASIC, delays can change with each place-and-route. Delay
chains can cause various design problems, including an increase in a design’s sensitivity to operating conditions, a decrease in a design’s reliability, and difficulties when migrating to different device architecture. **Avoid using delay chains in a design, rely on synchronous practices instead.**

总结下来主要就是 3 个原因：

1. 设计的可靠度低

    Buffer、非门都是组合逻辑，组合逻辑最大的问题就是容易出现毛刺，电路可靠度不高，这种方法的时序裕量小，对环境敏感（特别是温度），一旦外界环境发生变化，时序可能就会完全紊乱、导致电路瘫痪。
    
2. 设计的移植难度大

    一旦芯片换代，或者需要将设计移植到不同的器件上时，就必须对延时进行重新调整，电路的可维护性和扩展性差。
    
3. 信号通过多级非门时，综合器可能会将其优化掉。

    虽然可以在代码中添加约束，防止综合器将其优化掉，但是不推荐这种方法，理由见前两条。
    
[Xilinx FPGA高级设计及应用][book4] 介绍了 FPGA 中应该采用的方法：

1. **专门的延时器件**

    在 FPGA/CPLD 内部延时电路结构由一种标准的宏单元描述。虽然各家芯片的宏单元描述不同，但总的来说都是 **一些逻辑 + 一个/两个触发器构成**。
    
    Altera FPGA 中可以对信号加一个或多个 LCELL 来产生一个延时。（Xilinx 的没有查到...）
    
    虽然厂家提供了延时单元，但是这种延时并不稳定，会随着外界环境（比如温度）的变化而变化，所以并不提倡这种方法。
    
    网上有人讨论这种方法的应用：[fpga内部的延时单元][link1]
    
2. **触发器 or 计数器**

    如果延时相对较小，可以使用高频时钟来驱动一个移位寄存器，将待延时的信号当作输入，按照需要的延时来设置移位寄存器的级数，最后的输出即延时的结果。
    
    如果延时相对较大，可以使用计数器来延时输出。

[book3]: http://www.amazon.com/The-Art-Hardware-Architecture-Techniques/dp/1461403960
[book4]: http://www.amazon.cn/Xilinx-FPGA%E9%AB%98%E7%BA%A7%E8%AE%BE%E8%AE%A1%E5%8F%8A%E5%BA%94%E7%94%A8-%E6%B1%A4%E7%90%A6/dp/B007TLVUT8
[link1]: http://bbs.eccn.com/viewthread.php?tid=181856

<br>

## Reference

[Digital Design (Verilog): An Embedded Systems Approach Using Verilog][book1]

[FPGA-Based System Design][book2]

[设计与验证Verilog HDL](http://book.douban.com/subject/1882474/)

[Xilinx FPGA高级设计及应用][book4]

[The Art of Hardware Architecture: Design Methods and Techniques for Digital Circuits][book3]
