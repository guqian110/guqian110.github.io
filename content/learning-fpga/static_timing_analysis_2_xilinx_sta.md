Title: 静态时序分析 STA 2 —— Xilinx STA
Date: 2015-03-22
Category: FPGA
Tags: STA, Xilinx
Slug: static_timing_analysis_2_xilinx_sta
Author: Qian Gu
Summary: 总结 Xilinx 时序约束的一些基本内容

**总结 Xilinx 时序约束的一些基本内容，基本上是 [UG612 Timing Closure User Guide][ug612] 的翻译和概括。*

P.S. 找到一篇 Xilinx 的文章，也很简洁实用：[赛灵思 FPGA 设计时序约束指南][article1]

[article1]: http://china.xilinx.com/china/xcell/xl37/e10-14.pdf

## Xilinx STA
* * *

按照路径所覆盖的范围，可以将时序路径要求分为 4 大类：

1. Input paths

2. Register-to-register paths

3. Output paths

4. Path specific exceptions

**添加约束最有效的方法就是先添加全局约束，然后根据需求考虑是否添加指定路径上的特殊约束。在很多案例中，只需要添加全局约束就可以了。**

FPGA器件执行工具都是由指定的时序要求驱动的。如果时序约束过头的话，就会导致内存使用增加，工具运行时间增加。更重要的是，过约束还会导致性能下降。因此，推荐使用实际设计要求的约束值。

下面分别讨论每种路径上的约束。

<br>

## Input paths

所谓 “输入路径 `input paths`”，指的是从 “FPGA 外部引脚 ---> 内部读取这个数的寄存器” 之间的路径。

在输入路径模型中，发送端是一个外部设备（当然也可以是 FPGA），接收端是 FPGA 芯片，输入路径讨论的就是以接收端的 FPGA 为视角，如何正确接收输入的数据。

依据接口类型，可以将输入路径的时序分为 2 类：

1. System Synchronous Inputs

2. Source Synchronous Inputs

而对于输入路径的约束方法就是使用 `OFFSET IN` 来约束，它约束了 输入数据 和 用于捕获这个数据的时钟沿 之间的关系。（顾名思义，输入路径约束的是方向为 IN 的数据和时钟的相对偏移 OFFSET 的关系）

下面分别对两类输入路径进行讨论：

### System Synchronous Inputs

所谓 System Synchronous Inputs 其实就是指 “发送端 和 接收端 使用同一个系统（system）时钟”。布线延时和时钟倾斜会限制这种接口的工作时钟频率，由于这个原因，这种接口一般应用在 SDR 中。

system synchronous SDR 应用示例如下图：

![system synchronous SDR](/images/static-timing-analysis-2-xilinx-sta/system_synchronous_in_sdr.png)

其时序为：

1. 发送器件在某个时钟的上升沿将数据发送出去

2. FPGA 在下一个时钟的上升沿捕获到数据

**对于这种接口的时序，使用 `OFFSET IN` 是最有效方便的添加约束的方法。对于接口中的每个时钟，都有一个对应的 offset in 约束，这个约束覆盖了所有的使用该时钟来捕获输入数据的路径。**

**添加约束的方法：**

**1. 首先对接口的时钟添加周期约束（period constraint）**

**2. 其次为接口添加全局 offset in 约束（global Offset In）**

**语法如下：**

    OFFSET = IN value VALID value BEFORE clock;

+ OFFSET=IN <value> 约束了数据变有效的沿和时钟的捕获数据的沿之间的距离

+ VALID <value> 约束了数据保持有效的时间长度

举例：

例1. 在下面理想的 system synchronous SDR interface 时序图中：

![example1](/images/static-timing-analysis-2-xilinx-sta/example1.png)

数据在时钟沿的前 5 ns 变为有效，并且保持了 5 ns 时间，所以在这个实例中的时序约束应该如下：

    NET "SysClk" TNM_NET = "SysClk";
    TIMESPEC "TS_SysClk" = PERIOD "SysClk" 5 ns HIGH 50%;
    OFFSET = IN 5 ns VALID 5 ns BEFORE "SysClk";

而且这个约束对于 data1 和 data2 共同有效。

例2. 不是理想的 system synchronous SDR interface 中，假设时钟周期为 5 ns，并且占空比为 50%，数据在发送时钟上升沿之后的 500 ps 之后变有效，并且持续 4 ns。则时序约束应该如下：

    NET "clock" TNM_NET = CLK; 
    TIMESPEC TS_CLK = PERIOD CLK 5.0 ns HIGH 50%; 
    OFFSET = IN 4.5 ns VALID 4 ns BEFORE clock;

