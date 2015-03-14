Title: FPGA 中的复位设计
Date: 2014-06-20 00:22
Category: FPGA
Tags: reset
Slug: the_art_of_reset_design_in_fpga
Author: Qian Gu
Summary: 总结 FPGA 中的复位设计


复位信号在系统中的地位和时钟信号几乎同等重要，我们想尽量把系统设计为可控，那么最基本的控制信号就是复位信号了。

复位信号的设计需要考虑的因素，各种书刊、论文、白皮书、网上论坛都有相关讨论，但是至今对于给定 FPGA 设计中使用哪种复位方案仍然没有明确答案。本文总结了一些大神的经典论文和网上的许多博客，尽可能用简单的图说明选择某种设计方案及其理由，涉及的更深入的原理请自行 Google :-P
 
<br>

## Understanding the flip-flop reset behavior
* * *

在开始详细讨论之前，首先得理解 FPGA 的基本单元 Slice 中的 FF 的复位方式。Xilinx 的 Virtex 5 系列的芯片中的 FF 的类型都是 DFF (D-type flip flop)，这些 DFF 的控制端口包括一个时钟 CLK，一个高有效的使能 CE，一个高有效的置位/复位 SR。这个 SR 端口可以配置为同步的置位/复位，也可以配置为异步方式的置位/复位。如下图所示

![dff](/images/the-art-of-reset-design-in-fpga/dff.jpg)

例化（`instantiation`）和 推译（`inference`）是在 FPGA 设计中使用元件的两种不同方法。综合器是通过 HDL 代码 推译（`infer`） 最终的电路，所以我们写的 RTL 代码风格会影响最终综合出来的 FF 类型。

如果代码的敏感列表中包含复位信号，那么就会综合出一个异步复位的 DFF，SR 端口将被配置为置位或者复位端口(FDPE & FDCE primitive)。当 SR 变高时，FF 的输出值立即变为代码中的复位时设定的值 SRVAL。

同理，如果代码的敏感列表中不包含复位信号，那么就会综合出一个同步复位的 DFF，SR 端口将被配置为置位/复位端口(FDSE & FDRE primitive)。当 SR 变高时，FF 的输出值在下一个时钟的上升沿变为 SRVAL。

虽然 FPGA 的 FF 可以配额为 preset/clear/set/reset，但是一个单独的 FF 每次只能配置为其中的一种，如果在代码中多于一个 preset/clear/set/reset，那么就会产生其他的逻辑，消耗 FPGA 资源。

另外，基于 SRAM 的 FPGA 可以设定上电初始化的值：如果我们在定义 reg 变量时给它一个初始值，那么 FPGA 在上电配置(GSR 变高)时，载入这个值。

<br>

## Active low  V.S.  Active high
* * *

大多数书籍和博客都推荐使用 “低电平有效” 的复位方案，却没有明确说明为什么使用 “低电平有效”。

目前大多数书籍中都使用 低电平复位，网上给出的理由是

1. ASIC 设计大多数是低电平复位

2. 大多数厂商使用低电平复位多一些 (Xilinx 基本全是高电平复位，这也叫大多数？)

3. 低电平复位方式，在上电时系统就处于复位状态

[Verilog Verilog嵌入式数字系统设计教程][book1] 说明了原因：

> One reason for using active-low logic is that some kinds of digital circuits are able to sink more current when driving an output low than they can source when driving the output high. If such an output is used to activate some condition for which current flow is required, it would be better to use a low logic level rather than a high logic level.

也就是说目前推荐的 “低电平有效” 更多的是 IC 设计的传统，然而根据我查到资料来看，对于 Xilinx FPGA 这条传统并不适用。Xilinx 的器件全部是高电平复位端口，他们的 white paper 中的例子也都是高电平复位方式。而且，从综合结果来看，如果非要使用低电平复位，那么就会额外添加一个反相器，然后将反向得到的高电平连接到 FF 的复位端口，从而导致复位信号的传输时延增加，芯片的利用率下降，同时会影响到时序和功耗。

