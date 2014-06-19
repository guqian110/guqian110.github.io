Title: FPGA 中的复位设计
Date: 2014-06-20 00:22
Category: FPGA
Tags: FPGA, reset
Slug: the_art_of_reset_design_in_fpga
Author: Chien Gu
Summary: 总结 FPGA 中的复位设计


复位信号在系统中的地位和时钟信号几乎同等重要，我们想尽量把系统设计为可控，那么最基本的控制信号就是复位信号了。

复位信号的设计需要考虑的因素，各种书刊、论文、白皮书、网上论坛都有相关讨论，但是至今对于给定 FPGA 设计中使用哪种复位方案仍然没有明确答案。本文总结了一些大神的经典论文和网上的许多博客，尽可能用简单的图说明选择某种设计方案及其理由，涉及的更深入的原理请自行 Google :-P
 
<br>

## Active low  V.S.  Active high
* * *

大多数书籍和博客都推荐使用 “异步复位，低电平有效” 的复位方案，却没有明确说明为什么使用 “低电平有效”。

目前大多数书籍中都使用 低电平复位，网上给出的理由是

1. ASIC 设计大多数是低电平复位

2. 大多数厂商使用低电平复位多一些 (Xilinx 基本全是高电平复位，这也叫大多数？)

3. 低电平复位方式，在上电时系统就处于复位状态

但是从我找到的资料来看， Xilinx 的器件全部是高电平复位端口，他们的 white paper 中的例子也都是高电平复位方式。而且，从综合结果来看，如果非要使用低电平复位，那么就会额外添加一个反相器，然后将反向得到的高电平连接到 FF 的复位端口。

所以，个人观点：

1. 应该参考器件决定使用那种方式

2. 对于 Xilinx 器件，应该使用高电平复位方式

<br>

## Synchronous V.S. Asynchronous
* * *

### Synchronous Reset

模块的 `sensitivity list` 中不包含 `rst` 信号。

**code:**
        
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

有时候，有些器件不带同步复位专用端口，这时候一般会将复位信号综合为输入信号的使能信号，这时候就需要额外的逻辑资源了。

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
    
    ![extra logic](/images/the-art-of-reset-design-in-fpga/extra_reset.png)
    
    但是根据我实际的测试结果，对于 Virtex 5 系列的芯片，它的原语里面已经含有各种带同步、异步复位端口的 FF，ISE 自带的 XST 也已经很智能了，它会根据代码分析，自动选择合适的 FF。所以上面同步复位综合出来的 RTL Schematic 中没有所谓的 “多余的逻辑资源”。
    
    所以，是否占用多余的资源，还得针对具体的板子分析。
    
### Asynchronous

**code:**

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

![reset synchronizer](/imags/the-art-of-reset-degign-in-fpga/reset_synchronizer.png)

针对 Xilinx 器件，用代码具体实现

**code:**

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

其中，`rst_pb` 是系统的复位按钮，`sys_rst` 是同步化的结果。前面的原理图是按照低有效复位说明的，而 Xilnx 的 FPGA 都是高有效复位，所以综合出的 RTL 图则正好相反，复位按钮接到了 FF 的置位端，第一级 FF 的输入也由 `Vcc` 变为 `GND`。

**Simulation:**

![simulation](/images/the-art-of-reset-design-in-fpga/reset_synchronizer_simulation.png)

所谓 “异步复位”，如上图(由于连接到了置位端，叫 “异步置位” 更合适)，一旦复位信号 `rst_pb` 有效，那么输出端口 `sys_rst` 立即被置为 `1`，否则输出为 `0`。

所谓 “同步释放”。如上图，当复位信号 `rst_pb` 释放时(从有效变为无效)，输出端口 `sys_rst` 不是立即变化，而是被 FF 延迟了一个时钟输出，从而使其和时钟同步化。这个和时钟同步化的复位信号可以有效的驱动后面的逻辑，避免亚稳态。

可以看到，所谓的这种 “异步复位，同步释放” 的方法，其本质就是要 **利用异步复位来产生一个同步复位的功能。**

为什么不直接使用异步复位呢？因为异步复位容易产生亚稳态的问题。

为什么不直接使用同步复位呢？因为很多器件只有异步复位端口，不支持同步复位端口，如果要使用同步复位，就会产生额外的逻辑，消耗资源。

所以，这种方法的根本思想就是 **异步信号同步化**。

#### Conclusion

知道了这点，选择复位信号的策略就很明显了：

1. 尽可能使用同步复位，保持设计 “同步化”

2. 如果器件本身是带有同步复位端口的，那么在写代码时就直接使用同步复位就可以了(Xilinx 所有的芯片都带有同步/异步复位端口)

4. 如果不带有同步复位端口，那么就需要使用这种异步复位同步化

<br>

## Reset Distribution Tree
* * *

复位信号的 `reset distribution tree` 和 时钟信号的 `clock distribution tree` 差不多同等重要，因为在设计中，几乎每个器件都有时钟端口和复位端口(同步/异步)。

`reset distribution tree` 和 `clock distribution tree` 最大的区别就是它们对 `skew` 的要求不同。不像时钟信号的要求那么严格，复位信号之间的 skew 不需要那么严格，只要复位信号的延迟足够小，满足能在一个时钟周期内到达所有的复位负载端，并且满足各个寄存器和触发器的 `recovery time` 即可。

**方案一：**

下图所示的方案是使用 时钟树 的一个叶子分支来驱动 `Reset Synchronizer`。但是，大多数情况下，时钟频率都比较高，叶子分支的时钟无法在一个时钟周期内，既要穿过时钟树，还要驱动 `Reset synchroinzer`，然后再将得到的复位信号穿过 复位树，输入到负载端口。

