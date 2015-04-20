Title: FPGA 时钟设计 3 —— 跨时钟域设计
Date: 2014-10-09 23:01
Category: FPGA
Tags: clock design
Slug: the_clock_design_in_fpga_3_multiasynchronous_clock_design
Author: Qian Gu
Summary: 总结 FPGA 中跨时钟域的设计


## Problem
* * *

在前面一篇总结 [Latch V.S. Flip-flop][blog1] 的博文中，已经解释了 flip-flop 的一些参数：建立时间 `setup time`、保持时间 `hold time`、恢复时间 `recovery time`、撤销时间 `removal time`。

如果不满足这些参数的要求，则会发生所谓的 亚稳态 `Metastability` 的问题。下面是 Altera 官方的一篇关于亚稳态的 white paper，详细介绍了亚稳态的产生原因、它是如何导致设计出现问题、以及描述它的参数 MTBF (Mean Time Between Failures) 如何计算。

[Understanding Metastability in FPGAs][wp-01082]

我们知道，一般只涉及单时钟域的设计并不多见，尤其是对于一些复杂的应用，FPGA 往往需要和多个时钟域的信号进行通信，而这些时钟之间的关系一般都是频率不同、相位也不同，也就是不同频不同相的多异步时钟域设计 `Mulit-Asynchronous Clock Design`。

因为这些时钟信号之间的关系一般既不同频也不同相，所以一个时钟域的信号对于另外一个时钟域来说是异步信号，那么就无法保证进入新时钟域的信号和新的时钟信号之间满足 setup/hold time 的要求，自然就会引起亚稳态的问题。

在 Clifford E. Cummings 大神的 paper：[Synthesis and Scripting Techniques for Designing Multi-Asynchronous Clock Designs][paper1] 里面就举例说明了这种现象：

**Reason**

> "When sampling a changing data signal with a clock ... the order of the events determines the outcome. The smaller the time difference between the events, the longer it takes to determine which came first. When two events occur very close together, the decision process can take longer than the time allotted, and a synchronization failure occurs."

**Illustation 1: **

![failure](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/synchronization_failure.png)

**Illustation 2: **

如果不加处理，亚稳态产生的错误值将会传播到设计的其他部分，导致更加严重的问题

![propagatetion](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/propagation.png)

[blog1]: http://guqian110.github.io/pages/2014/09/23/latch_versus_flip_flop.html
[wp-01082]: http://www.altera.com.hk/literature/wp/wp-01082-quartus-ii-metastability.pdf
[paper1]: http://www.sunburst-design.com/papers/CummingsSNUG2001SJ_AsyncClk.pdf

<br>

## Synchronous Design
* * *

多时钟域导致的亚稳态的问题的根本原因就是：信号和时钟是异步的，也就是设计不是同步设计 `Synchronous Design`。

**同步化设计思想** 是 FPGA 中非常重要的原则：

**Asynchronous Circuits**

同步电路的核心逻辑是用 组合逻辑 `combination logic` 实现的，比如异步FIFO/RAM 读写信号、地址译码等电路。电路的主要信号、输出信号不依赖任何一个时钟信号，不是由时钟信号驱动 flip-flop 产生的。*异步电路最大的缺点就是容易产生毛刺。*

**Synchronous Circuits**

同步电路的核心逻辑是用 时序逻辑 `sequential logic` 实现的。电路的主要信号、输出信号是由某个时钟沿驱动 flip-flop 产生的。*同步电路可以很好的避免毛刺。*

**Synchronous V.S. Asynchronous**