[How do I reset my FPGA][article1] 中也证实了这一点，文中提到对于 Xilinx 器件，尽可能使用高有效复位，如果实在没有办法控制系统的复位极性，那么最好在系统的顶层模块中将输入的低有效复位翻转极性，这样做的好处是反向器将被吸收到 IO logic 中，不会消耗 FPGA 内的逻辑和布线资源。

### Conclusion

1. 应该参考器件决定使用那种方式

2. 对于 Xilinx 器件，应该使用高电平复位方式

[book1]: http://book.douban.com/subject/3919870/
[article1]: http://www.eetimes.com/document.asp?doc_id=1278998

<br>

## Synchronous V.S. Asynchronous
* * *

因为 DFF 有两种复位端口，所以对应的有两种复位方式：同步复位 和 异步复位。两种复位方式各有特点，适用于不同的应用场景。下面先分别总结两种方案的优劣，最后总结当前流行的的主流复位方案。

### Synchronous Reset

模块的 `sensitivity list` 中不包含 `rst` 信号。

**code:**
        
    #!verilog
    always @(posedge clk) begin
        if (rst) begin
            q <= 1'b0;
        end
        else begin
            q <= d;
        end
    end

**RTL Schematic:**

![sync reset](/images/the-art-of-reset-design-in-fpga/sync_reset.png)

其中 `fdr` 是 Xilinx 的原语，表示 `Singal Data Rate D Flip-Flop with Synchronous Reset and Clock Enable (posedge clk)`

    #!verilog
    // FDRE: Single Data Rate D Flip-Flop with Synchronous Reset and
    //       Clock Enable (posedge clk).
    //       All families.
    // Xilinx HDL Language Template, version 13.3
    
    FDRE #(
       .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
    ) FDRE_inst (
       .Q(Q),      // 1-bit Data output
       .C(C),      // 1-bit Clock input
       .CE(CE),    // 1-bit Clock enable input
       .R(R),      // 1-bit Synchronous reset input
       .D(D)       // 1-bit Data input
    );

    // End of FDRE_inst instantiation

有时候，有些器件不带同步复位专用端口，那么综合器一般会将复位信号综合为输入信号的使能信号，这时候就需要额外的逻辑资源了。

#### Advantage

1. 保证设计是 100% 同步，有利于时序分析，也利于仿真

2. 降低亚稳态出现的几率，时钟起到过滤毛刺的作用(如果毛刺发生在时钟沿附近，那么仍然会出现亚稳态的问题)

3. 在某些设计中，复位信号是由内部逻辑产生的，推荐使用同步复位，因为这样可以避免逻辑产生的毛刺

#### Disadvantage

1. 同步复位需要保证复位信号具有一定的脉冲宽度(脉冲延展器)，使其能被时钟沿采样到

2. 在仿真过程中，同步复位信号可能被X态掩盖(?不懂...)

3. 如果设计中含有三态总线，为了防止三态总线的竞争，同步复位的芯片必须有一个上电异步复位

4. 如果逻辑器件的目标库内的 FF 只有异步复位端口，那么使用同步复位的话，综合器会将复位信号综合为输入信号的使能信号，这时候就需要额外的逻辑资源了。

    有很多教材和博客都直接说 “同步复位会产生额外的逻辑资源”，可能他们是基于 Altera 的 FPGA 这么做的，如下图所示：
    
    ![extra logic](/images/the-art-of-reset-design-in-fpga/extra_logic.png)
    
    但是根据我实际的测试结果，对于 Virtex 5 系列的芯片，它的原语里面已经含有各种带同步、异步复位端口的 FF，ISE 自带的 XST 也已经很智能了，它会根据代码分析，自动选择合适的 FF。所以上面同步复位综合出来的 RTL Schematic 中没有所谓的 “多余的逻辑资源”。
    
    所以，是否占用多余的资源，还得针对具体的芯片分析。
    
### Asynchronous

**code:**

    #!verilog
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 1'b0;
        end
        else begin
            q <= d;
        end
    end

**RTL Schematic:**

![aync reset](/images/the-art-of-reset-design-in-fpga/async_reset.png)

