Title: FPGA 数字处理基础 (2)
Date: 2014-07-07 23:28
Category: FPGA
Tags: FPGA, digital processing
Slug: fpga_digital_processing_basic_2
Author: Chien Gu
Summary: 总结 FPGA 处理数字信号的基础知识 (2)

讨论 FPGA 中无符号数 unsigned 和有符号数 signed 的问题。

## Basic Knowledge
* * *

**整数的分类：** 无符号数 `unsigned` 和 有符号数 `signed`。

**数制：** 10、2、8、16 进制

**机器数：** 机器数的意思是数字在机器中的表示方式。主要有 3 种

`原码 sign-magnitude`、`反码 one's complement`、`补码 two's complement`

以前写过的一篇总结： [原码、反码、补码][article1]

**计算机系统：** 采用二进制、补码系统。

<br>

*FPGA 中是如何表示数字的呢？*

以前写过一篇总结，[FPGA 数字处理基础 (1)][article2]

本文算是上面文章的续吧。

[article1]: http://guqian110.github.io/pages/2014/03/19/signed_number_representations.html
[article2]: http://guqian110.github.io/pages/2014/05/14/fpga_digital_processing_basic_1.html

<br>

## (un)signed in Verilog
* * *

### Integer

在 Verilog 中表示一个整数可以有两种方法：

1. 简单的数字

    即只有简单的数字，默认为有符号数。比如 8, -10
    
2. 基数表示法 `<size>'<s><base><value>`

    其中，size 指定需要多少位表示这个数字，有 s 表示这个数为有符号数，没有则表示这个数是无符号数，base 指定后面的 value 是使用哪种基数来描述，value 制定这个数字的大小。默认为无符号数，除非声明 s 字段。
    
**在 FPGA 也采用补码系统**，即在综合时，综合工具会将有符号数翻译为补码，在硬件中存储起来。
    
    4'd5   // 这个数为无符号数，理解为 5, 占用 8 bit，存储的值为 0101
    4'sd5  // 这个数为有符号数，理解为 5, 占用 8 bit，存储的值为 0101
    -4'd5  // 这个数为无符号数，理解为 -5, 占用 8 bit，存储的值为 1011
    -4‘sd5 // 这个数为有符号数，理解为 -5, 占用 8 bit，存储的值为 1011
    
### Register

Verilog 中数据的基本类型： `wire`、`reg`、`integer`

在 Verilog-1995 中，规定所有的 wire、reg 都是 unsigned 类型，只有 integer 是 signed 类型。但是 integer 的宽度是固定的(与宿主机的字是一样的，最小为 32 位)，这样子，造成了很大的不方便和浪费。

在 Verilog-2001 中，添加了 wire、reg 也可以是 signed 类型了。

    reg             [8:0]   a;  // unsigned
    reg     signed  [8:0]   b;  // signed

<br>

**Problem**

> 数据可以是 signed 和 unsigned，寄存器也可以是 signed 和 unsigned，那么综合时，是以哪个为准呢？

这个问题一开始自己没有搞清楚，迷惑了一下午，后来写了几个小测试程序，最后发现这个结论：

**Conclusion** 

> 1. *以变量类型为准*
>
>       即 reg/wire 为哪种，那么综合时就以这个为标准进行综合。比如当 reg 为 unsigned 类型，当我们给它赋值为 signed 类型的数据 `-5`(`-4’d5`) 时，综合出来的结果为 reg 存储的是 `-5` 的补码 `1011`,但是解释为 unsigned 类型的 `+11`。这时候就结果和我们的预期是不一样的，出现了误差，一定要注意！另一种情况类似。
> 2. 如果参与运算的变量混合有 signed 和 unsigned 类型，那么会将 signed 转换为 unsigned 类型。(应该避免这种情况)

<br>

=========================================以下为详细的分类讨论==================================

编写一个简单的测试程序，查看综合结果和仿真波形，就可以知道综合时的策略。

**module: [test_signed.v][test_signed]**

**testbench: [tb_test_signed.v][tb_test_signed]**

#### 1. unsigned reg & unsigned value

定义 reg 为 unsigned 类型

    reg     [SIZE - 1 : 0]  i;      // unsigned
    reg     [SIZE - 1 : 0]  flag;   // unsigned
    
赋值为 unsigned 类型

    flag <= 8'd10;  // unsigned

那么可以从 RTL Schematic 中看到，综合出来的比较器是 unsigned 类型。

#### 2. unsigned reg & signed value

定义 reg 为 unsigned 类型

    reg     [SIZE - 1 : 0]  i;      // unsigned
    reg     [SIZE - 1 : 0]  flag;   // unsigned
    
赋值为 signed 类型

    flag <= -8'sd10;    // signed

那么综合出来的比较器是 unsigned 类型。

#### 3. signed reg & signed value

定义 reg 为 signed 类型

    reg     signed  [SIZE - 1 : 0]  i;      // signed
    reg     signed  [SIZE - 1 : 0]  flag;   // signed
    
赋值为 signed 类型

    flag <= -8'sd10;    // signed

