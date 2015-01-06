Title: LTE 咬尾卷积编码器的 Matlab 及 FPGA 实现
Date: 2015-01-07
Category: Com
Slug: tail_bitting_convolutional_code_implementation_in_matlab_and_fpga
Author: Qian Gu
Summary: 总结咬尾卷积编码的 Matlab 及 FPGA 实现方法。

## Tail Bitting 
* * *

咬尾卷积编码是一种特殊的卷积编码，它通过将编码器的移位寄存器的初始值设置为输入流的尾比特值，使得移位寄存器的初始和最终状态相同。和普通的卷积编码相比，咬尾的方案最大的优点是克服了编码时的码率损失，并且适合迭代译码，不过付出的代价是译码复杂度的增加。在 LTE 的标准中，咬尾卷积编码是一种备选的信道编码方案。

通常以 (n, k, K) 来描述卷积编码，其中：

+ `k` 表示编码器的 *输入码元数*

+ `n` 表示编码器的 *输出码元数*

+ `K` 表示编码器的 *约束长度*

由输入的 k 个信息比特，得到 n 个编码结果，所以 *编码效率* = k/n

约束长度 `K` 的意思是，编码结果不仅取决于当前输入的 k 比特信息，还取决于前 (K-1) 段时间内的信息位。在 k = 1 的条件下，编码器需要的 *移位寄存器级数* m = K - 1。

LTE 标准中编码器的结构如下图所示：

![coder](/images/tail-bitting-convolutional-code-implementation-in-matlab-and-fpga/coder.jpg)

+ 假设输入的比特流为 c1, c2, c3, ... 得到的编码结果为 d1, d2, d3, ...

+ 其中移位寄存器 D 从左到右一次是 S0, S1, ... S5。对其初始化时，S0 = Ck-1, S1 = Ck-2, ... S5 = Ck-6。

+ 进行编码时，有抽头的寄存器之间进行模 2 加法（即异或）运算。每次对一个输入信息完成编码之后，移位寄存器右移一位，抛弃最右端的移位结果，采用前一个输入作为最左端的信息位。

+ 当最后的比特进行编码完之后，寄存器又回到了设定的初始状态，就像一条蛇咬住了自己的尾巴，所以称为 咬尾 Tail Bitting。

+ 图中的 G1，G2, G3 是 *生成式*。

以上的内容已经提供了足够的信息供我们实现，关于更多的卷积编码、LTE 标准等请查阅 wiki 和专业书籍。

<br>

## Matlab Implementation
* * *

Matlab 的 `Communications System Toolbox` 中提供了大量的常用函数，其中就有卷积编码函数 `convenc`。我们就是基于这个函数实现LTE中的咬尾卷积编码。

通过

    help convenc

和 hlep browser，可以查到这个函数的用法，简单解释如下:

convenc 函数有几种方式来调用：

    CODE = convenc(MSG, TRELLIS)

    CODE = convenc(MSG, TRELLIS, PUNCPAT)

    CODE = convenc(..., INIT_STATE)

+ 第一个参数 `MSG` 是待编码的信息比特

+ 第二个参数 `TRELLIS` 是编码器的栅格描述

    TRELLIS 是 Matlab 内部定义的一种数据结构，它的值可以按照语法定义，更方便的方法是通过 `poly2trellis` 这个函数，由多项式描述方式转化得到。

    查阅 poly2trellis 的 help 就可以看到它的用法。

        trellis = poly2trellis(ConstraintLength, CodeGenerator)

    其中，`ConstraintLength` 是个 1×k 维的向量，表示编码器的约束长度；`CodeGenerator` 是个 k×n 维的向量，表示编码器中各个寄存器的抽头。

    help 中以一个 2/3 码率的编码器为例，其结构如下图所示：

    ![exmaple](/images/tail-bitting-convolutional-code-implementation-in-matlab-and-fpga/example.png)

    两组寄存器的长度分别为 4 和 3，所以 constraintlength 的取值为 [5, 4]；将每路输出的抽头用 8 进制来表示，即可得到 codegenerator 的取值 [27, 33, 0; 0, 5, 13]，表示第一路输出由第一组寄存器的 27 组合方式 + 第二组寄存器的 0 组合方式得到，第二路输出由第一组寄存器的 33 组合方式 + 第二组寄存器的 5 组合方式得到，第三路同理。

    应用到我们的编码器中，很容易写出其栅格描述

        tre = poly2trellis(7, [133, 171, 165]);

+ 第三个参数 INIT_STATE 是移位寄存器的初始值

    `INIT_STATE` 用来设定寄存器的初始状态，其取值就是寄存器的值。

    在下面的程序中，我们的测试向量的最后 6 bit 为 010110，所以对应的

        init = 22;

综上，可以写出 matlab 程序来实现咬尾卷积编码，如下：

    #!matlab
    clear;  
    % using a to test coder
    a = [0, 0, 0, 1, 1, 0, 1, 0];
    % describe the coder
    tre = poly2trellis(7, [133, 171, 165]);
    % init state is depend on a
    init = 22;
    % encode
    b = convenc(a, tre, init);

得到的编码结果是：

    0  1   0   1   0   1   1   1   0   0   1   1   0   1   1   1   0   0   1   1   0   1   0   0

数据的格式是将 3 位并行结果串行输出： d00, d01, d02, d10, d11, d12, ...

<br>

## Verlog Implementation
* * *

用 verilog 来实现编码器就相对简单直观的多，毕竟只有一组移位寄存器和一些抽头的异或运算。

### module & testbench

[module](https://github.com/guqian110/guqian110.github.io/blob/master/files/tbce.v)

[testbench](https://github.com/guqian110/guqian110.github.io/blob/master/files/tb_tbce.v)

### simulation

如下图所示

![sim1](/images/tail-bitting-convolutional-code-implementation-in-matlab-and-fpga/sim1.png)

![sim2](images/tail-bitting-convolutional-code-implementation-in-matlab-and-fpga/sim2.png)

和 matlab 中结果对比，结果是一致的。

## Summary
* * *

一个简单的咬尾卷积编码花费了一上午的时间才搞定，最大的收获就是：心态很重要，欲速则不达。没有认真看 help 就写程序，本来想节省时间，结果去相反 =.=

戒骄戒躁！！！

<br>

## Reference

[通信原理](http://book.douban.com/subject/1446684/)

[无线通信新协议与新算法](http://book.douban.com/subject/24784764/)
