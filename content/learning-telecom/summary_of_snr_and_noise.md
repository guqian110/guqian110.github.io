Title: 信噪比小结
Date: 2015-03-10 19:31
Category: Telecom
Tags: Telecom, SNR
slug: summary_of_snr_and_noise
Author: Qian Gu
Summary: 学而时习之，总结一下信噪比相关的小知识

所谓 `信噪比（SNR, Signal-to-noise ratio）` 就是指 信号的功率 和噪声的功率 的比值。我们可以用它来比较信号的和背景噪声的相对大小，如果比值大于 1（0 dB），说明信号功率比噪声功率强。

## SNR Def
* * *

信噪比的定义式：

![def](http://upload.wikimedia.org/math/f/0/e/f0e032777062c3f945554f1c63d9c864.png)

这里 `P` 表示信号/噪声的平均功率。

+ 如果信号和噪声的方差已知，且两者的均值都为0，则信噪比可以写为下式：

	![eq1](http://upload.wikimedia.org/math/9/0/9/9098fa286b51274407110dd98832b8b7.png)

+ 如果信号和噪声是使用相同的阻抗来测量的（功率这个词本来就源于物理，在电子系统中，功率 `P = UI = V^2/R`），那么信噪比公式可以用幅度的平方比值来计算：

	![eq2](http://upload.wikimedia.org/math/6/9/d/69d4d7d398cf17a0184463ae42b4b18b.png)

	其中 `A` 为信号/噪声的 `均方根（ root mean square, RMS）`

+ 一般信号的动态范围都很大，所以通常采用分贝的方式来表示信噪比

	![ep3](http://upload.wikimedia.org/math/8/e/7/8e7f17468834710c835579e252528515.png)

	把 均方根 带入，就可以得到下面的公式

	![eq4](http://upload.wikimedia.org/math/6/f/7/6f7dd3340b9b31a3d3afa11532c5480e.png)

+ 一般 SNR 指的是 **平均** 信噪比，因为通常 SNR  的瞬时值是不同的

+ 信噪比的概念也可以这么理解：将噪声的功率归一化为 1（0 dB），看信号的功率可以达到多大

<br>

## SNR in telecom
* * *

在物理学中，交流电信号的 平均功率 = (电压×电流) 的均值，如下式：

![eq5](http://upload.wikimedia.org/math/b/a/1/ba1615e4d1dc51196247c5a912227dba.png)

![eq6](http://upload.wikimedia.org/math/c/6/9/c69fbca997fb4cc8a82823fe47c2e47d.png)

但是在信号处理和通信中，一般假设电阻的阻值为 1 欧姆，所以在计算能量、功率时，电阻因子会被忽略。这可能会引起一些困扰。

所以信号的功率表示式简化为下面的公式：

![eq7](http://upload.wikimedia.org/math/a/e/7/ae780e83e953d7329de754a42fcddb63.png)

（其中，`A` 是交流信号的幅度）

### Eb/N0

在数字系统中可以使用 SNR 表示噪声的等级，但是更常用的是 `Eb/N0 (energy per bit to noise power spectral density ratio)`。

Eb/N0 是一种归一化的 SNR，称为 “ SNR 每 bit ”，在比较不同的调制方案的 `误比特率（BER, bit error rate）` 性能时，因为这种方法不考虑带宽的因素，所以很有效。

其中 Eb 是平均比特能量，它表示平均每个 bit 包含的能量。

<br>

## AWGN
* * *

高斯分布（`Gaussian distribution`）可以使用 `N(μ,σ2 )` 来表示，其中 μ 是均值，σ 是标准差。

对噪声进行建模，最简单的就是 **加性高斯白噪声 (AWGN, Additive White Gaussian Noise)**。

+ 加性：叠加在信号之上，而且无论有无信号，噪声都是始终存在

+ 高斯：噪声幅度的取值是随机过程，它的概率密度函数服从高斯分布

+ 白噪声：噪声的功率谱密度函数取值是常数，在坐标系中表现为一条直线，在每个频率点的谱密度都一样，就像白光包含各种频率的光一样，所以叫做白噪声。

同时满足这三个的条件的噪声就叫做 加性高斯白噪声。

高斯白噪声的功率谱函数：`P(f) = N0/2`，

其中 `N0` 是 **单边噪声功率谱密度**，`N0/2` 是 **双边噪声功率谱密度**。

因为功率谱密度函数的定义域是无穷大的，所以高斯噪声的功率也是无穷大的，它的功率只有在带限时才有意义。

在计算前面 SNR 时，我们可以使用下面两种方法来得到 Pn：

1. 如果均值为 0，`Pn = 方差 σ2 = R(0)`

2. 如果已知功率谱密度函数 P(f)，那么直接对其定积分

<br>

## Ref

[Signal-to-noise ratio](http://en.wikipedia.org/wiki/Signal-to-noise_ratio)

[Eb/N0](http://en.wikipedia.org/wiki/Eb/N0)

[Gaussian noise](http://en.wikipedia.org/wiki/Gaussian_noise)

[关于白噪声功率谱密度和方差的关系 ](http://bbs.c114.net/thread-663445-1-1.html)