### Source Synchronous Inputs

所谓 Source Synchronous Inputs 其实就是指 “发送端重新生成一个时钟信号，并且将数据和时钟信号有着相似的布线，两者的延时基本相同，在接收数据的 FPGA 端，使用这个时钟来捕获这个数据”。布线延时和时钟倾斜不再是限制这种接口工作速度的因素，所以这种接口一般应用在双倍数据速率的 DDR 中。

source synchronous SDR 应用示例如下图：

![source synchronous SDR](/images/static-timing-analysis-2-xilinx-sta/source_synchronous_in_ddr.png)

其时序为：

1. 发送器件在某个时钟的上升沿和下降沿都会发送一个独立的数据

2. 接收端的 FPGA 使用发送端传递过来的这个再生时钟来捕获数据

**对于这种接口的时序，使用 `OFFSET IN` 是最有效方便的添加约束的方法。对于接口中的每个时钟，都有一个对应的 offset in 约束，这个约束覆盖了所有的使用该时钟来捕获输入数据的路径。**

**添加约束的方法：**

**1. 首先对接口的时钟添加周期约束（period constraint）**

**2. 其次为时钟的上升沿添加全局 offset in 约束（global Offset In）**

**3. 最后为时钟的下降沿添加全局 offset in 约束（global offset in）**

**语法如下：**

    OFFSET = IN value VALID value BEFORE clock RISING;
    OFFSET = IN value VALID value BEFORE clock FALLING;

举例： 

例3. 在下面理想的 source synchronous DDR interface 时序图中：

![example3](/images/static-timing-analysis-2-xilinx-sta/example3.png)

输入时钟的周期为 5 ns，并且占空比为 50%，两 bit 的数据的有效时间都为 1/2 时钟周期，所以在这个实例中的时序约束应该如下：

    NET "SysClk" TNM_NET = "SysClk";
    TIMESPEC "TS_SysClk" = PERIOD "SysClk" 5 ns HIGH 50%;

    OFFSET = IN 1.25 ns VALID 2.5 ns BEFORE "SysClk" RISING;
    OFFSET = IN 1.25 ns VALID 2.5 ns BEFORE "SysClk" FALLING;

例4. 不是理想的 source synchronous DDR（数据和时钟的边沿对齐），假设时钟周期为 5 ns，并且占空比为 50%，上升沿和下降沿的数据都保持有效 2ns，并且位于时钟波形的高低电平的中间位置，也就是说，在数据有效的前后各有 250 ps 的空白。

对于上升沿，因为数据相对于捕获它的时钟沿后了 250 ps，并且有效时间持续了 2 ns；对于下降沿，数据也沿后了 250 ps， 并且有效时间持续了2 ns，所以时序约束如下：

    NET "clock" TNM_NET = CLK; 
    TIMESPEC TS_CLK = PERIOD CLK 5.0 ns HIGH 50%; 
    OFFSET = IN -250 ps VALID 2 ns BEFORE clock RISING; 
    OFFSET = IN -250 ps VALID 2 ns BEFORE clock FALLING

例5. 不是理想的 source synchronous DDR（数据和时钟的中间位置对齐），假设时钟周期为 5 ns，并且占空比为 50%，上升沿和下降沿的数据都保持有效 2 ns，并且时钟沿对齐数据的中间位置，可以得出结论，在数据有效的前后各有 250 ps 的空白。

对于上升沿，因为数据相对于捕获它的时钟提前了 1 ns，并且有效时间持续了 2 ns；对于下降沿，数据也提前了 1 ns，并且有效时间持续了 2 ns，所以时序约束如下：

    NET "clock" TNM_NET = CLK; 
    TIMESPEC TS_CLK = PERIOD CLK 5.0 ns HIGH 50%; 
    OFFSET = IN 1 ns VALID 2 ns BEFORE clock RISING; 
    OFFSET = IN 1 ns VALID 2 ns BEFORE clock FALLING;

<br>

## Register-to-register paths

这部分讨论寄存器-寄存器之间同步路径上的周期约束（period constraint）。

period constraint

+ 定义了时钟域的时序

+ 覆盖了内部寄存器之间的同步数据路径

+ 分析单个时钟域内的路径

+ 分析两个相关联的时钟域之间的所有路径

+ 在分析时考虑了时钟域之间的相位、频率、不确定性因素

同步时钟域的约束可以分为以下 3 类：

1. Automatically Related Synchronous DLL, DCM, PLL, and MMCM Clock Domains

2. Manually Related Synchronous Clock Domains

3. Asynchronous Clock Domains