那么综合出来的比较器是 signed 类型。

#### 4. signed reg & unsigned value

定义 reg 为 signed 类型

    reg     signed  [SIZE - 1 : 0]  i;      // signed
    reg     signed  [SIZE - 1 : 0]  flag;   // unsigned
    
赋值为 unsigned 类型

    flag <= 8'd10;  // unsigned

那么综合出来的比较器是 signed 类型。

#### 5. signed reg & unsigned reg

如果参与运算的两个变量一个是 signed，另一个是 unsigned。（注意这种现象应该避免，一般我们是不会将两种不同类型的数据混在一起进行计算的）

定义 i 为 unsigned 类型，flag 为 signed 类型

    reg             [SIZE - 1 : 0]  i;      // unsigned
    reg     signed  [SIZE - 1 : 0]  flag;   // signed

给 flag 赋值为 signed 的 -5

    flag <= -4'd5;      // sigend
    
综合出来的比较器为 unsigned 类型。

**P.S.** 变量 integer 也是也可综合的。在上例中，如果将 flag 的类型改为 integer 也是可综合的，但是，因为只用到了低 8 位，所以在综合时会提示高 24 位是未连接 unconnected，但是因为 integer 是一个整体，所以即使未连接也不能优化掉，这就是在 Verilog-1995 中 integer 不够灵活的体现，好在 Verilog-2001 中已经添加了支持 reg/wire 为 signed 的类型，而且综合工具(XST)也是支持的。

=======================================分割线结束==========================================

以前只知道硬件上最基本的一些运算单元，比如加法器(adder)、减法器(subtractor)、比较器(comparator) 等，完成的功能是固定的，电路是不会检查输入数据的类型的。涉及到 signed 和 unsigned 类型，就出现一个问题：对于基本运算单元(比如加法器)，运算单元并不知道输入的数据是哪种数据，对于 unsigned 和 signed 类型，必然出现适合一种时不适合另外一种的问题。

所以可以推断出 **对于不同的数据类型，同样是个加法器，底层的硬件电路是不一样的**。

如果我在程序中定义了 signed 和 unsigned 类型的数据，那么综合工具是否足够智能，能够根据数据的类型综合出正确适合的电路？

答案是肯定的，即**综合器足够智能**。

上面的程序证明了这一点，从 RTL 图中可以看到综合出的比较器是 signed 还是 unsigned 类型，仿真波形也可以看到，最终下载到板子上测试也符合预期。这些都证明 综合器足够智能。后来看到 [UG627(v14.5): XST User Guide][ug627]，才发现里面已经非常清楚地写着

Chapter 3: Signed and Unsigned Support in XST

> When using Verilog or VHDL in XST, some macros, such as adders or counters, can be
implemented for signed and unsigned values.
> To enable support for signed and unsigned values in Verilog, enable Verilog-2001
as follows:
> + ISE® Design Suite
>   Select Verilog 2001 as instructed in the Synthesis Options topic of ISE Design Suite
Help
> + XST Command Line
>   Set -verilog2001 to yes.

花费了大量时间上网找资料，在论坛里问别人无果，最后自己动手写程序测试，最后才发现原来官方资料里面早就写的清清楚楚 =.=

[test_signed]: http://guqian110.github.io/files/test_signed.v
[tb_test_signed]: http://guqian110.github.io/files/tb_test_signed.v
[ug627]: http://www.xilinx.com/support/documentation/sw_manuals/xilinx14_7/xst.pdf

<br>

## Conclusion
* * *

说了这么多，总结下来就是下面这几句话：

**经验：**

1. 遇到问题，先不要急着上网求助，上网求助这个方法虽然简单，但是是最不好的，一方面别人的话不一定可靠，另一方面，放弃思考直接上网求助对学习无益。

2. 找资料的技巧很重要。虽然我大概能够猜测到 Xilinx 官方的文档中肯定有说明，但是就是懒得去下载文档，再去找。认为网上肯定有人也有相同的困惑，所以直接 Google。结果找到一堆没有帮助的网页，浪费了时间，最后还是要看文档。

3. 实践是检验真理的唯一标准，到底行不行，写测试程序，在板子上跑跑，验证一下是最有力的证明。

**知识：**

1. Verilog-2001 已经支持 signed 类型的 wire 和 reg，所以我们代码中如果涉及到有符号数，那么像 C 语言一样直接定义、赋值、使用即可，综合工具会综合出正确的有符号数的运算电路。不必再像以前一样手动进行补码转换，自己来处理有符号数的补码计算的细节。

2. 综合时的原则是按照寄存器的类型进行综合(即上面的分类讨论的结论)。

3. 仔细对比 signed 和 unsigned 类型的综合结果，可以发现 Technology Schematic 是一样的，之所以和 “理论上硬件电路是应该不一样” 矛盾，我认为原因在于 FPGA 的实现是基于查找表的。以上面的例子来说明，这个比较器的功能最终是在一个 LUT6 的查找表上实现的，所以，ASIC 上硬件电路的不同映射到 FPGA 中就是 LUT 的内容不同。