其中 `fdc` 是 Xilinx 的原语，表示 `Single Data Rate D Flip-Flop with Asynchronous Clear and Clock Enable (posedge clk)`

    #!verilog
    // FDCE: Single Data Rate D Flip-Flop with Asynchronous Clear and
    //       Clock Enable (posedge clk).
    //       All families.
    // Xilinx HDL Language Template, version 13.3
   
    FDCE #(
       .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
    ) FDCE_inst (
       .Q(Q),      // 1-bit Data output
       .C(C),      // 1-bit Clock input
       .CE(CE),    // 1-bit Clock enable input
       .CLR(CLR),  // 1-bit Asynchronous clear input
       .D(D)       // 1-bit Data input
    );
    
    // End of FDCE_inst instantiation

异步复位的优缺点和同步复位是相对应的：

#### Advantage

1. 脉冲宽度没有限制，可以快速复位

2. EDA 工具 route 起来更容易，对于大型设计，能显著减少编译时间

3. 没有时钟的时候也可以将电路复位 (比如省电模式下，同步复位无法工作，而异步复位是可以的)

4. 无需额外的组合逻辑 (同上，具体分析)

#### Disadvantage

1. 不是同步电路，不利于时序分析，设计者要正确约束异步复位信号比同步复位复杂

2. 复位信号容易收到毛刺的干扰

3. 容易在复位信号撤销的时候(release)不满足 `removal time` 时序要求，从而产生亚稳态 (关于亚稳态，网上有很多论文、博客都有详细说明)

### Reset Synchronizer

两种复位方式各有优缺点，设计者应该根据实际情况选择合适的复位方法。目前，很多文献书籍中都推荐一种 “异步复位，同步释放” 的方法。这种方法可以将两者结合起来，取长补短。

它的原理如下图所示

![reset synchronizer](/images/the-art-of-reset-design-in-fpga/reset_synchronizer.png)

需要注意到是，上图的复位是传统的低电平有效方式，对于 Xilinx 器件，原理图稍有不同，其复位按钮接到了 FF 的置位端，第一级 FF 的输入也由 `Vcc` 变为 `GND`。 [How do I reset my FPGA][article1] 介绍了对应的 RTL Schematic ：

![reset_synchronizer_xilinx](/images/the-art-of-reset-design-in-fpga/reset_synchronizer_xilinx.jpg)

对于 Xilinx 器件，用代码具体实现

**code:**

    #!verilog
    module SYSRST(
        clk, rst_pb, sys_rst
        );

        input       clk;
        input       rst_pb;

        output      sys_rst;
        reg         sys_rst;

        reg         rst_r;

        always @(posedge clk or posedge rst_pb) begin
            if (rst_pb) begin
                // reset
                rst_r <= 1'b1;
            end
            else begin
                rst_r <= 1'b0;
            end
        end

        always @(posedge clk or posedge rst_pb) begin
            if (rst_pb) begin
                // reset
                sys_rst <= 1'b1;
            end
            else begin
                sys_rst <= rst_r;
            end
        end

    endmodule

**RTL Schematic:**

![reset synchronizer](/images/the-art-of-reset-design-in-fpga/reset_synchronizer_rtl.png)

其中，`rst_pb` 是系统的复位按钮，`sys_rst` 是同步化的结果。可以看到综合结果和上图是一致的。

**Simulation:**

![simulation](/images/the-art-of-reset-design-in-fpga/reset_synchronizer_simulation.png)

所谓 “异步复位”，如上图(由于连接到了置位端，叫 “异步置位” 更合适)，一旦复位信号 `rst_pb` 有效，那么输出端口 `sys_rst` 立即被置为 `1`，否则输出为 `0`。

所谓 “同步释放”。如上图，当复位信号 `rst_pb` 释放时(从有效变为无效)，输出端口 `sys_rst` 不是立即变化，而是被 FF 延迟了一个时钟输出，从而使其和时钟同步化。这个和时钟同步化的复位信号可以有效的驱动后面的逻辑，避免亚稳态。

