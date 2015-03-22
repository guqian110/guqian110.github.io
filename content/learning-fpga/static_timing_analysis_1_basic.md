Title: 静态时序分析 STA 1 —— 基础知识
Date: 2015-03-18
Category: FPGA
Tags: STA
Slug: static_timing_analysis_1_basic
Author: Qian Gu
Summary: 静态时序分析 STA 系列之 1，基础知识。

静态时序分析（Static Timing）是数字 IC 设计中不可避免的话题，也是一个菜鸟成长必须掌握的技术。本文先总结 STA 中常见的定义、名词等。

## Clock
* * *

时钟是数字电路的动力系统，可以说数字电路中最重要的信号就是时钟信号了。一般时钟信号的时序特性分为：

1. 偏移 Skew

2. 抖动 Jitter

3. 占空比时钟 Duty Cycle Distortion

对于低速设计，基本不用考虑这些特征，但是对于高速设计，由于时钟本身造成的问题越来越普遍，因此有必要关注高速设计中的时序特性。

### Skew

时钟信号要提供给整个电路的时序单元，所以时钟信号线非常长，并构成分布式的RC网路。它的延时与时钟线的长度、时序单元的负载电容、个数有关，由于时钟线长度及负载不同，会导致时钟信号到达相邻两个时序单元的时间不同，这个时间上的偏差就是 时钟偏移 `Skew`。如下图所示：

![skew](/images/static-timing-analysis-1-basic/skew.jpg)

假设时钟信号达到两个 DFF 的延时分别为 Tc1 和 Tc2，用 Tskew 来表示它们之间的时钟偏移，则计算公式如下：

    Tskew = Tc1 - Tc2

根据差值可以分为正偏移和负偏移：

+ 当时钟到达 DFF1 的延时更大时，也就是 C1 > C2 时，Tskew 为正

+ 当时钟到达 DFF2 的延时更大时，也就是 C1 < C2 时，Tskew 为负

需要注意到是，时钟偏移永远存在，当其大到一定程度时，就会严重影响电路的时序。

FPGA 在设计架构时，专门针对这种现象进行优化，采用全铜工艺和树状结构，并且设计了专用的时钟缓冲和驱动网络，这么做的目的就是尽量使时钟到达不同时序单元的路径一样长，从而使时钟偏移非常小，可以忽略不计。

所以，**Skew 问题的解决方法就是：设计中的主要信号应该走全局时钟网络。**

即使采用了这样的设计，在实际电路中，时钟信号到达每个 DFF 的时间也不可能完全相等，Skew 是肯定存在的。所以 STA 仍然需要考虑该因素。在 PAR 之前，STA 只能根据设计的面积来粗略估计 Skew，在 PAR 之后，因为有了更具体的信息（线段长度、宽度、信号分布情况）STA 的估计值更加精确。

### Jitter

理想的时钟信号是方波，但是实际中的时钟信号边沿不可能是瞬间变化的，是个斜坡，如下图所示：

![clock](/images/static-timing-analysis-1-basic/clock.jpg)

时钟抖动 `Jitter` 的定义很多，最常见的有 3 种：

+ 周期抖动 `Period Jitter`

    ![Period Jitter](/images/static-timing-analysis-1-basic/period_jitter.jpg)

    实际时钟信号周期与理想时钟周期的差值的变化。这是最早最直接的一种衡量抖动的方式，这个指标说明了时钟信号每个周期的变化。

    因为这个差值是个随机变量，并且满足高斯分布，所以可以用期望和方差来描述。一般随机选择很多个周期，然后计算平均周期、标准差、峰峰值。标准差称为 “`RMS 抖动`”，峰峰值称为 “`Pk-Pk 周期抖动`”。知道 Pk-Pk 周期抖动，对于恰当配置系统和保持时间很有用。

+ 周期差抖动 `Cycle-to-cycle Jitter`

    ![c2c_jitter](/images/static-timing-analysis-1-basic/cycle_to_cycle_jitter.jpg)

    两个相邻时钟周期的差值的变化。根据定义可知，对周期抖动做一阶差分，就可以得到周期差抖动。

    这个差值也是一个服从高斯分布的随机变量。

+ 相位抖动 `Phase Jitter`

    ![phase_jitter](/images/static-timing-analysis-1-basic/phase_jitter.jpg)

    一个时钟沿相对于基准对齐之后，经过一段时间后，与理想位置的偏差。这个指标说明了周期抖动在各个时期的累计效应。

    因为需要累积一段时间，所以这个误差又称为 时间间隔误差（TIE, Timer Interval Error）。