**使用工具对 DCM、PLL 和 MMCM 的输出时钟自动添加时钟关系，并且手动定义外部的相关时钟的关系。通过这种方法，可以保证所有的跨时钟域的同步路径都被正确约束、分析，使用这种方法来添加 period constraint 可以避免再添加额外的跨时钟域约束。**

### Automatically Related Synchronous DLL, DCM, PLL, and MMCM Clock Domains

最常见的时钟信号就是下面两个：

1. 输入到 DCM、PLL 或者是 MMCM 的时钟信号

2. 从这些单元输出，用来驱动内部的同步路径的时钟信号

推荐的约束方法是 **对输入到 DCM、PLL 或者是 MMCM 的时钟信号添加周期约束（period constraint）。** 通过对输入时钟添加周期约束，Xilinx 工具会

+ 自动为 DCM、PLL 或者是 MMCM 的输出生成一个新的周期约束

+ 确定输出时钟之间的关系

+ 分析这些同步域之间的任何路径

**语法如下：**

    NET "ClockName" TNM_NET = "TNM_NET_Name";
    TIMESPEC "TS_name" = PERIOD "TNM_NET_Name" PeriodValue HIGH HighValue%;

其中 

+ PeriodValue 定义时钟周期

+ HighValue 定义时钟的占空比

举例：

例6. 在下图的例子中

![example6](/images/static-timing-analysis-2-xilinx-sta/example6.png)

输入时钟连接到 DCM 的输入端，因为输入时钟的时钟周期为 5 ns，并且占空比为 50%，所以添加的约束为：

    NET "ClkIn" TNM_NET = "ClkIn";
    TIMESPEC "TS_ClkIn" = PERIOD "ClkIn" 5 ns HIGH 50%;

在上面的例子中，我们给出上面的约束条件之后，DCM 会自动为它的两个输出添加约束，并且分析这两个时钟域

### Manually Related Synchronous Clock Domains

在有些情况中，Xilinx 工具无法自动分析指定同步时钟域之间的关系（比如相关的时钟信号从两个不同的管脚输入进入到 FPGA），

**这种情形下，Xilinx 推荐的约束方法是：**

**1. 为每一个输入时钟都创建一个周期约束**

**2. 手动定义时钟之间的关系**

一旦我们定义了时钟约束，工具会自动分析两个同步域之间的所有路径，并且在分析时会把频率、相位、不确定因素都考虑进去。

Xilinx 的约束系统可以通过在周期约束中加入频率和相位信息来添加更加复杂的周期约束（complex manual relationship）。

**约束方法：**

**1. 为主时钟定义周期约束**

**2. 以主时钟的约束为参考，为其他的相关时钟添加周期约束**

**语法如下：**

    NET "PrimaryClock" TNM_NET = "TNM_Primary";
    NET "RelatedClock" TNM_NET = "TNM_Related";
    TIMESPEC "TS_primary" = PERIOD "TNM_Primary" PeriodValue HIGH HighValue%;
    TIMESPEC "TS_related" = PERIOD "TNM_Related" TS_Primary_relation PHASE value;

在 related PERIOD 的约束中，PERIOD 的值定义了相关时钟和主时钟之间的关系（以时钟周期为单位），这种关系用主时钟的 TIMESPEC 形式来定义；PHASE 的值定义了主时钟和相关时钟的上升沿之间的关系。

举例：

例7. 如下图所示

![example7](/images/static-timing-analysis-2-xilinx-sta/example7.png)

CLK2X180 的频率是 CLK1X 的 2 倍，所以 PERIOD 的值为 1/2；CLK2X180 的相位相比于主时钟，偏移了 180度，所以它的上升沿比主时钟的上升沿晚了 1.25 ns；所以这个例子的约束如下：

    NET "Clk1X" TNM_NET = "Clk1X";
    NET "Clk2X180" TNM_NET = "Clk2X180";
    TIMESPEC "TS_Clk1X" = PERIOD "Clk1X7 5 ns HIGH 50%;
    TIMESPEC "TS_Clk2X180" = PERIOD "Clk2X180" TS_Clk1X/2 PHASE +1.25 ns;

### Asynchronous Clock Domains

异步时钟是指频率或相位有一个不同或者都不相同的时钟。因为时钟是不相关的，所以在进行 setup/hold time 分析时，是无法确定时钟的最终关系的。因此，**Xilinx 推荐在设计时使用一些特殊的方法来确保数据能被正确捕获。**然而，有时候设计者希望不考虑频率和相位之间的关系，在孤立的条件下限制数据传输的最大时延。

Xilinx 约束系统允许不考虑源和目的时钟之间的频率、相位关系，直接约束数据路径的最大时延。语法就是使用带 `DATAPATHONLY` 关键字的 `From-To` 语句。