可以看到，这种 “异步复位，同步释放” 的方法既解决了同步复位中脉冲宽度的要求，又解决了异步复位中亚稳态的问题。

### Conclusion

知道了这点，选择复位信号的策略就很明显了：

1. 尽可能使用同步复位，保持设计 “同步化”

2. 如果器件本身是带有同步复位端口的，那么在写代码时就直接使用同步复位就可以了(CummingsSNUG2002SJ 也说了如果如果生产商提供同步复位端口，那么使用异步复位是毫无优点的。Xilinx 就是个例子，它所有的芯片都带有同步/异步复位端口)

4. 如果不带有同步复位端口，那么就需要使用这种异步复位同步化

<br>

*在详细讨论了复位的有效电平、复位方式之后，我们开始讨论稍微复杂一点的复位设计：包括系统的复位方案、多时钟域的复位方案、复位信号的去除毛刺等。*

## Think Local V.S. Think Global
* * *

我们使用复位信号的一个目的就是为了使电路可控，当上电时或者系统出错时，可以通过复位的方式回到正常状态。为了达到完全可控，传统的做法是对系统内的每个 FF 都连接复位信号，这样就造成了复位信号的高扇出，而高扇出会导致一系列的问题。

Xilinx 有个 White Paper，[Get Smart About Reset: Think Local, Not Global][wp272]，提出一种新的复位思路： 能不用全局复位时，尽量不要使用，这样可以降低复位信号的扇出。

这个原则和我们平时的理解和习惯是相反的，不使用全局复位的原因主要有三个：

1. 随着时钟速率的提高，GSR 逐渐变为时序关键路径

2. 如果电路中没有反馈环路，那么上电初始化已经足够了，很多设计中的 reset 信号都可以省去

    如果没有反馈环路，比如移位寄存器，即使开始状态是错误的，当数据流进入到一段时间，错误数据将被冲刷出去，所以没有必要保留 reset 信号。如果系统中有反馈环路，比如状态机，当初始状态不对或者状态跑飞时，无法回到正常状态，那么 reset 信号是有必要保留的。

3. 代码中简单的添加一个 reset 端口，在底层实现时要消耗很多我们想不到的资源。

    全局复位会和设计中的其他单元竞争布线资源，全局复位一般来说肯定有非常高的扇出，因为它需要连接到设计中的每一个 FF。这样，它会消耗大量的布线资源，使芯片利用率下降，同时也会影响时序性能。

所以，有必要使用其他的不依靠全局复位的方法。

如图所示，Xilinx FPGA 在配置/重配置的时候，每个 FF 和 BRAM 都会被初始化一个预先设定的值(大部分器件的默认值是 0, 也有例外)，所以，上电配置和全局复位有着类似的功能，将每个存储单元配置为一个已知的状态。

![configuration](/images/the-art-of-reset-design-in-fpga/configuration.jpg)

系统在上电配置时，内部有个信号叫 `GSR` (Global Set/Reset)，它是一种特殊的预布线的复位信号，能够在 FPGA 配置的过程中让设计保持初始状态。在配置完成后，GSR 会被释放，所有的触发器及其它资源都加载的是 INIT 值。除了在配置进程中自动使用 GSR，用户设计还可以通过实例化 STARTUP 模块并连接到 GSR 端口的方法来访问 GSR 网。使用该端口，设计者可以重新断言 GSR ，相应地 FPGA 中的所有存储元件将返回到它们的 INIT 属性所规定的状态。

设定初值的语法很简单，只需要在定义变量时给它初始值就可以了：

    #!verilog
    reg tmp = 0;

和 reg 类似，BRAM 也可以在配置的时候初始化，随着嵌入式系统的 BRAM 逐渐增大，BRAM 初始化非常有用：因为预先定义 RAM 的值可以使仿真更容易，而且无需使用引导序列为嵌入式设计清空内存。

使用 GSR 的好处是 **可以解决复位信号高扇出的问题**，因为 GSR 是预布线的资源，它不占用每个 FF 和 Latch 的 set/reset 端口，如下图所示。很多资料都推荐将设计中的 reset 按钮连接到 GSR，以利用它比较低的 skew。