由于 周期抖动 和 周期差抖动 是单个周期或者相邻周期的偏差，所以表征为短期抖动行为。而相位抖动需要累积一段时间，所以表征为长期抖动行为。

时钟抖动的原因就是噪声。**时钟抖动是永远存在的**，当其大到可以和时钟周期相比拟的时候，会影响到设计，这样的抖动是不可接受的。

### Duty Cycle Distortion

![dcd](/images/static-timing-analysis-1-basic/dcd.jpg)

占空比失真，即时钟不对称，有脉冲的时间和无脉冲的时间发生了变化。DCD 会吞噬大量的时序裕量，造成数字信号的失真，使过零区间偏离理想的位置。DCD通常是由信号的上升沿和下降沿之间时序不同而造成的。

<br>

## Ohters
* * *

除去时钟信号，还有一些其他的相关定义。

### Fan-out/Fan-out

**Fan-out**

在数字电路中，逻辑门相互连接，组成更加复杂的电路，所以大多数逻辑门的输出端都连接着多个别的单元的输入。所以需要一个术语来描述逻辑门的驱动能力的大小，也就是扇出 `Fan-out`。最大扇出数 `maximum fan-out` 定义为一个逻辑门可以驱动的同类逻辑门的最大数。

> 大多数 TTL 逻辑门能够为 10 个其他数字门或驱动器提供信号。因而，一个典型的 TTL 逻辑门有 10 个扇出信号。
> 
> 在一些数字系统中，必须有一个单一的 TTL 逻辑门来驱动 10 个以上的其他门或驱动器。这种情况下，被称为缓冲器（buf）的驱动器可以用在 TTL 逻辑门与它必须驱动的多重驱动器之间。这种类型的缓冲器有 25 至 30 个扇出信号。逻辑反向器（非门）在大多数数字电路中能够辅助这一功能。
> 
> **模块的扇出** 是指模块的直属下层模块的个数。一般认为，设计得好的系统平均扇出是 3 或 4。一个模块的扇出数过大或过小都不理想，过大比过小更严重。一般认为扇出的上限不超过 7。扇出过大意味着管理模块过于复杂，需要控制和协调过多的下级。解决的办法是适当增加中间层次。一个模块的扇入是指有多少个上级模块调用它。扇入越大，表示该模块被更多的上级模块共享。这当然是我们所希望的。但是不能为了获得高扇入而不惜代价，例如把彼此无关的功能凑在一起构成一个模块，虽然扇入数高了，但这样的模块内聚程度必然低。这是我们应避免的。
> 
> 设计得好的系统，上层模块有较高的扇出，下层模块有较高的扇入。其结构图像清真寺的塔，上面尖，中间宽，下面小。

**Fan-in**

与扇出相对的概念是 扇入 `Fan-in`，它描述的是一个逻辑门能够处理的外部输入的能力。扇入大的逻辑门的速度要比扇入小的慢，原因是增加扇入相当于增加逻辑门的输入电容。我们可以用使用多级逻辑门来代替高扇入的设计。

### Setup/Hold/Recovery/Removal Time

建立/保持时间是在同步设计中的概念：

建立时间 `setup time` ：触发器在时钟信号上升沿到来以前，要求输入数据必须保持稳定不变一段时间，这段时间就是器件需要的建立时间。如不满足 setup time，这个数据就不能被这一时钟打入触发器。

保持时间 `hold time` ：触发器在时钟信号上升沿到来以后，要求数据保持稳定不变一段时间，以便能够稳定读取，这段时间就是器件需要的保持时间。如果不满足 hold time，数据同样不能被打入触发器。

恢复/撤销时间是在异步设计中的概念：

恢复时间 `recovery time` : 对于异步信号（比如异步复位/置位），信号变无效的边沿和下一个时钟沿之间必须满足一个最小的间隔。其意义在于，如果保证不了这个最小时间，也就是异步信号无效边离时钟边沿太近了，异步信号解除（无效）之后，没有给 DFF 足够的时间来恢复（recovery）到正常状态，那么就不能保证在时钟沿到来时 DFF 可以正常工作。

撤销时间 `removal time` : 对于异步信号（比如异步复位/置位），信号变有效的边沿和前一个时钟沿之间必须满足一个最小的间隔。其意义在于，如果保证不了这个最小时间，也就是异步信号的有效沿离时钟太近了，在时钟信号去除（无效）之前，异步信号提前有效了，可能会造成 DFF 处于不确定状态。

