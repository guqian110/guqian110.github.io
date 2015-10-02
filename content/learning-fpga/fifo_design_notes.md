Title: FIFO 设计笔记
Date: 2015-10-02 22:13
Category: FPGA
Tags: FIFO
Slug: fifo_design_notes
Author: Qian Gu
Summary: 总结 FIFO 的注意事项


FIFO 的重要性就不用再重复了，在笔试面试的时候也常常被问到，总结一下设计 FIFO 需要注意的问题。

FIFO 可以分为两类：

+ Sync FIFO: write 和 read 使用同一个时钟

+ Async FIFO: write 和 read 分别使用两个时钟

设计 FIFO 的时候，通常需要考虑的问题有：

1. FIFO 的大小

2. FIFO 空满的判断

## Sync FIFO
* * *

Sync FIFO 的框图如下所示：

![sync fifo](/images/fifo-design-notes/sync_fifo.png)

因为同步 FIFO 的读写速率是相同的，所以 FIFO 的大小设置不必考虑读写速率差这个因素，要简单很多。

在 FIFO 内部，一般使用 dual port RAM 存储数据。双端口 RAM 有两套独立的读写地址，读地址和写地址分别由读指针和写指针来产生：写指针指向下一个数据被写入的地址，读指针指向下一个被读出的数据的地址，通过判断读写指针的相对大小，就可以得到 FIFO 的状态（full / empty）。

还有另外一种方法来产生 full / empty 信号：FIFO 内部维护一个计数器，每次写入一个数据 cnt++，每次读出一个数据 cnt--。这种方法产生 full / empty 很简单：当 cnt == 0，表示 FIFO empty；当 cnt == max，表示 FIFO full。虽然这种方法产生 full / empty 很简单，但是需要额外的计数器，而且计数器的位宽随着 FIFO 的深度增加，不仅占用的资源更多，而且会降低 FIFO 最终可以达到的速度。


<br>

## Async FIFO
* * *

一般异步 FIFO 的读写速率不同，如果写速度 > 读速度，则当数据量超过一定长度时，会出现溢出的情况，为了防止这种情况，可以采用两种措施：

1. 预先知道写速率和模式（burst / nonburst），最小的读速率，根据这些条件设置 FIFO 的深度

    通常发送端的数据都是突发的形式，FIFO 的深度至少要大于等于突发数据的最大长度。

2. 握手机制（full / empty）

    很多情况下，突发数据的长度和分布是预先不知道的，此时则无法确保 FIFO 的深度足够大，因此需要握手机制来告诉发送端已经没有多余的空地址保存数据 or 告诉接收端已经内部已经没有剩余的可以读取的数据。通常使用如下的 FSM 来实现：

    发送端，写数据：

    ![wr fsm](/images/fifo-design-notes/wr_fsm.png)

    接收端，读数据：

    ![rd fsm](/images/fifo-design-notes/rd_fsm.png)

### Gray Code

在异步 FIFO 中，因为一些内部的信号要从写/读时钟域传递到读/写时钟域，所以必须要解决异步信号同步的问题，而且有的信号不止 1 bit，如果使用“同步桥”，则因为各个 bit 的同步时延不一定（1~2T），所以不能用同步桥。

这个问题可以使用 gray code 解决：gray code 是循环码，每次只有 1 bit 变化，这样就避免了多 bits 变化的数据同步问题。如下图：

![sync](/images/fifo-design-notes/sync.png)

gray code 与 binary code 的相互想换见另[外一篇 blog]()。

### wr_ptr / rd_ptr Sync Lag

异步 FIFO 还有个问题是：地址信号跨时钟域时，可能会有 1T 的时延，这个多余的时延并不会导致 full /empty 错误置位，引起错误的 overf：

+ 如果地址信号传递到读时钟域时延时了 1T，此时接收端并不知道数据已经写入了 FIFO，仍然认为 FIFO 是空的，这种情况只会对 FIFO 的吞吐率 throughput 有影响，但是不会导致 underflow；

    如下图，先写满 FIFO，然后开始读：在 t6 时 FIFO 读空，empty = 1，在 t7 时，写入了一个新数据，此时 FIFO 内已经有有效数据了，但是 wr_ptr 同步到读时钟域要花费 2T，所以在 t9 时 empty = 0。有两个时钟周期（t7, t8） rd 被阻塞了，但是并不影响 FIFO 正常工作。

    ![empty](/images/fifo-design-notes/empty.png)

    时序图：

    ![empty timing](/images/fifo-design-notes/empty_timing.png)


