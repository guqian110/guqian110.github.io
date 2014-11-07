Title: 计数器设计小结
Date: 2014-11-4 20:40
Category: FPGA
Tag: FPGA, counter design
Slug: counter_design_summary
Author: Chien Gu
Summary: 总结 FPGA 中的计数器设计

## Introduction
* * *

计数器 在数字电路设计 和 计算机程序设计 中都应用非常广泛，其功能顾名思义，就是用来计数。这里只讨论数字电路设计中的计数器。

通常，将包含触发器 flip-flop 的电路（即使含有组合电路部分）认为是时序电路。时序电路通常不以电路命名，而是以功能进行分类，分别是 **寄存器** 和 **计数器**。

计数器 [counter][wiki] 从本质上来说也是寄存器，不过它是在雨点设定好的状态序列中转移，尽管计数器是寄存器的一种特殊形式，通常还是以不同的名称来加以区分。

[wiki]: http://en.wikipedia.org/wiki/Counter

<br>

## Type

按照不同的标准来划分，计数器可以有不同的划分方法：

1. 触发方式

    同步 / 异步 计数器
    
2. 计数增减

    加法 / 减法 / 可逆计数器
    
因为第二种方法没有明确显示计数器的计数方式，所以一般使用第一种方法。

这里总结了一些常见的计数器：

1. Basic Binary Counter

2. BCD Counter

3. Ring Counter

4. Johnson Counter

5. Ripple Counter

计数器在数字电路中的用途非常广，可以作为定时器、实用计数器、状态机等。在具体实现时，有前面总结的不同的计数器类型可供选择，每种计数器由其特点决定了适用场合，我们要做到就是在不同计数器类型和配置之间进行权衡，选择正确的设计，以节省大量逻辑资源，并提高性能。

下面分别讨论各种计数器的特点和 HDL 实现。

## Implement
* * *

### Binary Counter

最简单、最基本的计数器就是 二进制计数器 Binary Counter。它的计数方式就是从 0 开始每个脉冲进行 “+1” 操作，直到最大值，然后重新从 0 开始。

[FPGA Prototyping By Verilog Examples: Xilinx Spartan-3 Version][book1] 里面有个例子，这里稍作修改就可以当作通用模块，供其他模块调用了。