[Xilinx FPGA高级设计及应用](http://book.douban.com/subject/10593491/)

> 从 ASIC 设计的角度来看，大约需要 7 个门来实现一个 D 触发器，而一个门即可实现一个2输入与非门，所以一般来说，在 ASIC 设计中，同步时序电路比异步电路占用更大的面积。但是，由于 FPGA 是定制好的底层单元，对于 Xilinx 器件，一个底层可编程单元 Slice 包含两个触发器（FF）和一个查找表（LUT）。其中触发器用以实现同步电路，查找表用以实现组合电路。FPGA 最终使用率用 Slice 来衡量。所以对于某个选定器件，其可实现的同步电路和异步电路的资源数量和比例是固定的，这点造成了过度使用查找表会浪费触发器资源，反之亦然。因而对于 FPGA，同步时序设计不一定比异步设计多消耗资源。单从节约资源的角度考虑，应该按照芯片配置的资源比例实现设计，但是设计者还要时刻权衡同步设计没有毛刺、信号稳定等优点，**所以对于 FPGA 设计推荐采用同步设计。**

> 无论是用离散逻辑、可编程逻辑，还是用全定制硅器件实现的任何数字逻辑，为了成功操作，可靠的时钟是非常关键的。
> 
> ...
>
> **因为，FPGA 同步设计中最好的时钟解决方案是由专用全局时钟输入引脚驱动单个主时钟去控制设计项目中的每一个触发器。系统中各个功能模块使用同一同步复位信号。**
>
> ...
>
> **FPGA 同步设计中，时序电路应尽量采用同步电路，尽可能使用同步器件，尽量减小或不使用门控时钟（为了降低系统功耗以外）。设计中不用系统主时钟经过逻辑运算得到控制信号，避免使用非时钟信号作为触发器的时钟输入。**

下面提到的所有方法，就是同步化思想的应用，其核心目的就是将本时钟域外的 **异步信号同步化**。

<br>

## Solution
* * *

### Solution 1: Daul Rank Synchronizer

通常使用 `MTBF (Mean Time Between Failures)` 来描述 flip-flop 亚稳态指标，MTBF 越大，表示出现故障的间隔越大，表示设计越可靠。

以一个典型的 0.25 us 工艺的 ASIC 库中的 flip-flop 的参数计算可以得到 MTBF = 2.01 d，即两天就会出现一次亚稳态。显然这是不能接受的，但是如果将两个 flip-flop 级联在一起，计算结果则变成了 9.57×109 years，显然这个概率基本就可以忽略不计，可以看作是消除了亚稳态。

理论上，亚稳态是不可能完全消除的，一般级联多少个 flip-flop，由实际指标要求和设计者的强迫症习惯决定，对于普通的应用来说，2 级 flip-flop 级联已经足够了。

如图所示：

![synchronizer](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/synchronizer.png)

通常，同步器 synchronizer 由两个 flip-flop 串联而成，它们中间没有其他的组合电路。第一个 flip-flop 有很大的可能性会产生亚稳态，但是当第二个 flip-flop 获得前一个 flip-flop 的输出时，前一个 flip-flop 已经退出了亚稳态，并且输出稳定，这样就避免了第一级 flip-flop 的亚稳态对下一级逻辑造成的影响。

为了让 synchronizer 正常工作，从某个 时钟域传递过来的信号应该先通过原时钟域的一个 flip-flop，然后不经过两个时钟域间的任何组合逻辑，直接进入 synchronizer。之所以这样要求，是因为 synchronizer 的第一级 flip-flop 对组合逻辑产生的毛刺非常敏感，如果一个足够长的信号毛刺正好满足 setup/hold time 的要求，那么它就会通过 synchronizer，给新时钟域后续逻辑一个虚假的信号。

synchronizer 有很多设计方法，因为一种方法不能满足所有的应用需求。synchronizer 的类型基本上分为 3 种：

1. level synchronizer

2. edge-detecting synchronizer

3. pulse synchronizer

下面分别讨论：

#### level synchronizer

**Schematic:**

电平同步器的结构图就是前面的图，在 Clifford E. Cummings 的 [paper][paper1] 中有更详细的图解说明：

![level](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/level.png)

**Code:**

    #!verilog
    module LVLSYNC(
        input           clk_src, 
        input           rst_src,
        input           dat_src, 

        input           clk_dst,
        input           rst_dst, 
        output  reg     dat_dst
        );
    
        /////////////////////////////////////////////////////////////
        // source time domain
        /////////////////////////////////////////////////////////////
        reg         dat;
    
        always @(posedge clk_src) begin
            if (rst_src) begin
                dat <= 1'b0;
            end
            else begin
                dat <= dat_src;
            end
        end
    
        ////////////////////////////////////////////////////////////
        // destination time domain
        ////////////////////////////////////////////////////////////
        reg         dat_r;
    
        // using two level DFF to synchronize the din_q
        always @(posedge clk_dst) begin
            if (rst_dst) begin
                dat_r   <= 1'b0;
                dat_dst <= 1'b0;
            end
            else begin
                dat_r   <= dat;
                dat_dst <= dat_r;
            end
        end
    
    endmodule

**RTL:**

![level rtl](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/lvl_rtl.png)

**Restriction:**

使用 level synchronizer 的要求是：

1. 源时钟域的信号应先通过源时钟域的一个 DFF 后输出，然后直接进入目的时钟域的 synchronizer 的第一级 DFF。这样做的

    这么做到原因是：synchronizer 的第一级 DFF 对组合逻辑产生的毛刺（glitch）非常敏感。如果一个足够长的毛刺刚好满足了 setup/hold time，那么 synchronizer 会将其放行，产生一个虚假的信号。

2. 跨域时钟域的这个信号持续时间 >= 2 个新时钟域时钟周期。

    虽然 [Crossing the abyss: asynchronous signals in a synchronous world][paper2] 中是这么写的，但是我觉得这个条件应该是保险条件，而不是最低条件。level synchronizer 的最低条件应该和 edge-detecting synchronizer 相同：

    输入信号的宽度 >= 目标时钟域周期 + 第一个 flip-flop 的 hold time。

    首先，待同步到信号宽度 > 源时钟周期，这样它才能被源时钟域的 DFF 采样到，然后输出；

    其次，源时钟域采样输出端信号的宽度当然是源时钟周期的整数倍，它的宽度 > 目标时钟域周期 + 第一个 flip-flop 的 hold time，这样它才能被目的时钟域的时钟采样到，然后进行同步。

    所以，保险一点的条件是：待同步到信号有效时间至少是目的时钟周期的 2 倍。

*level synchronizer 是其他两种同步器的基础：*

#### edge-detecting synchronizer

边沿检测同步器 是在 level synchronizer 的输出端增加了一个 flip-flop，如下图所示。这个电路的功能是实现上升沿检测，产生一个和时钟周期等宽，高电平有效的脉冲；如果将与门的两个输入端交换，则会完成下降沿检测。如果改为非门，则可以得到一个低电平脉冲有效的电路。

**Schematic:**

![edge-detecting](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/edge-detecting.png)

**Code:**

    #!verilog
    module EDGESYNC(
        input   clk_src,
        input   rst_src, 
        input   dat_src, 
    
        input   clk_dst, 
        input   rst_dst,
        output  dat_dst
        );
    
        /////////////////////////////////////////////////////////////
        // source time domain
        /////////////////////////////////////////////////////////////
        reg     dat;
    
        always @(posedge clk_src) begin
            if (rst_src) begin
                dat <= 1'b0;
            end
            else begin
                dat <= dat_src;
            end
        end
    
        ////////////////////////////////////////////////////////////
        // destination time domain
        ////////////////////////////////////////////////////////////
        reg     [2:0]   sync_reg;
    
        always @(posedge clk_dst) begin
            if (rst_dst) begin
                sync_reg <= 3'b0;
            end
            else begin
                sync_reg <= {sync_reg[1:0], dat};
            end
        end
    
        // AND to get the output
        assign dat_dst = sync_reg[1] && (~sync_reg[2]);

    endmodule
    
**RTL:**

...

**Restriction:**

使用 edge-detecting synchronizer 的要求是：

1. 输入信号的宽度 >= 目标时钟域周期 + 第一个 flip-flop 的 hold time。最保险的脉冲宽度是同步周期的两倍。

    实际上，因为在源时钟域，要先用 DFF 寄存一下再输出，所以源时钟域输出的信号的宽度是其时钟周期的整数倍，它肯定是 > 目标时钟周期的，因为 edge-detecting synchronizer 只能工作在慢时钟域到快时钟域的情况下。

*edge-detecting synchronizer 在将一个慢时钟域的信号同步到一个较快时钟域时可以正常工作，它会产生一个脉冲表示输入信号的上升沿或者下降沿。但是反过来，将一个快时钟域的信号同步到慢时钟域时，并不能正常工作，这时候需要使用 pusle synchronizer。*

#### pulse synchronizer

脉冲同步器的基本功能是从某个时钟域中取出一个单时钟宽度的脉冲，然后在新的时钟域中建立另外一个单时钟宽度的脉冲。

源时钟域的单时钟宽度的脉冲不是直接输出的，而是先经过一个源时钟域的翻转电路。这个翻转电路在每次输入一个脉冲时，它的输出会在高、低电平之间翻转。

而在目的时钟域，翻转电路的输出先通过一个 level synchronizer，其输出到达异或门的一个输入端，而这个输出再经过一个 DFF，延时一个时钟周期后进入异或门的另外一个输入端。最后异或门的输出即最终的同步结果：

源时钟域每有一个单时钟脉冲（源时钟），synchronizer 的输出端产生一个单时钟宽度（目的时钟）的脉冲。

**Schematic:**

![pusle](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/pulse.png)

**Code:**

    module PULSESYNC(
        input   clk_src,
        input   rst_src,
        input   pulse_src,
    
        input   clk_dst,
        input   rst_dst,
        output  pulse_dst
        );
    
        ///////////////////////////////////////////////////
        // source time domain
        ///////////////////////////////////////////////////
        reg toggle_reg;
    
        always @(posedge clk_src or posedge rst_src) begin
            if (rst_src) begin
                toggle_reg <= 1'b0;
            end
            else begin
                if (pulse_src) begin
                    toggle_reg <= ~toggle_reg;
                end
            end
        end
    
        ///////////////////////////////////////////////////
        // destination time domain
        ///////////////////////////////////////////////////
        reg     [2:0]   sync_reg;
    
        always @(posedge clk_dst) begin
            if (rst_dst) begin
                sync_reg <= 3'b0;
            end
            else begin
                sync_reg <= {sync_reg[1:0], toggle_reg};
            end
        end
    
        // XOR to generate the pusle_dst
        assign pulse_dst = sync_reg[1] ^ sync_reg[2];

    endmodule

**RTL:**

...

**Restriction:**

使用 pusle synchronizer 的要求是：

1. 输入脉冲之间的最小间隔 >= 2 个同步时钟周期。如果两个输入脉冲相互过近，则新时钟域的输出脉冲也会紧密相邻，形成一个比单时钟周期宽的输出脉冲。

    实际上，在一些情况下，少于 2 个时钟周期（> 1 个时钟周期）也是可以同步上的。只要 synchronizer 的两个 DFF 的值不一样即可同步上，也就是说异步信号在连续的两个目的时钟采样的值不同即可，由于异步信号和时钟的相位关系不确定，所以在没有对齐的情况下，大于 1 个时钟时也能满足两个采样值不同的条件。

    一般为了保险起见，要求其保持至少两个时钟宽度。

#### Timing

synchronizer 需要花费 1～2 个时钟周期来完成同步，所以粗略的估计可以认为 synchronizer 会造成目的时钟域的 2 个周期的延迟，我们在设计时需要考虑 synchronizer 对时序产生的影响。

#### Summary

总结 3 种同步器的特点，有下表：

![synchronizer sum](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/synchronizer_sum.png)

虽然还有其他类型的 synchronizer，但是这 3 种基本上就可以解决设计中遇到的多数问题了。

<br>

*synchronizer 仅适用于简单的数据跨时钟域传输的同步，除了简单的信号之外，还有数据、地址、控制总线信号等也要跨时钟域。对于这些需求，可以使用其他的工具，比如握手协议、FIFO 等。*

<br>

### Solution 2: Handshaking

> Handshaking allows digital circuits to effectively communicate with each other when the response time of one or both circuits is unpredictable. For example, an arbitrated bus allows more than one circuit to request access to a single bus, such as PCI or AMBA (Advanced Microcontroller Bus Architecture), using arbitration to determine which circuit gains access to the bus. Each circuit signals a request, and the arbitration logic determines which request “wins.” This winning circuit receives an acknowledgment indicating that it has access to the bus. It then discontinues its request and begins the bus transaction.

大意就是：对于（单边/双边）电路响应时间不确定的应用，握手协议可以有效地传输信号。比如（PCI、AMBA）总线仲裁电路，有多个电路申请访问总线时，每个电路都发出请求，由仲裁电路来决定哪个有访问权。“获胜” 的电路会收到确认信号，然后才可以访问总线。

这种交互方式就是握手协议，简而言之就是双方首先要握手达成一致，然后才能传输数据。

有两种基本握手协议：

1. Full-handshaking

2. Partial-handshaking

这两种握手协议都要用到 synchronizer，每种都有各自的优缺点，下面分别讨论：

#### full handshaking

![full](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/full.png)

如图所示，全握手协议中，双方电路在声明或中止各自的握手信号前都要等待对方的相应。首先，发送方电路A声明它的请求信号，然后接收方电路B检测到该请求有效后，声明它的效应信号；当电路A检测到响应信号有效之后，中止自己的请求信号；最后，当电路B检测到请求无效之后，中止自己的相应信号。这样，算是完成了一次通信。除非A检测到无效的响应信号，否则它不会再声明新的请求信号。这种机制要求请求电路A必须延迟它的下一个请求，直到它检测到无效的响应信号（意味着上次请求已完成）。

这种类型的握手使用了 level synchronizer。可以根据两点来粗略估计这个协议的时序：信号跨域一个时钟域需要花费 2 个时钟周期，信号在跨域时钟域之前被电路寄存花费 1 个时钟周期。所以，发送端A需要 5 个周期，接收端B需要 6 个周期。

全握手鲁棒性很好，因为通过检测请求和响应信号，每个电路都清楚地知道对方的状态，这种方式的不足之处是完成整个过程要花费很多时钟周期。

#### partial handshaking

另一中类型是部分握手。部分握手的双方不用等对方的响应就中止各自的信号，并继续执行握手命令序列。

部分握手比全握手在健壮性方面稍弱，因为握手信号并不指示各自电路的状态，每一电路都必须保存状态信息（在全握手里这个信息被送出去），但是，由于无需等待对方的响应，完整的时间序列花费较少的时间。

有两种类型的部分握手：

第一种握手方法中，电路A以有效电平声明其请求信号，电路B以一个单时钟宽度脉冲作为响应。此时，电路B并不关心电路A何时中止它的请求。

![partial-1](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/partial_1.png)

但是为了这种方法成立，电路A中止请求信号至少要 1 个时钟周期长度，否则，电路B就不能区别前一个和后一个新的请求。

在这种握手方式下，电路B为请求信号使用一个 level synchronizer；电路A为响应信号使用一个 pusle synchronizer。只有当电路B检测到请求信号时才发出响应脉冲，这样电路A控制请求信号的时序，就能控制自己synchronizer接收到的脉冲间隔。

同样，使用前面的方法可以估算出这种握手协议的时序：发送端电路A需要花费 3 个时钟周期，接收端B需要花费 5 个时钟周期。

第二种握手方法中，电路A使用一个单时钟宽度脉冲发出它的请求，电路B也以一个单时钟宽度脉冲响应这个请求。这种情况下，两个电路都需要保存状态，以指示请求正待处理。

![partial-2](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/partial_2.png)

这种握手使用的是 pusle synchronizer。完整的时序是：电路A需要花费 2 个时钟周期，电路B需要花费 3 个时钟周期。

#### summary

![handshaing sum](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/handshaking_sum.png)

因为 handshaking 内部采用了 synchronizer，所以可以解决异步信号导致的亚稳态现象。根据实际要求，选择不同的 synchronizer 和握手信号，就有了前面介绍的 3 种不同的 handshaking：

+ full handshaking
是最健壮的，因为在这种机制下，两部分电路都在等待收到对方的确认信号之后才发送新的握手信号，两部分电路是相互都知道对方目前所处于的状态，而且用了两组握手信号（request/acknowledge，de-request/de-acknowledge），相当于完成了两次握手。但是，最健壮的代价就是花费的时间最长，而且要求信号在收到对方的回复之前要保持不变，这就限制了发送信号的速率和节奏。

+ partial handshaking 是对 full 的精简，动机就是减少握手所花费的时间，从减少花费时间的方法上，就有了两种不同的 partial shandshaking。

+ partial I 精简了 1 个握手信号 de-acknowledge，剩下了 3 个握手信号，相当于完成了1次半的握手。而且修改了 full 中 level synchronizer 的方式，接收电路 B 发送的不再是电平信号，而是一个单时钟宽度的脉冲，所以电路A则必须使用 pusle synchronizer 来检测来自 B 的握手信号。通过减少一个握手信号和改进一方的 synchronizer，partial I 就比 full 方式节约了很多时间。

+ partial II 则更进一步，在 partial I 的基础上又精简掉一个握手信号，只剩下 2 个握手信号，只完成1次握手。而且两部分电路的 synchronizer 同时修改为 pusle 方式。这样子进一步减少了握手花费的时间。

+ partial 和 full 的本质区别不在于synchronizer 的类型和握手信号的多少，而在于握手的方式。 partial 不用再等待对方的回答，就继续进行自己的下一步操作，而 full 必须等到对方的回复才进行下一步的操作，所以从某种意义上，full 方式才是真正的“握手”，而 partial 并不符合 “握手” 的意思，毕竟根本不管对方的反应，自顾自地挥手叫哪门子的握手 =.=

<br>

*在许多应用中，跨时钟域传送的不只是简单的信号，数据总线、地址总线、控制总线都会同时跨域传输。因为 synchronizer 需要花费的时间是不确定的（1 or 2 个时钟周期），所以对于这些多 bit 的数据，synchronizer 无法完成同步功能，通常采用其他的方法，比如使用 FIFO。*

<br>

### Solution 3: Datapath Design

在进行信号同步时，有一个重要的原则：

**不应该在设计中的多个地方对同一信号进行同步，即禁止单个信号扇出至多个同步器。**

因为 synchronizer 要花 1~2 个时钟周期，设计者不能确切预测到每个信号何时跨越时钟域，此外，在新时钟域中一组经过同步后的信号其时序是不定的，因为 synchronier 的延迟可以是 1～2 个时钟周期，这种情况下各个同步信号间形成一种“竞争状况”，这种竞争状况在需要跨域时钟域传输的多组信号间也会发生，例如数据总线、地址总线、控制总线等。因此，**不能对组中的每个信号单独使用 synchronizer，也不能对数据/地址总线的每一位单独使用同步器**，因为在新的时钟域中，要求每个信号同时有效。

#### problem

Clifford E. Cummings 在他的文章中举例说明了几种常见的错误：

> A frequent mistake made by engineers when working on multi-clock designs is passing multiple control signals from one clock domain to another and overlooking the importance of the sequencing of the control signals. **Simply using synchronizers on all control signals is not always good enough** as will be shown in the following examples. 
>
> If the order or alignment of the control signals is significant, care must be taken to correctly pass the signals into the new clock domain. All of the examples shown in this section are overly simplistic but they closely mimic situations that often arise in real designs.
> 
> **Problem - Two simultaneously required control signals**
>  a register in the new clock domain requires both a load signal and an
enable signal in order to load a data value into the register. If both the load and enable signals are being sent from one clock domain, there is a chance that a small skew between the control signals could cause the two signals to be synchronized into different clock cycles within the new clock domain. In this example, this would cause the data to the register to not be loaded.
>
> ![problem 1](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/problem_1.png)
>
> ** Solution - Consolidating control signals before passing**
>
> ![solution 1](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/solution_1.png)
>
> **Problem - Two phase-shifted sequencing control signals**
>
>  The problem is that in the first clock domain, the aen1 control signal might terminate slightly before the aen2 control signal is asserted, and the second clock domain might try to sample the aen1 and aen2 control signals in the middle of this slight time gap, causing a one-cycle gap to form in the enable control-signal chain in the second clock domain. This would cause the a2 output signal to be missed by the second flip-flop.
>
> ![problem 2](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/problem_2.png)
>
> ** Solution - Logic to generate the proper sequencing signals**
>
> ![solution 2](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/solution_2.png)

#### solution

有一种解决这个问题的方法是：**使用一个保持寄存器 + 一个握手信号**。

![solution](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/datapath.png)

保持寄存器保持信号总线的数据，握手信号指示目标时钟域何时可以对总线进行采样，源时钟域何时可以更换当前寄存器中保存的内容。

> In this design, the transmitting circuit stores the data (signal bus) in the holding register as it asserts the request signal. These two actions can happen at once because the request signal takes at least one clock cycle before the receiving circuit detects it (the minimum handshake-synchronization delay). When the receiving circuit samples the data (signal bus), it asserts the acknowledgment signal.

仔细分析一下，其实这里采用的原理类似于握手协议。

当有一组新的数据出现在数据总线上需要跨时钟域时，额外添加一对握手信号 request/acknowledge，这对信号对于两个时钟域来说分别是异步信号（接收电路不知道何时会收到request，发送电路也不知道何时会获得acknowledge），可能会产生亚稳态的问题，所以在两个时钟域对它们分别用 synchronizer 进行同步。

和request一起送过来的还有数据总线 上的数据信号，但是对于数据信号，不能简单地对每一位使用 synchronizer 来同步（原因前面已经说过了）。虽然对于接收电路来说，数据总线上的数据也是异步的，但是我们可以强制要求在握手过程中，数据保持不变，这样虽然数据是异步的，只要发送端满足保持寄存器数据在握手过程中不变化这一条件，那么即使数据总线上的数据到达接收时钟域有一些小的偏差 skew，但是不会超出 1 个时钟周期，在 synchronizer 最好的状态下，只花费了 1 个时钟周期就同步到了握手请求request，这时候数据总线上的数据已经是稳定不变的有效数据了，所以可以采样到正确的有效数据，不会存在亚稳态的问题。

采用这种方法可以避免亚稳态的出现的原因就是它规定了异步信号（保持寄存器）什么时候可以变化，虽然是异步信号，但是在采样的时候人为地确保了它保持稳定，满足 setup/hold time 的要求，所以不会有亚稳态的问题。

这里的握手机制可以采用 full handshaking，也可以采用 partial handshaking，设计者应该根据实际需求来选择。

在 [The Art of Hardware Architecture][art] 这本书中，有详细的时序图来说明了一种握手机制下，这种机制采用了 full handshaking 中等待对方的方法，但是对握手信号进行了精简（partial II 类型）。如下图：

![datapath timing](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/datapath_timing.png)

<br>

*如果发送端的数据速率很快/无法控制发送端发送数据的速度，那么就有可能无法满足握手机制中要求数据保持稳定这一要求，这时候这种方法就不再适用，而应该采用其他的方法，比如 FIFO。*

[art]: http://www.amazon.com/The-Art-Hardware-Architecture-Techniques/dp/1461403960

<br>

### Solution 4: Advanced Datapath Design

有时候，数据在跨时钟域时需要“堆积”起来，这时候只使用单个的寄存器就无法完成工作。比如某个传输电路突发式地发送数据，接收电路来不及采样，为了保持数据不丢失，就必须先把数据存储起来；还有一种情况是接收电路的采样速率比发送速度快，但是位宽却不够，仍然需要将没有采样的数据先暂存起来，这时候就需要使用 FIFO。

基本上，使用 FIFO 的目的有两个：

1. 速度匹配

2. 宽度匹配

FIFO 的实现可以直接使用 IP core，也可以自己写代码实现。

如果是自己写代码实现，那么异步信号的问题还是需要我们在实现 FIFO 是仔细考虑的；如果是采用 IP core 的方式，那么可以很大程度地缓解我们的压力，因为事实上我们是把异步信号的问题交给了设计 IP core 的人来处理...这些 IP core 在内部针对异步数据读写的问题作了非常严谨复杂的设计，对外提供了非常简单的接口。采用这种方式虽然轻松，但是相应的地也有缺点：耗费更多的资源。

在 [Synthesis and Scripting Techniques for Designing Multi-Asynchronous Clock Designs][paper1] 和 [Crossing the abyss: asynchronous signals in a synchronous world][paper2] 两篇 paper 和 [The Art][art] 中都有一些实现 FIFO 使用的相关技术的介绍，比如指针逻辑的处理，内部 gray code 计数器的实现等。这里就偷懒不细说了（以后再补） :P

=============Update March/12/2015===========================

FIFO 的目的在于解决数据跨时钟域传输的问题，但是在实现FIFO本身时，一些内部的握手信号也需要跨时钟域，这时候需要用到之前讨论过的dual rank synchronizer等技术。

比如FIFO内部的地址计数器，如果使用dual rank synchronizer来同步，计数器的不同的bit可能会在不同的时钟周期内传递过去，这时接收到的数据就是错误的，对导致致命性的问题。

而对应这个问题的解决方法就是使用 gray code。

==============end of update==================================

[paper2]: http://inst.eecs.berkeley.edu/~cs150/sp10/Collections/Papers/ClockCrossing.pdf

*关于跨时钟域 [papaer1][paper1] 中还有一些其他方面的技巧，可以帮助我们更好的实现设计。*

<br>

### Design Partitioning

**Guideline:**

> Only allow one clock per module.

**Reason:**

> Static timing analysis and creating synthesis scripts is more easily accomplished on single-clock modules or groups of single-clock modules.

**guideline:**

> Create a synchronizer module for each set of signals that pass from just one clock domain into another clock domain.

**Reason:**

> It is given that any signal passing from one clock domain to another clock domain is going to have setup and hold time problems. No worst-case (max time) timing analysis is required for synchronizer modules. Only best case (min time) timing analysis is required between first and second stage flip-flops to ensure that all hold times are met. Also, gate-level simulations can more easily be configured to ignore setup and hold time violations on the first stage of each synchronizer.

采用这种设计方式的原因如上所示，可以减少不必要的时序验证，而且脚本也更容易写，总之可以使时序验证工作更容易。

举例如下图所示：

![partitioning](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/partitioning.png)

<br>

### Clock Name Conventions

**Guideline:**

> Use a clock naming convention to identify the clock source of every signal in a design.

**Reason:**

> A naming convention helps all team members to identify the clock domain for every signal in a design and also makes grouping of signals for timing analysis easier to do using regular expression "wild-carding" from within a synthesis script.

作者还举例说明了一个这样的例子：1995 年为 In Focus projectors 设计 video ASIC 时，他们就采用了这样的方法，对于 mircroprocessor 的时钟命名为 uClk，对于 video 的时钟则命名为 vClk。对应的时钟域中的信号的名字也添加了对应的前缀，比如udata，uwrite，uadder等。

使用了这样的策略后，整个设计团队的攻城狮们都可以很方便地确定某个信号是否为异步信号，如何处理。当时有个攻城狮没有按照这种策略，使用了自己的命名方式，在一次会议之后，大家墙裂建议他修改命名，结果也证明修改之后遇到的问题、出错的概率都小了很多。

<br>

## Gated Clock
* * *

虽然 FPGA 可以用来为 ASIC 搭建原型，但是一些 ASIC 中的技术并不适用于 FPGA，比如 gated clock。一般也没有必要在 FPGA 中模拟 ASIC 的低功耗优化。事实上，由于 FPGA 时钟资源的的粗颗粒度性，并不是总能模拟成功。

下面简单讨论一下 ASIC 中 gated clock 的问题。（更详细的内容见 gated clock 文章，未写）

1. dedicated clock module

    **guideline**: 将全部的 gated clock 时钟放在一个专门的时钟模块中，并将其从功能模块中分离出来

    **reason**: 

    + 约束更加容易处理
    + FPGA 设计修改起来更容易（比如通过 #define 来选择编译 ASIC 还是 FPGA 设计，选择两者各自的实现代码）

2. gating removal

    在 FPGA 上建立模型时，有很多巧妙的方法去除 gated clock。比如下面这个例子就是最直观，但也是最繁琐的方法：

        #!verilog
        `define FPGA
        // `define ASIC

        module clock_blocks (...)

            `ifdef ASIC
                assign clock_domain_1 = system_clock_1 & clock_enable_1;
            `else
                assign clock_domain_1 = system_clock_1;
            `endif

        ...

        endmodule

    这种方法的缺点是当做出改动时，需要对 FPGA 和 ASIC 代码都作出修改。很多人对这种方式很不爽，因为他们必须写两种不同的 RTL 代码。

    一种更加高级的方法是依靠工具，现代的很多综合工具都可以通过适当的约束，通过将条件并到数据通路，来自动消除 gated clock。

    比如下面的这段代码：

        #!verilog
        module clockstest(
            output  reg  oDat,
            input        iClk,
            input        iEnable,
            input        iDat);

            wire  gated_clock = iClk & iEnable;

            always @(posedge gated_clock)
                oDat <= iDat;

        endmodule

    如果不打开自动消除的开关，产生的 gated clock 电路如下：

    ![circuit1](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/circuit1.png)
    
    如果打开自动消除的开关，产生的没有 gated clock 电路如下：
    
    ![circuit2](/images/the-clock-design-in-fpga-3-multiasynchronous-clock-design/circuit2.png)
    
    现在大多数器件都提供了一个时钟使能（clock enable）端口
    
    + 如果器件提供了这种接口，那么就没有必要使用上述方法；
    
    + 如果器件没有提供这种端口，那么使用这种技术虽然可以消除 gated clock，但是付出的代价是增加了 data path 的 delay。

<br>

## Summary
* * *

以上，就是一些在多时钟域设计中处理异步数据的常用方法，总结如下：

1. 对于简单的单比特的数据，根据实际情况选择对应的 synchronizer 即可

2. 对于其他的信号，比如数据总线、地址总线、控制总线等数据，可以使用握手协议

3. 总线上的数据要求同时到达新的时钟域，所以不要对总线上的信号分别进行同步，而要采用一个保持寄存器 + 握手信号的方式

4. 还可以采用 FIFO 来处理异步数据的问题

5. 分块设计，尽可能保证一个模块只有一个时钟域，对于跨时钟域信号，写独立的同步模块，这样可以减轻时序验证的工作

6. 采用良好的命名习惯，如前缀的方式，可以帮助设计

7. 注意 ASIC 和 FPGA 中对时钟信号的不同处理方法

<br>

## Reference

[Synthesis and Scripting Techniques for Designing Multi-Asynchronous Clock Designs][paper1]

[Crossing the abyss: asynchronous signals in a synchronous world][paper2]

[Xilinx FPGA高级设计及应用](http://book.douban.com/subject/10593491/)

[FPGA高手设计实战真经100则](http://www.amazon.cn/%E5%9B%BE%E4%B9%A6/dp/B00FW1RTZG)

[ASIC中的异步时序设计](http://bbs.ednchina.com/BLOG_ARTICLE_174906.HTM)

[跨越鸿沟：同步世界中的异步信号](http://bbs.ednchina.com/BLOG_ARTICLE_175526.HTM)

[Understanding Metastability in FPGAs][wp-01082]

[The Art of Hardware Architecture][art]

[Advanced FPGA Design: Architecture, Implementation, and Optimization](http://book.douban.com/subject/2878096/)