[更加详细的总结：锁存器 Latch v.s. 触发器 Flip-Flop][blog1]。

[blog1]: http://guqian110.github.io/pages/2014/09/23/latch_versus_flip_flop.html

<br>

## STA Intro
* * *

[STA 的 wiki][wiki] 已经说的很明白了，下面的内容基本就是引用和翻译：

> Static timing analysis (STA) is a method of computing the expected timing of a digital circuit without requiring simulation.
>
> High-performance integrated circuits have traditionally been characterized by the clock frequency at which they operate. Gauging the ability of a circuit to operate at the specified speed requires an ability to measure, during the design process, its delay at numerous steps. Moreover, delay calculation must be incorporated into the inner loop of timing optimizers at various phases of design, such as logic synthesis, layout (placement and routing), and in in-place optimizations performed late in the design cycle. While such timing measurements can theoretically be performed using a rigorous circuit simulation, such an approach is liable to be too slow to be practical. Static timing analysis plays a vital role in facilitating the fast and reasonably accurate measurement of circuit timing. The speedup comes from the use of simplified timing models and by mostly ignoring logical interactions in circuits. It has become a mainstay of design over the last few decades.

### Definitions

STA 中的一些术语定义如下：

+ `timing path`

    [FPGA STA(三) --- STA的基本概念][blog1] 中说的很明白：

    > 在做 STA 时，首先要把电路分解为一条条的 timing path。实际上我们也可以把 timing path 称为 data path，其本质就是指信号传播的途径。每一条 timing path 都具有一个起始点和一个终点。起始点是指电路中信号被时钟沿锁存的点；而信号经过一系列的组合逻辑的通道或者走线后被另外一个时钟沿捕获，这个点被称为终点。信号从起始点到终点所经过的通道就被称为 timing path。
    > 
    > 起点有两种：
    >
    > + 时序器件的 时钟输入端
    >
    > + 电路的 输入端口
    > 
    > 终点也有两种：
    > 
    > + 时序器件的 数据输入端
    > 
    > + 电路的 输出端口
    > 
    > 输入和输出排列组合一共就有 4 种 path：
    > 
    > 1. 电路输入端口  ->  触发器的数据D端 (Pad-to-Setup)
    > 
    > 2. 触发器的clk端  ->  触发器的数据D端 (Clock-to-Setup)
    > 
    > 3. 触发器的clk端  ->  电路输出端口 (Clock-to-Pad)
    > 
    > 4. 电路输入端口  ->  电路输出端口 (Pad-to-Pad)
    > 
    > 如下图所示：
    > 
    > ![path](/images/static-timing-analysis-1-basic/timing_path.jpg)

+ `critical path`

    关键路径：从输入到输出，延时最大的那条路径称为 critical path。关键路径是系统中延时最大的路径，它决定了系统所能达到的最大时钟频率。

+ `arrival time`

    到达时间：信号到达某个特定位置所消耗的时间。一般将时钟信号到达的时刻作为参考的 0 时刻，为了计算到达时间，需要对路径中的所有组件的延时都进行计算。

+ `required time`

    需求时间：所能容忍的路径最大延时，也就是信号到达的最晚的时间。如果路径上的延时再大一些，则必须降低时钟频率，否则会产生 setup/hold time violation。

+ `slack`

    时序裕量：`slack = required time - arrival time`。如果计算出某条路径的 slack 是正数，说明这条路径的时延是满足要求的；如果计算出某条路径的 slack 是负数，则表示路径上的延时太大了，必须做出修改（修改设计 or 修改约束 or 换芯片），否则包含它的电路不能以预期的频率工作。

### Purpose

在同步设计中，数据的流动是统一步伐的，即时钟信号每改变一次，数据跟随改变一次。这种运作方式是基于同步器件（DFF 或者 Latch）来实现的，这类器件以时钟信号作为指示，将其输入端的数据复制到输出端。在同步设计中只存在两种时序错误：

+ setup time violation

    输入数据和时钟的关系不满足 setup time 的要求，即在时钟有效沿之前，输入数据没有保持稳定足够长的时间，数据将不能被这个时钟沿记录下来。

+ hold time violation

    输入数据和时钟的关系不满足 hold time 的要求，即在时钟有效沿之后，输入数据没有保持稳定足够长的时间，数据将不能被时钟信号记录下来。