**Code**

    #!verilog
    module free_run_bin_counter(
        clk, rst, max_tick, q
        );

        parameter   N = 8;
    
        input                     clk;
        input                     rst;
        output  reg               max_tick;
        output  reg  [N - 1 : 0]  q;
    
        // count
        always @(posedge clk) begin
            if (rst) begin
                // reset
                q <= 0;
            end
            else begin
                q <=  q + 1;
            end
        end

        // max_tick
        always @(posedge clk) begin
            if (rst) begin
                max_tick <= 0;
            end
            else begin
                if (q == {N{1'b1}}) begin
                    max_tick <= 1;
                end
                else begin
                    max_tick <= 0;
                end
            end
        end

    endmodule
    
[book1]: http://www.amazon.com/FPGA-Prototyping-Verilog-Examples-Spartan-3/dp/0470185325

### BCD Counter (mod-m counter)

人类更习惯使用十进制进行计数，十进制一共有 10 个符号，我们只需要从 4 bit 的二进制计数器中选取 10 个数字，只使用这 10 个数字进行计数即可，通常去掉 1010 ~ 1111 这 6 个数字，即使用 8421BCD码 来对十进制数进行编码、计数，即 BCD Counter。

将十进制进行推广，我们就可以写出任意的 模 m 的计数器，在下面的例子中，M 表示计数器的模值（默认为 10），N 表示计数器需要的位数（默认为 4）。在例化时如果要修改，则需要手动计算这两个参数进行赋值。

**Code**

    #!verilog
    module bcd_counter(
        clk, rst, max_tick, q
        );

        parameter   N = 4,  // number of bits in counter
                    M = 10; // mod-M

        input       clk;
        input       rst;
        output  reg  [N - 1 : 0]    q;
        output  reg                 max_tick;

        always @(posedge clk) begin
            if (rst) begin
                // reset
                q <= 0;
            end
            else begin
                if (q == (M - 1)) begin
                    q <= 0;
                end
                else begin
                    q <= q + 1;
                end
            end
        end

        always @(posedge clk) begin
            if (rst) begin
                // reset
                max_tick <= 0;
            end
            else begin
                if (q == (M - 1)) begin
                    max_tick <= 1;
                end
                else begin
                    max_tick <= 0;
                end
            end
        end

    endmodule

### Ring Counter

基于线性移位寄存器 [`LFSR` (Linear feedback shift register) ][lfsr_wiki] 可以衍生出两种计数器：[环形计数器 (ring counter)][ring_counter wiki] 和 扭环计数器（约翰逊计数器）。

将 LFSR 中存储的数字设置为独热码的形式，即只有一位为 1，其他位为 0。然后把最后一级的输出直接反馈到第一级的输入，这样，输入和输出组成了一个环形，所以称为 环形计数器。4 bit 的环形计数器电路图如下：

[ring counter](/images/counter-design-summary/ring_counter.png)

(ref: http://electronics-course.com/ring-counter)

**Adv**

1. 相比于 binary counter，ring counter 不需要后者必需的加法器来实现计数，所以它在电路上占用的资源要更少。

2. 因为没有额外的加法器，所以 ring counter 也不存在加法器带来的进位时延，它的最大时延是固定值，和计数器的模值无关。所以它的时序性能也比 binary counter 好。

3. 因为 ring counter 的汉明距离为 2，所以它可以检查单比特翻转的错误。

**Disadv**

Ring counter 最大的缺点就是它的低密度码，同样适用 N 个寄存器，binary counter 可以计数到 2^N，而 ring counter 只能计数到 N，经过改良后的 Johnson counter 也才能到 2N。所以，如果寄存器比组合逻辑更加珍贵的情况下，不适合使用 ring counter。

**Code**

    #!verilog
    module ring_counter(
        clk, rst, max_tick, q
        );

        parameter   N = 10;

        input       clk;
        input       rst;
        output  reg                 max_tick;
        output  reg  [N - 1 : 0]    q;

        always @(posedge clk) begin
            if (rst) begin
                // reset
                q <= 0;
                q[N-1] <= 1'b1;
            end
            else begin
                q <= {q[0], q[N-1 : 1]};    // right shift
            end
        end

        always @(posedge clk) begin
            if (rst) begin
                // reset
                max_tick <= 0;
            end
            else begin
                if (q[0] == 1) begin
                    max_tick <= 1;
                end
                else begin
                    max_tick <= 0;
                end
            end
        end

    endmodule

### Johnson Counter

在 ring counter 的反馈链路中加入一个反相器，就好象把一个环扭了一下，所以称为 扭环计数器 (Johnson Counter)

4 bit 的 Johnson Counter 如下图所示：

![johnson counter](http://upload.wikimedia.org/wikipedia/commons/e/e8/JohnsonCounter2.png)

**Adv**

最大的优点就是它可以计数的范围和 ring counter 相比，扩大了一倍，达到了 2N。

**Disadv**

最大的缺点就是一旦它进入了错误状态，则永远无法返回到正确状态，除非外界干预。

**Code**

首先，将前面例子第 行的反馈语句修改一下，

    #!verilog
    q <= {~q[0], q[N-1 : 1]};    // right shift

同时，计数器的终点也要进行相应的修改，

    #!verilog
    if (q[N-1] == 1 && q[N-2:0] == 0) begin
        max_tick <= 1;
    end
    else begin
        max_tick <= 0;
    end

### Ripple Counter

前面总结的这些计数器都是同步计数器，组成它们的 flip-flop 是由同一个脉冲信号触发的。还有一种计数器是异步计数器，它内部的 flip-flop 不是由同一个脉冲信号触发的。由于 FPGA 特殊的结构原因，在 FPGA 中应该使用同步设计，所以一般 FPGA 不会使用这种计数器。

ripple counter 的每个 flip-flop 使用前一级的 flip-flop 的输出信号作为触发信号，所以后一级的触发器必须等到前一级的触发器输出之后才能工作，所以对于一个长度为 N 的触发器链，从输入时间开始，要等 N 个触发器依次工作完之后才能输出有效结果。

示意图：

[ripple counter](/images/counter-design-summary/ripple_counter.png)

(ref: http://www.eecs.tufts.edu/~dsculley/tutorial/flopsandcounters/flops6.html)

**Adv**

1. 面积小（不需要电路来实现 “+1” 功能）

2. 功率少（因为面积小）

所以在一些对面积、成本、功率敏感的应用中，ripple counter 很有用。比如：一个电子时钟，因为秒 s 对于纳秒 ns 来说是很缓慢的，所以可以忍受这种累积误差的。

**Dis**

所有的 flip-flop 不是同时触发的，每个 flip-flop 的时延会累积到输出，当所有的时延累积到一起，有时候（很长的 flip-flop 级联在一起）相对于时钟信号而言，就不能忽略这种时延了，严重时会导致系统出错。

**Code**

代码在

[Hdl Chip Design: A Practical Guide for Designing, Synthesizing & Simulating Asics & Fpgas Using Vhdl or Verilog][book2]

里面有介绍。

[book2]: http://www.amazon.com/Hdl-Chip-Design-Synthesizing-Simulating/dp/0965193438

### Gray Code Counter

Gray 码和普通的二进制编码相比，优势就是它相邻数字之间只有一位不同，这样在计数时，就避免的多位不是同时变化导致的毛刺。

[Gray Code wiki][gray code]:

> A typical use of Gray code counters is building a FIFO (first-in, first-out) data buffer that has read and write ports that exist in different clock domains. The input and output counters inside such a dual-port FIFO are often stored using Gray code to prevent invalid transient states from being captured when the count crosses clock domains.[10] The updated read and write pointers need to be passed between clock domains when they change, to be able to track FIFO empty and full status in each domain. Each bit of the pointers is sampled non-deterministically for this clock domain transfer. So for each bit, either the old value or the new value is propagated. Therefore, if more than one bit in the multi-bit pointer is changing at the sampling point, a "wrong" binary value (neither new nor old) can be propagated. By guaranteeing only one bit can be changing, Gray codes guarantee that the only possible sampled values are the new or old multi-bit value. Typically Gray codes of power-of-two length are used.

在大神 Clifford E. Cummings 的论文 

[synthesis and scripting techniques for designing multi-asynchronous clock designs][paper1]

中有详细介绍如何设计一个 Gray Code Counter 的过程，其基本思想就是利用一个 binary counter 来实现目的，计数器的计数功能由内部的 binary counter 实现，将 binary 的计数结果通过一个 binary2gray 的转换电路转化为 gray code 后再输出；输出的 gray code 反馈回计数器之前，再通过一个 gray2bianry 的电路转化回 binary 形式，以供内部的 binary counter 使用。模块示意图如下：

[gray code counter](/images/counter-design-summary/gray_code_counter.png)

代码略...

[lfsr_wiki]: http://en.wikipedia.org/wiki/Linear_feedback_shift_register

[gray code]: http://en.wikipedia.org/wiki/Gray_code
[paper1]: http://www.sunburst-design.com/papers/CummingsSNUG2001SJ_AsyncClk.pdf

<br>

## Reference

[FPGA Prototyping By Verilog Examples: Xilinx Spartan-3 Version][book1]

[Hdl Chip Design: A Practical Guide for Designing, Synthesizing & Simulating Asics & Fpgas Using Vhdl or Verilog][book2]

[synthesis and scripting techniques for designing multi-asynchronous clock designs][paper1]

[Design Recipes for FPGAs: Using Verilog and VHDL (Embedded Technology) ](http://www.amazon.com/Design-Recipes-FPGAs-Embedded-Technology/dp/0750668458/ref=sr_1_1?s=books&ie=UTF8&qid=1415197345&sr=1-1&keywords=design+recipes+for+fpgas)