![gsr rset](/images/the-art-of-reset-design-in-fpga/gsr_reset.gif)

既然 GSR 这么好，那么是不是只使用 GSR 就可以了，不必再用 FF 和 Latch 的 set/reset 端口了呢？

答案当然是否定的。由于 GSR 的释放是异步方式，所以，如果我们只使用 GSR 作为系统的唯一复位机制，那么可能导致系统不可靠。所以还是需要显式地使用同步复位信号来复位状态机、计数器等能自动改变状态的逻辑。

所以，应该使用 **GSR + explict reset** 的解决方案：

给系统中的 reg 赋初值，对于没有环路的电路节省 reset，利用 GSR 实现复位的功能；对于有环路的电路，使用显示的复位信号。

### Upate: 07/01/2014

1. 关于 initialize 代替 reset

    这几天看 resest 相关问题时，又在 `stackoverflow` 上发现一个关于[是否应该使用 initialize 代替 reset 的问题][stackoverflow]。

    支持用 initialize 代替 reset 的人提出的方案是尽量不要使用全局复位信号，使用初始化值代替复位，对于一些必须要求复位的模块，使用 *local* 的复位信号。

    反对者认为，用 initialize 代替 reset 的想法只是学院派的不切实际的想法。一般只有基于 SRAM 的 FPGA 才会使用到初始化。而这样做的目的只是为了节省布线资源，降低时序要求，但是现代 FPGA 有很多布线资源和没有使用的全局网络，所以，复位信号一般不是时序关键路径。即使遇到问题，可以通过手动例化一个时钟 BUF 来解决。使用这种无复位的设计虽然在某些情况是可行的，但是当你把你的设计和其他系统连接起来时，通常会感到非常痛苦，因为大多数系统都会要求有个复位信号。在由 FPGA 转 ASIC 时也比较方便，因为只有基于 SRAM 的 FPGA 才可以使用这种 initialize 代替 reset 的技术，而 ASIC 不行。

2. 关于 GSR

    网上有很多人都推荐将我们用户定义的复位信号连接到 GSR 信号上，以便利用 GSR 提供的低抖动性，包括 [How do I reset my FPGA][article1] 也推荐使用 GSR 信号。但是在 Xilinx 的另一份文档 [UG626: Synthesis and Simulation Design Guide][ug626] 中说不推荐使用 GSR 来作为系统的复位

    > Although you can access the GSR net after configuration, Xilinx does not recommend using the GSR circuitry in place of a manual reset. This is because the FPGA devices offer high-speed backbone routing for high fanout signals such as a system reset. This backbone route is faster than the dedicated GSR circuitry, and is easier to analyze than the dedicated global routing that transports the GSR signal.

    而这个矛盾早就有人在 Xilinx Forum 上提问了 [What does GSR signal really mean and how should I handle the reset signal properly][question1]，还有 [FPGA Power On Reset!][question2]。


** Conclustion**

应该优先选择有全局复位的设计方案，并且这个全局复位信号是用户定义的，不要使用 GSR 。

P.S. 事实上没有一个通用的、适合所有器件的复位方案，我们应该首先了解所使用的器件和工具，针对它们的特点进行复位方案的设计。

[wp272]: http://www.xilinx.com/support/documentation/white_papers/wp272.pdf
[stackoverflow]: http://stackoverflow.com/questions/6363130/is-there-a-reason-to-initialize-not-reset-signals-in-vhdl-and-verilog
[ug626]: http://www.xilinx.com/support/documentation/sw_manuals/xilinx14_7/sim.pdf
[question1]: http://forums.xilinx.com/t5/Virtex-Family-FPGAs/What-does-GSR-signal-really-mean-and-how-should-I-handle-the/td-p/35610
[question2]: http://forums.xilinx.com/t5/Archived-ISE-issues/FPGA-Power-On-Reset/m-p/7027?query.id=134602#M2035

<br>

### Shift Register Reset