**约束方法：**

**1. 为源同步寄存器定义时钟组**

**2. 为目的同步寄存器定义时钟组**

**3. 用带 `DATAPATHONLY` 关键字的 `From-To` 来约束两个时钟域之间的最大数据时延**

**语法如下：**

    NET "CLKA" TNM_NET = FFS "GRP_A";
    NET "CLKB" TNM_NET = FFS "GRP_B";
    TIMESPEC TS_Example = FROM "GRP_A" TO "GRP_B" Delay DATAPATHONLY

举例：

例8. 以前面的图为例，假设 CLKA 输入到第一个寄存器 R1，CLKB 输入到第二个寄存器 R2，R1 的输出连接到 R2 的输入，能忍受的最大的数据时延为 5 ns，则约束为：

    NET "CLKA" TNM_NET = FFS "GRP_A";
    NET "CLKB" TNM_NET = FFS "GRP_B";
    TIMESPEC TS_Example = FROM "GRP_A" TO "GRP_B" 5 ns DATAPATHONLY

<br>

## Output paths

这部分讨论如何为输出路径添加约束。输出约束覆盖了从 “内部同步单元/寄存器 ---> FPGA 输出管脚” 之间的所有路径。如下图所示：

![output example](/images/static-timing-analysis-2-xilinx-sta/output_example.png)

在输出路径模型中，发送端是 FPGA 芯片，接收端是一个外部设备（当然也可以是 FPGA），输入路径讨论的就是以发送端的 FPGA 为视角，如何将待发送定数据正确发送出去。

和输入路径对应，输出路径使用 `OFFSET OUT` 来约束以达到时序要求。

OFFET OUT 定义了输出数据和将该数据发送到输出管脚的时钟之间的关系。OFFSET OUT 的分析会自动将影响输出数据/输出时钟的内部因素考虑在内：

1. 时钟的频率和相位畸变

2. 时钟的不确定性

3. 数据时延的调整

和输入路径类似，输出路径的时序要求也可以依据接口的类型（system/source synchronous）和数据速率（SDR/DDR）来分类讨论。

### System Synchronous Output

在 system synchronous output 中，发送端和接收端使用同一个时钟，所以发送端的 FPGA 只需要发生数据部分就可以了。如下图所示：

![system synchronous output](/images/static-timing-analysis-2-xilinx-sta/system_synchronous_out.png)

**对于 system synchronous output 接口，使用全局 OFFSET OUT 是最有效的方法。每个 OFFSET OUT 都约束了一个对应的输出时钟，并且所有使用这个时钟来触发的输出数据路径都被这个约束所覆盖。**

**约束方法：**

**1. 为输出时钟定义一个时钟名（TNM）来分组、，这个时钟组包含了所有被这个时钟触发的输出寄存器**

**2. 定义接口的全局 OFFSET OUT 约束**

**语法如下：**

    OFFSET = OUT value AFTER clock;

其中 `OFFSET = OUT <value>` 规定了 “接收器件的输入时钟（=发送端 FPGA 的时钟）上升沿 ---> 发送端 FPGA 输出数据变有效” 直接的最大时延。

举例：

例9. 如下图所示的 System Synchronous SDR output interface

![example9](/images/static-timing-analysis-2-xilinx-sta/example9.png)

假设发送端的输出数据必须在时钟上升沿之后的 5 ns 内变为有效，则约束如下：

    NET "ClkIn" TNM_NET = "ClkIn";
    OFFSET = OUT 5 ns AFTER "ClkIn";

### Source Synchronous Output

在 source synchronous output interface，发送端的 FPGA 会重新生成一个时钟信号，并且将时钟信号和数据一起发送出去，如下图所示：

![source synchronous output](/images/static-timing-analysis-2-xilinx-sta/source_synchronous_out.png)

**对于 source synchronous output 接口，使用全局 OFFSET OUT 是最有效的方法。每个 OFFSET OUT 都约束了一个对应的输出时钟，并且所有使用这个时钟来触发的输出数据路径都被这个约束所覆盖。**

**约束方法：**

**1. 为输出时钟定义一个时钟名（TNM）来分组、，这个时钟组包含了所有被这个时钟触发的输出寄存器**

**2. 为时钟上升沿添加 global Offset Out 约束**

**3. 为时钟下降沿添加 global Offset Out 约束**

**语法如下：**

+ `OFFSET = OUT <value>` 约束了从 “输入时钟的上升沿 ---> 发送端 FPGA 输出端口数据变为有效” 的最大时延。