+ 如果地址信号传递到写时钟域时延是了 1T，此时发送端并不知道 FIFO 已经有空余地址了，仍然认为 FIFO 是满的，这种情况也是只会对 FIFO 的吞吐率 throughput 有影响，但是不会导致 overfl；

    如下图，先写满 FIFO，然后开始读：在 t5 时，full = 1，在 t6 时，读出了一个数据，此时 FIFO 已经有空余地址了，但是 rd_ptr 同步到写时钟域要花费 2T，所以在 t8 时 full = 0。有两个时钟周期（t6, t7） wr 被阻塞了，但是并不影响 FIFO 正常工作。

    ![full](/images/fifo-design-notes/full.png)

    时序图：

    ![full timing](/images/fifo-design-notes/full_timing.png)

### Full / Empty Generation

因为 wr_ptr 和 rd_ptr 相同时，FIFO 既可能是 full，也有可能是 empt，所以需要额外的 1 bit 来区别这两种情况：

假设 FIFO 的深度是 8，则地址为 3 bits，初始时 wr_ptr 和 rd_ptr 都是 `0000`，FIFO 此时是 empty：

1. 当连续 8 个数据写入到 FIFO full，wr_ptr = `1000`，而 rd_ptr = `0000`，**MSB 不同，剩余位相同**

2. 当连续 8 次读取数据 FIFO empty，rd_ptr = wr_ptr = `1000`，**所有 bits 都相等**

借助这多余的 1 bit，可以区分出是 wr_ptr 太快，将 rd_ptr 套圈了（wr_ptr = `1000`，rd_ptr = `0000`， 即 full），还是 rd_ptr 更快，追上了 wr_ptr（rd_ptr = wr_ptr = `1000`）。

框图如下：

![full empty gen](/images/fifo-design-notes/full_empty_gen.png)

这种 wr_ptr / rd_ptr 用 gray code 保存，比较/+1 用 binary 保存的方式，使得 design / debug 变得很简单，但是需要的资源比较多。如果全部使用 gray code，虽然可以降低资源占用，但是需要其他逻辑。

### Dual Clock FIFO Design

下图是使用 Dual port RAM 的异步 FIFO 框图，其中 wr_ptr 和 rd_ptr 直接使用 gray code，节省了 gray code 和 binary code 之间的转换逻辑。

![dual clock fifo](/images/fifo-design-notes/dual_port_fifo.png)

和前面的逻辑类似，使用多 1 bit 来辅助区分 full / empt，不过因为改成用 gray code 来比较，所以稍有不同，下图显示了 FIFO 从 empty 到 full 再到 empty 的过程：

![full empty condition](/images/fifo-design-notes/full_empty_condition.png)

1. FIFO empty

    当 wr_ptr = rd_ptr 时 FIFO empty

2. FIFO full

    如上图，FIFO 初始状态为 empty，然后连续写入 8 个数据，再读出 8 个数据，此时 wr_ptr = rd_ptr = 7，FIFO 又变为 empty。此时如果再写入一个数据，wr_ptr = 8，rd_ptr = 7，如果仍然使用前面介绍的方法（MSB不同，剩余位相同)，则会得出 FIFO full 的错误结论，实际上 FIFO 并没有满。

    仔细观察 gray code 的对称性，就可以知道，当 full 时（wr_ptr 将 rd_ptr 套圈时），MSB 不同，wr_ptr 的 2nd MSB 要先翻转，才和 rd_ptr 相同。所以，当下面 3 个条件都满足时，FIFO full：

    1. wr_ptr 和 rd_ptr 的 MSB 不相等

    2. wr_ptr 的 2nd MSB 翻转后和 rd_ptr 的 2nd MSB 相等

    3. 剩余 bits 全部相等

<br>

## Summary
* * *

总结 FIFO 的设计，只要注意 FIFO 通过 wr_ptr 和 rd_ptr 得到 full / empty，而且使用 gray code 来跨时钟域，基本上就没问题了 :-D

<br>

## Ref

[The Art of Hardware Architecture: Design Methods and Techniques for Digital Circuits](http://www.amazon.com/The-Art-Hardware-Architecture-Techniques/dp/1461403960)

[Advanced FPGA Design: Architecture, Implementation, and Optimization](http://www.amazon.com/Advanced-FPGA-Design-Architecture-Implementation/dp/0470054379/ref=sr_1_1?s=books&ie=UTF8&qid=1432020884&sr=1-1&keywords=advanced+fpga+design)