导致数据和时钟不同步的原因很多，比如数据本身和时钟不同步、或者是电路进行了不同的操作，器件的温度、电压、制造工艺等因素也会产生影响。

**静态时序分析 STA 的主要目的是在上述可能的电路偏移情况存在的情况下，验证所有信号能够准时到达，并保证电路的正常功能。**

[Xilinx FPGA开发实用教程][book1]：

> 工作频率对数字电路而言至关重要。提高工作频率意味着更强大的处理能力，但是也带来了时序瓶颈：时序冲突的概率变大，电路的稳定性降低。所以为了使电路的性能达到设计的预期目标，并满足电路工作环境的要求，必须对一个电路设计进行时序、面积、负载等多方面的约束，并自始至终使用这些约束来驱动EDA软件工作。
> 
> ISE 具有一定的自动优化能力，对于一般的低速设计（处理时钟不超过100MHz），基本上不需要时序方面的任何手动分析和处理；但是对于高速和大规模设计，需要设计人员自行添加时序方面的控制和处理，通过多次反复操作，根据反馈结果逐步调整设定，直到满足要求为止。
>
> 以前小规模FPGA设计，只需要做动态的门级时序仿真就课同时完成逻辑功能验证和时序验证；随着FPGA设计规模和速度的提升，有必要将逻辑功能验证和时序验证分开：首先，逻辑功能的正确性，可以通过RTL级或者门级的功能仿真来验证；其次，时序分析通过STA（Static Timing Analysis，静态时序分析）验证。
> 
> 时序分析的主要作用就是查看FPGA内部逻辑和布线的延迟，验证其是否满足设计者的约束。
> 
> + 确定芯片最高工作频率
> 
>   控制工程的综合、映射、布局布线等关键环节，减少逻辑和布线的延迟，从而尽可能提高工作频率。一般情况下，处理时钟高于100MHz的时候，必须添加合理的时序约束文件。
> 
> + 检查时序约束是否满足
> 
>   检查目标模块是否满足约束，若不满足，通过时序分析器定位程序中不满足的部分，并给出具体原因，然后设计人员修改程序，直到满足约束。
> 
> + 分析时钟质量
> 
>   当采用了全局时钟等优质资源后，仍然不满足目标约束，则需要降低所约束的时钟频率。
> 
> + 确定分配引脚的特性
> 
>   通过时序分析可以指定I/O引脚所支持的接口标准、接口速率和其他电气特性。
>
> **STA的目的就是要保证 DUT（Device Under Test）中所有的路径满足内部时序单位对 setup time 和 hold
 time 的要求。信号可以及时的从任一时序路径的起点传递到终点，同时要求在电路正常工作所需的时间内保持恒定。**

### Theory

STA 是基于前面介绍的时序路径的，在分析时，计算时序路径上数据信号的到达时间和要求时间的差值，以判断是否存在违反设计规则的错误。

    Slack = Trequired_time - Tarrival_time

如果时序裕量 Slack 为正，表示满足时序，负值表示不满足时序。STA 按照上式分析设计中所有路径，如果 Slack为负值，则该路径为影响设计的关键路径，需要修改设计以达到时序要求。

STA 是通过“穷举法”抽取整个设计电路的所有时序路径，按照约束条件分析电路中是否有违反设计规则的问题，并计算出设计的最高频率。

[wiki]: http://en.wikipedia.org/wiki/Static_timing_analysis
[book1]: http://book.douban.com/subject/11523088/
[blog1]: http://blog.sina.cn/dpool/blog/s/blog_72c14a3d01013tpi.html?type=-1

<br>

## Ref

[Xilinx FPGA 开发实用教程](http://book.douban.com/subject/11523088/)

[RF类IC demo 板loadboard设计参考资料之时钟部分](http://www.ictest8.com/debug/rf_pcb.htm)

[正确理解时钟器件的抖动性能](http://www.ti.com.cn/cn/lit/an/zhca492/zhca492.pdf)

[技术解析：详解各种抖动技术规范](http://m.ee.ofweek.com/2014-10/ART-11000-2813-28889698.html)

[时间抖动(jitter)的概念及其分析方法](http://www.elecfans.com/article/85/126/2008/2008112718522.html)

[锁存器 Latch v.s. 触发器 Flip-Flop][blog1]

[TimeQuest定时分析的基本概念](http://blog.csdn.net/shanghaiqianlun/article/details/8685047)

[Static timing analysis][wiki]

[Xilinx FPGA开发实用教程][book1]

[FPGA STA(三) --- STA的基本概念][blog1]
