Title: OFDM 中的 IFFT/FFT 注意事项
Date: 2015-03-10 19:40
Category: Telecom
Tags: Telecom, ifft, fft, ofdm
Slug: ifft_and_fft_in_ofdm
Author: Qian Gu
Summary: OFDM 中做 IFFT/FFT 时需要注意的一点细节

在做 OFDM 项目时，发现一个容易犯错的地方：IFFT/FFT。

在很多介绍 OFDM 的书中，给出结论：在发射机，基带信号的复包络采用值正好是待发射序列的 IDFT，所以在 N 是 2 的指数时，可以采用 IFFT 来快速计算；在接收机，将接收的频带信号解调到基带，采样得到基带复包络，然后做 DFT (FFT) 即可得到原始的发射序列。

这个结论是正确的，但是需要注意的一点是：

**调制/解调所做的运算的形式和 IFFT/FFT 是相同的，但是有一个功率归一化的系数的差别。**

很多书（[通信原理][book1]）都给出了公式推导，然而这些公式并不严谨，这些公式只是为了说明做的变换形式是 IFFT/FFT。

有的书（[宽带无线通信OFDM技术][book2]）则给出了更加详细，严谨的公式推导。

### IFFT / FFT

![fft/ifft](http://guqian110.github.io/images/xilinx_fft_core_notes/theory.png)

### IFFT /FFT in OFDM

OFDM 中 **功率归一化因子** 为 1/sqr(N)，而标准的 IFFT 中的系数为 1/N，所以在调用标准 IFFT 函数之后，需要额外乘以一个 sqr(N) ：

`1/N × sqr(N) = 1/sqr(N)`

而在接收端，也要先除以一个 sqr(N)，然后再进行 FFT 。

<br>

[book1]: http://book.douban.com/subject/1446684/
[book2]: http://book.douban.com/subject/1140934/

## Ref

[通信原理][book1]

[宽带无线通信OFDM技术][book2]