并不是每一个设计，器件中的每一个寄存器都需要复位的。最好的做法是只将复位连接到那些需要复位的寄存器。一个典型特例就是移位寄存器的复位。

如果一个模块内部含有一组触发器(移位寄存器)，这些寄存器可以分为两类：

1. resetable flip-flops

    第一个 ff，它是需要复位信号的
    
2. follower flip-flops

    后续的 ff，仅作为简单的数据移位寄存器，不含复位端

那么在设计时应该只复位第一个触发器，后续的触发器仅作为数据寄存器使用，不能对它们进行复位。
这里体现出来的一个原则就是：能节省 reset 时，尽量节省。

原因就是 reset 作为一个实际存在的物理信号，需要占用 FPGA 内部的 route 资源，往往 reset 的fanout 又多得吓人。这就很容易造成 route 难度上升，性能下降，编译时间增加。因此，在 FPGA 设计中能省略的复位应尽量省略。

比较好的设计风格，不同类型的 FF 不应该组合进单个 alway 块中。也就是说，不要把这两种 FF 写在同一个 always 块中，而应该每个 `always` 模块只对一种 FF 建模。

**Bad Style:**

    #!verilog
    module BADSTYLE (
        clk, rst, d, q);
        
        input       clk;
        input       rst;
        input       d;
        
        output      q;
        reg         q;
        
        reg         tmp;
        
        always @(posedge clk) begin
            if (rst) begin
                tmp <= 1'b0;
            end
            else begin
                tmp <= d;
                q   <= tmp;
            end
        end
    
    endmodule
    
**RTL Schematic:**

如下图，复位信号 `rst` 对于第二个 ff 来说，是一个片选信号 `ce`，这样的设计产生额外的逻辑，是不好的。

![bad style](/images/the-art-of-reset-design-in-fpga/bad_style.png)

**Good Style:**

    #!verilog
    module GOODSTYLE (
        clk, rst, d, q
        );
        
        input       clk;
        input       rst;
        input       d;
        
        output      q;
        reg         q;
        
        reg         tmp;
        
        always @(posedge clk) begin
            if (rst) begin
                tmp <= 1'b0;
            end
            else begin
                tmp <= d;
            end
        end
        
        always @(posedge clk) begin
            q <= tmp;
        end
    
    endmodule
    
**RTL Schematic:**

如下图，复位信号 `rst` 对于两个 ff 来说，都是复位信号，不需要额外的逻辑，这样的设计是比较好的。

![good style](/images/the-art-of-reset-design-in-fpga/good_style.png)

<br>

## Reset Distribution Tree
* * *

复位信号的 `reset distribution tree` 和 时钟信号的 `clock distribution tree` 差不多同等重要，因为在设计中，几乎每个器件都有时钟端口和复位端口(同步/异步)。

reset distribution tree 和 clock distribution tree 如下图所示：

![reset tree](/images/the-art-of-reset-design-in-fpga/reset_tree.png)

系统中的主复位信号经过 reset distribution tree 达到每个元件，实现复位。`reset distribution tree` 和 `clock distribution tree` 最大的区别就是它们对 `skew` 的要求不同。由上面的讨论可知，复位信号和时钟的关系最好是“同步释放”，不像时钟信号的要求那么严格，复位信号之间的 skew 不需要那么严格，只要复位信号的延迟足够小，满足能在一个时钟周期内到达所有的复位负载端，并且满足各个 reg 和 flip-flop 的 `recovery time` 即可。

### in ASIC

在 ASIC 设计中，两种 tree 的关系有以下两种方式：

**方案一：**

驱动 reset tree 最安全的方法就是使用 clock tree 的叶子结点的时钟信号来驱动，如下图所示。如果采用这种方法，时序分析是满足的，那么就没有问题。

![reset tree driven delayed clock](/images/the-art-of-reset-design-in-fpga/reset_tree_delayed_clock.png)

分析以下情况：clock tree 中的一路叶子时钟信号驱动 `reset synchroinzer`，得到的复位信号 masterrst_n 穿过 reset tree，输入到 DFF 的复位端口；clock tree 的另外一路叶子时钟信号直接连接 DFF 的时钟端。