![reset tree driven delayed clock](/iamges/the-art-of-reset-design-in-fpga/reset_tree_delayed_clock.png)

**方案二：**

为了加速 reset 信号到达触发器，触发器使用的时钟与 reset 信号是并行的。如图所示。但是，这时候 reset 和 clock 是异步的，所以必须在 `PAR` 之后进行 `STA`，保证异步复位信号释放(release)和使能(enable)时满足 `建立时间(setuo time)` 和 `保持时间(hold time)`。

![reset tree driven delayed clock](/iamges/the-art-of-reset-design-in-fpga/reset_tree_parallel_clock.png)

<br>

## Reset Glitch Filtering
* * *

使用异步复位信号时，考虑到异步复位信号对毛次比较敏感，所以在一些系统中需要处理毛次，下图显示了一种简单但是比较丑陋的方法(时延不是固定的，会随温度、电压变化)

![reset glitch filtering](/iamges/the-art-of-reset-design-in-fpga/reset_glitch_filtering.png)

需要注意的是

1. `毛刺 Glitch` 是一个很重要的问题，不论是对于时钟、复位信号还是其他信号，详细讨论待续

2. 不是所有的系统都需要过滤毛次，设计者要先研究需求，再觉得是否使用延时来过滤毛次

<br>

## Multi-clock Reset
* * *

在一个系统中，往往有多个时钟，这时候有必要为每个时钟域分配一个复位信号。

因为只有一个全局复位的话，它与系统的时钟都没有关系，是异步复位信号，要求这个信号满足所有时钟域的 recovery 和 removal 时序不是一件容易的事情，因为为每个时钟域分配复位是有必要的。

根据实际情况的不同，有两种方案可以采用：

**Non-coordinated reset removal**

对于多时钟域的设计，很多时候不同时钟域之间复位信号的先后顺序没有要求，尤其是在有 `request-acknowledge` 这样握手信号的系统中，不会引起硬件上的错误操作，这时候下图所示的方法就足够了。

![non coordinated reset](/iamges/the-art-of-reset-design-in-fpga/non_coordination.png)

**Sequenced coordination of reset removal**

对于一些设计，要求复位信号的释放顺序有一定顺序，这时候应该使用下图所示的方法

![sequenced rcoordination](/iamges/the-art-of-reset-design-in-fpga/sequenced_coordination.png)

<br>

## Shift Register Reset
* * *

并不是每一个设计，器件中的每一个寄存器都需要复位的。最好的做法是只将复位连接到那些需要复位的寄存器。

如果一个模块内部含有一组触发器(移位寄存器)，这些寄存器可以分为两类：

1. resetable flip-flops

    第一个 ff，它是需要复位信号的
    
2. follower flip-flops

    后续的 ff，仅作为简单的数据移位寄存器，不含复位端

那么在设计时应该只复位第一个触发器，后续的触发器仅作为数据寄存器使用，不能对它们进行复位。
这里体现出来的一个原则就是：能节省 reset 时，尽量节省。

原因就是 reset 作为一个实际存在的物理信号，需要占用 FPGA 内部的 route 资源，往往 reset 的fanout 又多得吓人。这就很容易造成 route 难度上升，性能下降，编译时间增加。因此，在 FPGA 设计中能省略的复位应尽量省略。

### Principle

每个 `always` 模块只对一种 FF 建模。也就是说，不要把这两种 FF 写在同一个 always 块中。

### Code

**Bad Style:**

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

如图，复位信号 `rst` 对于第二个 ff 来说，是一个片选信号 `ce`，这样的设计产生额外的逻辑，是不好的。

![bad style](/images/the-art-of-reset-design-in-fpga/bad_style.png)

**Good Style:**

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

如图，复位信号 `rst` 对于两个 ff 来说，都是复位信号，不需要额外的逻辑，这样的设计是比较好的。

![good style](/images/the-art-of-reset-design-in-fpga/good_style.png)

<br>

## Think Local, Not Global
* * *

我们应该遵守一个原则：能不用全局复位时，尽量不要使用。

这个原则和我们平时的理解和习惯是相反的，Xilinx 官方有个 white paper  [Get Smart About Reset: Think Local, Not Global][wp272]，专门讲了尽量避免使用 GSR，原因主要有三个：首先，随着时钟速率的提高，GSR 逐渐变为时序关键路径；其次，如果电路中没有反馈环路，那么上电初始化已经足够了，很多设计中的 reset 信号都可以省去；最后，代码中简单的添加一个 reset 端口，在底层实现时要消耗很多我们想不到的资源。

[wp272]: http://www.xilinx.com/support/documentation/white_papers/wp272.pdf

<br>

## Reference

[Synchronous Resets? Asynchronous Resets? I am so confused! How will I ever know which to use?](http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_Resets.pdf)

[Asynchronous & Synchronous Reset Design Techniques - Part Deux](http://www.sunburst-design.com/papers/CummingsSNUG2003Boston_Resets.pdf)

[Get Smart About Reset: Think Local, Not Global][wp272]

[FPGA复位电路的实现及其时序分析](http://www.eefocus.com/coyoo/blog/13-12/301045_9c39f.html)

[深入浅出玩转 FPGA](http://book.douban.com/subject/4893454/)

[100 Power Tips for FPGA Designers](http://item.jd.com/11337565.html)

[Advanced FPGA Design by Steve Kilts](http://www.amazon.com/Advanced-FPGA-Design-Architecture-Implementation/dp/0470054379)