+ 关键词 `REFERENCE_PIN` 约定以重新生成的时钟作为参考，输出数据的 skew 报告就是以这个时钟作为参考生成的。

举例：

例10. 下图是一个理想的 Source Synchronous DDR interface 时序图

![example10](/images/static-timing-analysis-2-xilinx-sta/example10.png)

时钟周期为 5 ns，并且占空比为 50%，数据保持有效的时间为 1/2 时钟周期。所以，这个示例的约束如下：

    NET "ClkIn" TNM_NET = "ClkIn";
    OFFSET = OUT AFTER "ClkIn" REFERENCE_PIN "ClkOut" RISING;
    OFFSET = OUT AFTER "ClkIn" REFERENCE_PIN "ClkOut" FALLING

<br>

## Path specific exceptions

通过前面的 3 节的讨论，对输入、寄存器-寄存器、输出路径进行约束，大部分时序路径都得到了正确约束，然后在一些情况中，存在少数不适应于全局约束的少数路径，这些例外最常见的就是：

+ False Paths (Paths Between Registers That Do Not Affect Timing)

+ Multi-Cycle Paths

下面分别讨论。

### False Paths (Paths Between Registers That Do Not Affect Timing)

如果有些路径不影响时序性能，那么我们就可以将这些路径从时序分析中移除。**最常用的方法就是使用带 time ignore (`TIG`) 关键词的 `FROM_TO` 约束。** 使用这种约束，可以

+ 从源时钟域指定一组寄存器

+ 从目标时钟域指定一组寄存器

+ 将源到目标域的路径从时序分析中移除

**约束方法：**

**1. 在源时钟域指定一组寄存器**

**2. 在目标时钟域指定一组寄存器**

**3. 使用带 TIG 关键词的 FROM-TO 来移除这两个域之间的路径**

**语法如下：**

    TIMESPEC "TSid" = FROM "SRC_GRP" TO "DST_GRP" TIG;

举例：

例11. 假设下图中的两个寄存器之间的路径并不影响设计的时序，希望将这条路径从时序约束中移除

![example11](/images/static-timing-analysis-2-xilinx-sta/example11.png)

则本例的约束如下：

    NET "CLK1" TNM_NET = FFS "GRP_1";
    NET "CLK2" TNM_NET = FFS "GRP_2";
    TIMESPEC TS_Example = FROM "GRP_1" TO "GRP_2" TIG;

### Multi-Cycle Paths

在多周期路径中，从发送端到接收端的同步单元，数据以低于周期约束中的 PERIOD 速率传输。这种情况最常见的场景是同步单元使用一个共同的 clock enable 来门控。

通过定义一个多周期路径（Multi-Cycle path），这些同步单元的约束条件会比默认的周期约束宽松很多。方法就是先给周期约束定义一个标识，然后再声明 Multi-Cycle path 包含多少个时钟周期。然后工具就可以合理分配这些路径的优先级。

定义一个多周期路径的 **最常用的方法就是用 clock enable 信号定义一个时钟组，这样我们就可以用这个 clock enable 来定义一个包含了源、目的寄存器的时钟组，然后将多周期约束应用到这些寄存器之间的路径上。**

**约束方法：**

**1. 对公用时钟域进行周期约束**

**2. 定义所有基于同一个 clock enable 信号的寄存器**

**3. 对新的时序要求进行 From:To(Multi-Cycle) 约束**

**语法如下：**

    TIMESPEC "TSid" = FROM "MC_GRP" TO "MC_GRP" <value>;

+ `MC_GRP` 定义了一组公用时钟的寄存器

+ 所有从 `MC_GRP` 开始，到 `MC_GRP` 结束的路径就是需要进行多周期约束的路径

举例：

例12. 如下图所示的假设情形中

![example12](/images/static-timing-analysis-2-xilinx-sta/example12.png)

两个寄存器直接的路径被一个共同点 clock enable 控制，并且 clock enable 的变化速率是时钟频率的一半。则本例的时序约束如下：

    NET "CLK1" TNM_NET = "CLK1";
    TIMESPEC "TS_CLK1" = PERIOD "CLK1" 5 ns HIGH 50%;
    NET "Enable" TNM_NET = FFS "MC_GRP";
    TIMESPEC TS_Example = FROM "MC_GRP" TO "MC_GRP" TS_CLK1*2;

[ug612]: http://www.xilinx.com/support/documentation/sw_manuals/xilinx14_2/ug612.pdf

<br>

## Summary
* * *

通过对这四种类型的 timing path 进行约束，基本上系统内所有路径都得到了合理约束。

## Ref

[Timing Closure User Guide][ug612]