1. 理想情况下（时钟速率不高），reset 支路即使经过 reset synchronizer 和 reset tree，仍然满足 slack 为正，满足时序，电路可以正常工作。

2. 但是，在大多数情况下，时钟信号的频率都比较高，这些操作产生的延时太大，无法在一个时钟周期内完成，导致 slack 为负，此时无法满足时序要求。

**方案二：**

为了加速 reset 信号到达系统内的 DFF，使用进入 clock tree 之前的时钟信号来驱动 reset synchronizer，如图所示。这时候 reset 和 clock 是异步的，所以必须在 `PAR` 之后进行 `STA`，以保证

1. 若系统使用异步复位方式，则经过 reset tree 的复位信号释放(release)满足 `恢复时间(recovery time)`

2. 若系统使用同步复位方式，则经过 reset tree 的复位信号满足`建立时间(setup time)` 和 `保持时间(hold time)`。

一般来说，只有最后完成布局布线之后，才能根据具体情况进行分析调整 clock tree 和 reset tree。

![reset tree driven delayed clock](/images/the-art-of-reset-design-in-fpga/reset_tree_parallel_clock.png)

*对于 synchronou/asynchronous 两种 tree，可以用两种技术来进行优化：*

#### synchronous reset distribution tree

如下图所示，通过在 tree 中嵌入 DFF，这样 reset 信号就不必在一个时钟周期内到达每一个 DFF 的复位端口，从而可以把 reset 信号的时序要求降得很低。在每个模块中，输入的 reset 信号首先经过一个 DFF，然后把经过 DFF 延迟输出的复位信号用作复位信号来复位逻辑、驱动子模块。每个 module 里面都含有以下代码：

![synchronous reset](/images/the-art-of-reset-design-in-fpga/synchronous_reset_distribution.png)

**code**

    #!verilog
    input    reset_raw;

    // synchronous reset
    always @(posedge clk) reset <= reset_raw;

reset_raw 是本模块的输入复位信号，reset 为经过 DFF 后的本地（local）复位信号，同时也连接子模块 reset_raw 的输入。

**Advantage**

1. 降低 reset 的时序要求

2. 降低 reset 的扇出

3. 利于时序工具分析

**Disadvantage**

1. 需要多个时钟周期才能复位

#### asynchronous reset distribution tree

和同步复位类似，异步复位也可以采用相同的策略，如下图所示：

![asynchronous reset](/images/the-art-of-reset-design-in-fpga/asynchronous_reset_distribution.png)

利用前面讨论过的 reset synchronizer 将异步复位信号同步到每个子模块当中。

和 synchronous reset 一样，在 reset tree 中加入 synchronizer 之后，复位功能需要多个时钟周期才能完成。

#### Problem

因为不同的子模块深度不同，所以不同模块可能不是同时复位的（同一个时钟周期）。这种情况是否会引起问题，依应用情况而定，大多数设计都没有问题，但是如果要求一定要在同一时钟周期复位，那么就要平衡不同子模块内的 synchronizer 数量，无论是 synchronous 还是 asynchronous 都是一样的。

#### Advantage

前面讨论的 reset tree 和 clock tree 主要问题就是两者是异步的，一定要保证 reset 的释放满足 recovery time，在 P&R 之后，时序分析如果不满足的话，设计者需要手动调整时序，然后重新 P&R，时序分析直到满足为止。

作为对比，如果采用这里插入 synchronizer 的方法，则免去了手动调整的工作，让综合工具完成时序分析和调整工作。经过调整之后，全局（global）复位信号就变为本地（local）复位信号了。（synchronous 也一样，变为 local reset）

### in FPGA

对于 FPGA，因为系统的 clock tree 是预先布线好的，而全局主复位信号一般也使用时钟布线资源，所以不存在两棵 tree 之间关系的调整问题，所以只需要采用上面的 synchronou/asynchronous reset distribution tree 即可。

<br>

## Multi-clock Reset
* * *

在一个系统中，往往有多个时钟，这时候有必要为每个时钟域分配一个复位信号。

