Title: Xilinx FFT IP core 笔记
Date: 2014-09-02 23:12
Category: FPGA
Tags: FPGA, fft
Slug: xilinx_fft_core_notes
Author: Chien Gu
Summary: 使用 Xilinx FFT IP core (xfft v7.1) 的笔记

关于 FFT 的背景介绍就不再赘述，通原书和网上的教程、课件很多；关于这个 IP 核的介绍也就不再粘贴复制了，原版的 datasheet 必然是最全面的，仅记录我的使用时遇到的问题和需要注意到细节。

IP 核的接口示意图：

![schematic symbol](/images/xilinx_fft_core_notes/symbol.png)

<br>

## Timing
* * *

### `START / RFD` port

datasheet 中没有专门描述 `start` 信号和其他信号的时序关系，只是简单介绍：

> FFT start signal (Active High): START is asserted to begin the data loading and transform calculation (for the Burst I/O architectures). For Streaming I/O, START begins data loading, which proceeds directly to transform calculation and then data unloading.

在我最开始的测试小程序中，是先判断 `rfd` 信号，根据 rfd 来给 start 赋值。

*思路是：首先必须等 IP core 准备好接收新数据时，才能开始*

        if (rfd) begin
            start <= 1;
        end
        else if (busy) begin
            start <= 0;
        end
        else begin
            start <= start;
        end

但是仿真出来的结果显示 IP core 根本就没有工作，后来改了这两个信号的先后关系，

*新思路：程序将输入 start 置有效，通知 IP core 需要调用，然后 IP core 根据自己的状态给出标识信号（rfd / busy），外部电路等到 rfd 有效时才输入需要变换的信号。*


        always @(posedge clk or posedge rst) begin
            if (rst) begin
                start <= 1;
            end
            else begin
                if (busy) begin
                    start <= 0;
                end
                else begin
                    start <= 1;
                end
            end
        end

这样子程序就可以正常运行了。

### `RFD / DV` port

在 datasheet 中给出的时序图如下所示（Burst I/O Solutions with Natural Order Output）

![Burst I/O Solution](/images/xilinx_fft_core_notes/burst_io_splution.png)

实际仿真图：

![rfd_dv_sim](/images/xilinx_fft_core_notes/rfd_dv.png)

实际仿真结果和示意图有一点点小差别：datasheet 中的时序图显示 rfd 必须在等 unload 阶段结束之后才能变有效，输入新的数据；但是实际的仿真图显示，在 unload 的后半段时间，rfd 已经变有效了，开始载入新的数据。

从理论上分析，采用 Burst I/O with Natural Order Output 方案，总共需要 3N 个时钟周期，load 阶段需要 N 个周期载入数据，processing 阶段需要 N 个时钟变换，unload 阶段需要 N 个周期来输出数据。

从仿真结果来看，unload 阶段和下一帧的 load 阶段有部分是重叠的，这样实际上的周期是少于 3N 个时钟的。

**虽然功能上是不影响下一帧的数据的，毕竟和预期的时序不同，不知道是否会影响时序设计，有待继续观察。**

<br>

## Port
* * *

### `NFFT` port

这个 FFT core 是可以设置为 动态重配置的，可以在运行时改变做运算的点数，非常方便，不过有一点需要注意到是重配置的点数是有范围限制的，比如我测试时设置的最大点数为 4096 点，那么运行重配置时，最小的点数为 64。可以选择 64 ~ 4096 之间的任何一个 2 的指数。

由于我一开始忽略了这一点，重配置为 16 点，迷糊了半天，重新打开 IP core 设置时才发现是自己看文档不够仔细 =.=

### `CP` port

这个 FFT core 专门提供了一个端口可以设置循环前缀的长度，循环前缀 (cyclic prefix) 在通信中（尤其是 OFDM）是很有用的。

在向导中设置了 cyclic prefix insertion，并且在程序重配置时设置了 CP length = 10，但是仿真结果却没有出现 CP，和 CP = 0 时的结果相同。

**仔细看了两遍程序和 datasheet，没有发现问题...待解决！**

<br>

## P.S. Test program
* * *

### FFT IP core

**设置**

page1: 

+ channel = 1

+ Transform Length = 4096

+ Radix-4, Burst I/O

+ run time configurable transform length

page2:

+ Fix Point

+ Input data width  = 24

+ Phase factor width = 24

+ block floating point

+ natural output

+ cyclic prefix insertion

+ input data timing - no offset

page3:

+ use 3-multiplier structer

+ use CLB logic to implement butterfly arithmetic

**运行时重配置**

变换长度为 64 点，cp 长度为 10

### Matlab

        x = [0:63];
        y = fft(x);
        re = real(y);
        im = imag(y);
        fprintf('%f', re);
        fprintf('%f', im);

### Conclusion

FFT IP core 仿真结果：

![fft core sim](/images/xilinx_fft_core_notes/fft_core_sim.png)

对比 Matlab 中的结果，可以看到 IP core 的计算结果是正确的（除了 CP 的问题）。