因为只有一个全局复位的话，它与系统的时钟都没有关系，是异步复位信号，要求这个信号满足所有时钟域的 recovery 和 removal 时序不是一件容易的事情，因此为每个时钟域分配复位是有必要的。

根据实际情况的不同，有两种方案可以采用：

**Non-coordinated reset removal**

对于多时钟域的设计，很多时候不同时钟域之间复位信号的先后顺序没有要求，尤其是在有 `request-acknowledge` 这样握手信号的系统中，不会引起硬件上的错误操作，这时候下图所示的方法就足够了。

![non coordinated reset](/images/the-art-of-reset-design-in-fpga/non_coordination.png)

**Sequenced coordination of reset removal**

对于一些设计，要求复位信号的释放顺序有一定顺序，这时候应该使用下图所示的方法

![sequenced rcoordination](/images/the-art-of-reset-design-in-fpga/sequenced_coordination.png)

[How do I reset my FPGA][article1] 在文中提供了一张图来说明典型的系统复位方案，图中 `MMCM` 的 `lock` 和外部输入的复位信号相与，目的是为了保证提供给后面的同步器的时钟信号是稳定的；每个时钟域都有一个同步器来同步复位信号。

![typical reset implementation in FPGA](/images/the-art-of-reset-design-in-fpga/typical_reset.jpg)

<br>

## Reset Glitch Filtering
* * *

最后讨论一下复位信号毛刺的问题。

使用异步复位信号时，考虑到异步复位信号对毛次比较敏感，所以在一些系统中需要处理毛次，下图显示了一种简单但是比较丑陋的方法(时延不是固定的，会随温度、电压变化)

![reset glitch filtering](/images/the-art-of-reset-design-in-fpga/reset_glitch_filtering.png)

需要注意的是

1. `毛刺 Glitch` 是一个很重要的问题，不论是对于时钟、复位信号还是其他信号，详细讨论待续

2. 不是所有的系统都需要过滤毛刺，设计者要先研究需求，再觉得是否使用延时来过滤毛次

<br>

## Summary
* * *

本文是读书笔记，总结了参考资料中的复位信号的设计方法和需要注意的问题，包含了底层的 DFF 复位方式、高/低电平有效、同步/异步复位、和系统级的复位方案选择、设计。

1. 应该参考器件决定使用那种方式

2. 对于 Xilinx 器件，应该使用高电平复位方式

3. 尽可能使用同步复位，保持设计 “同步化”

4. 如果器件本身是带有同步复位端口的，那么在写代码时就直接使用同步复位就可以了(CummingsSNUG2002SJ 也说了如果如果生产商提供同步复位端口，那么使用异步复位是毫无优点的。Xilinx 就是个例子，它所有的芯片都带有同步/异步复位端口)

5. 如果不带有同步复位端口，那么就需要使用这种异步复位同步化

6. 应该优先选择有全局复位的设计方案，并且这个全局复位信号是用户定义的，不要使用 GSR 。

7. 采用 synchronou/asynchronous reset distribution tree 可以降低 reset 信号的时序要求，减小扇出

8. 每个时钟域都应该有一个同步器来同步复位信号。

<br>

## Reference

[Synchronous Resets? Asynchronous Resets? I am so confused! How will I ever know which to use?](http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_Resets.pdf)

[Asynchronous & Synchronous Reset Design Techniques - Part Deux](http://www.sunburst-design.com/papers/CummingsSNUG2003Boston_Resets.pdf)

[Get Smart About Reset: Think Local, Not Global][wp272]

[How do I rest my FPGA][article1]

[FPGA复位电路的实现及其时序分析](http://www.eefocus.com/coyoo/blog/13-12/301045_9c39f.html)

[深入浅出玩转 FPGA](http://book.douban.com/subject/4893454/)

[100 Power Tips for FPGA Designers](http://item.jd.com/11337565.html)

[Advanced FPGA Design by Steve Kilts](http://www.amazon.com/Advanced-FPGA-Design-Architecture-Implementation/dp/0470054379)
