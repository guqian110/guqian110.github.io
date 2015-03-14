Title: 原码、反码、补码
Date: 2014-03-19 14:31
Category: Telecom
Tags: Code
Slug: signed_number_representations
Author: Qian Gu
Summary: 最近找到一本好书——《编码: 隐匿在计算机软硬件背后的语言》 。作者是大名鼎鼎的 Charles Petzold 。看到用继电器搭建加法器、减法器，讨论二进制编码方式那章，想起一直不是很清楚的原码、反码、补码等，果断 Google、Wiki，于是总结出下文 。

最近找到一本好书——[《编码: 隐匿在计算机软硬件背后的语言》][bianma]。作者是大名鼎鼎的 [Charles Petzold][CPwiki] ([个人网站][CP])。书的介绍也很有意思，据说完全不懂计算机的人也能看懂...于是买了本来拜读一下（这种文章当然是英文版最好了，只是学生党没银子，只好买翻译版了）

看到用继电器搭建加法器、减法器，讨论二进制编码方式那章，想起一直不是很清楚的原码、反码、补码等，果断 [Google][G]、[Wiki][W]，于是总结出下文。

[bianma]: http://book.douban.com/subject/4822685/
[CPwiki]: http://en.wikipedia.org/wiki/Charles_Petzold
[CP]: http://charlespetzold.com/
[code]: http://www.charlespetzold.com/code/
[G]: https://www.google.com.hk/
[W]: http://en.wikipedia.org/wiki/Main_Page

<br>

##基本概念
* * *

###机器数

顾名思义，一个数字在机器中的存储方式，“*数* ” 是指 有符号数（`signed number`），即包含了正负号的数，“*机器* ” 当然是指计算机（`Computer`）了。

从小学毕业，刚进入初中，我们就知道数字是有符号的：*正数* & *负数*。但是在计算机的哲学体系中，整个世界只有两个元素：0 & 1 ，没有额外的专门表示正负号的符号。怎么办呢？解决方法就是添加一位来表示符号。于是，人们约定把符号位放在一个数字的 *最高有效位*（Most significant bit, `MSB`），在[大端序][big-endian]中，`MSB` 指的是一个二进制数的最左边的一位。一般，`MSB` 等于 0  表示正数，1 表示负数。

[big-endian]: http://zh.wikipedia.org/wiki/%E5%AD%97%E8%8A%82%E5%BA%8F#.E5.A4.A7.E7.AB.AF.E5.BA.8F

###真值

因为机器数中有一位表示符号，所以机器数的形式值不等于真正的数值，机器数对应的数值称为机器数的 *真值*。

<br>
举个栗子：

用 8 bit 表示一个数字，因为有符号位的存在，可以表示的范围为 (-127, -0, +0, +127) 。

	# +5 的 机器数 = 0000_0101 ；真值 = + 000_0101
	 
	# -5 的 机器数 = 1000_0101 ；真值 = - 000_0101

这种机器数的编码方式称为 [*原码*][sm] (`signed-magnitude`) ，是机器数编码方式中的一种。

[sm]: http://en.wikipedia.org/wiki/Signed_magnitude#Signed_magnitude_representation

<br>
> *The four best-known methods of extending the binary numeral system to represent signed numbers are: sign-and-magnitude, Ones' complement, two's complement, and excess-K.*

> *There is no definitive criterion by which any of the representations is universally superior. The representation used in most current computing devices is two's complement, although the Unisys ClearPath Dorado series mainframes use Ones' complement.*
（[Wikipeida][Wiki]）

<br>

下面分别讨论：

[Wiki]: http://en.wikipedia.org/wiki/Signed_number_representations

<br>

##机器数表示法
* * *

###原码（sign and magnitude）

####编码规则

	# 正数：  0_xxxxxxx
	
	# 负数：  1_xxxxxxx

8 bit 的原码可以表示的范围是 [ -127, -0, +0, +127 ]，共 255 个数
    
####计算法则

	# 两数符号相同：  低位相加，最高位的符号位不变（当低位相加产生进位时，溢出 Overflow）
 
	# 两数符号不同：  比较绝对值的大小，差的绝对值 = 大数 - 小数 ，符号位和大数的符号位相同

####缺点

1. 电路复杂

    + 从前面的计算方法中可以看到，原码中的符号位不能直接参与运算，必须要单独的线路来确定符号位
    + 原码的计算不能避免减法运算，加法运算是产生 *进位*，减法运算需要 *借位*，这是两种不同的运算过程，需要额外的电路把 `加法器` 改造为 `减法器`（[《编码》][code]这本书里面有详细介绍 如何使用继电器搭建 加法器 和 减法器）


2. 0的表示不唯一

    + 0可以编码为两种方式： `0000_0000` 和 `1000_0000`，进一步增加了逻辑的复杂性
    
####总结

This approach is directly comparable to the common way of showing a sign (placing a "+" or "−" next to the number's magnitude). Some early binary computers (e.g., [IBM 7090][7090]) used this representation, perhaps because of its natural relation to common usage. Signed magnitude is the most common way of representing the significand in floating point values.
（[Wiki][sm]）

[7090]: http://en.wikipedia.org/wiki/IBM_7090
<br>

> *虽然 `原码` 的编码方式最接近人类的习惯，但是，并不适合在计算机中使用，为了解决原码计算中的一些问题，于是 `反码` 就出现了*

<br>

###反码（Ones' complement）

首先，来看看 [Code][code] 中介绍了基于10进制的补码：

实现一个减法

`253 - 176 =？`

按照我们从数学课上学习到知识，这个计算需要进行 *借位* 操作，为了避免这个在计算机中很难实现的操作，可以稍微变化一下计算过程

`253 + (999-176) + 1 - 1000 = ?`

在这个过程中，用两个减法代替了原来的一个减法，避免了烦琐的 *借位* 操作。在这个运算中，负数 `-176` 转化为另外一个数 `999 - 176` ，这个数称为它的 `9 的补数(nine's complement)` 。

这个运算的关键在于：*把负数用 9 的补数表示，减法转化为加法* 。同理，我们推广到 2 进制，就得到了 `1 的补数(Ones' complement)` 。

把减数从一串 1 当中减去，结果就称为这个数的 “1 的补数”，在求 1 的补数的时候，其实并不需要做减法，因为求 1 的补数，只需要将原来的 1 变为 0 ，0 变为 1 即可，也就是取反，在电路中只需要一个反向器就可以实现，所以 `1 的补数` 也称为 `反码` 。

从上面的描述就可以很容易写出反码的编码规则
    
####编码规则

	# 正数    反码 = 原码
	
	# 负数    反码 = 符号位不变，其他位取反

8 bit 的反码可以表示的范围是 [ -127, -0, +0, +127 ]，共 255 个数
    
####计算法则

反码的计算不用区分符号和绝对值，直接进行计算，计算结果若有溢出，需要将溢出加到最低位，这种操作称为 “循环进位”（end-around carry）

####优缺点

1. 优点，电路简单

    + 因为不需要把符号和绝对值分开考虑，正数和负数的加法都一样算，所以反码计算不需要单独的判断符号的电路，也不需要判断两个数绝对值相对大小的电路
    + 节省了减法器，只需要一组额外的反向器就能把加法器改进为可以计算 加 / 减法

2. 缺点

    + 计算机中仍然需要进行 “循环进位” 的硬件电路，但是这种复杂度的电路是可以接受的
    + 0的表示不唯一，0的编码仍然有两种方式： `0000_0000` 和 `1111_1111`

<br>

####总结

The [PDP-1][PDP-1], [CDC 160 series][CDC 160 series], [CDC 6000 series][CDC 6000 series], [UNIVAC 1100 series][UNIVAC 1100 series], and the [LINC][LINC] computer used Ones' complement representation.（[Wiki][onecom]）

[PDP-1]: http://en.wikipedia.org/wiki/PDP-1
[CDC 160 series]: http://en.wikipedia.org/wiki/CDC_160_series
[CDC 6000 series]: http://en.wikipedia.org/wiki/CDC_6000_series
[UNIVAC 1100 series]: http://en.wikipedia.org/wiki/UNIVAC_1100
[LINC]: http://en.wikipedia.org/wiki/LINC
[onecom]: http://en.wikipedia.org/wiki/Signed_number_representations#Ones.27_complement

<br>

> *`反码` 中仍然没有避免 0 有两种编码方式的问题，虽然对于人来说，+0 和 -0 没有区别，但是对于计算机来说，判断一个数是否为0，要进行两次判断。为了解决 0 的表示问题和硬件上的 “循环进位”，于是人们又发明了 `补码`*

<br>

###补码（Two's complement）

前面介绍的

`253 - 176 =？`

按照反码的方法可以转换为

`253 + (999-176) + 1 - 1000 = ?`

如果我们稍微再变形一下，就有

`253 + (1000 - 176) - 1000 = ?`

在这个运算中 `-176` 转化为 `1000 - 176`，这个数称为它的 `10 的补数(ten's complement)` 。

这个运算的关键在于：*把负数用 10 的补数表示，减法转化为加法* 。同理，我们推广到 2 进制，就得到了 `2 的补数(two's complement)` 。

因为对一位二进制数 b 取补码就是 `1 - b + 1 = 10 - b`，相当于从 2 里面减去 b ,所以，这种方法称为 `2 的补数`，这种编码方式简称 `补码` 。

举例说明，要表示 -4 ，需要对 `0000_0100`取补码，`1111_1111 - 0000_0100 + 1 = 1_0000_0000 - 0000_0100`，相当于从2^8里面减去 4 。

从上面的计算过程可以很容易写出补码的编码规则

####编码规则

	# 正数    补码 = 原码
	
	# 负数    补码 = 反码 + 1

8 bit补码可以表示的范围是 [ -128, -1, +0, +127 ]，共 256 个数 。

目前大多数计算机内部使用的都是补码，所以对于编程中的 32 位 `int` 型变量，它可以表示的范围就是 [ -2^32, +2^32 - 1] 。

P.S. -128 没有对应的 原码 和反码，它的补码为 `1000_0000` 。

####计算法则

采用补码的系统，减法转换成加法（减法等同于加上一个负数，所以不再有减法），忽略计算结果最高位的进位，不必加回到最低位上去。

####优点

+ 电路简单，从计算法则中可以看到，不用考虑 “循环进位” 的问题，所以，补码系统的电路是最简单的，这也是补码系统应用最广泛的原因
+ 0 的表示是唯一的，`0000_0000`，不再有 -0 的困扰

####补码中的数学原理

补码能将减法转化为加法，其数学原理就是 *模* 。

举个栗子：

	# 如果有个手表的时间为6点，实际时间为4点，那么如何校准呢？
	
	# 答案有两种方法：
	
	#	1. 逆时针转动  2，也就是做 减法 6 - 2 = 4
	#	2. 顺时针转动 10, 也就是做 加法 (6 + 10) mod 12 = 4

从这个例子中就可以很明白的看到 *减法* 是如何转化为 *加法* 的，也就是如何将一个 *负数* 转化为 *正数*的 。

即有公式：

`A - B = A + (-B + M)`

这个式子中的 `-B + M` 即为 `B` 的 *补数* （类似于几何中的*补角*） 。

####溢出问题（摘自 [百度百科][baike]）

无论采用何种机器数，只要运算的结果大于数值设备所能表示数的范围，就会产生溢出。 溢出现象应当作一种故障来处理，因为它使结果数发生错误。异号两数相加时，实际是两数的绝对值相减，不可能产生溢出，但有可能出现正常进位；同号两数相加时，实际上是两数的绝对值相加，既可能产生溢出，也可能出现正常进位。

由于补码运算存在符号位进位自然丢失而运算结果正确的问题，因此，应区分补码的溢出与正常进位。

详细论证过程不再复制粘贴了...直接给出结论

结论：在相加过程中最高位产生的进位和次高位产生的进位如果相同则没有溢出，如果不同则表示有溢出。逻辑电路的实现可以把这两个进位连接到一个异或门，把异或门的输出连接到溢出标志位。

[baike]: http://baike.baidu.com/view/60437.htm

####总结
由 *“减去一个数 = 加上一个负数”*，计算机系统内部就不再有减法操作

由 *“负数的表示由取模运算转变为补码表示”*，计算机系统就可以用一个正数来表示负数

所以，计算机内部只需要加法器就可以完成 加减法 和 正负数 的表示 。

> *Two's complement is the easiest to implement in hardware, which may be the ultimate reason for its widespread popularity. Processors on the early mainframes often consisted of thousands of transistors – eliminating a significant number of transistors was a significant cost savings. Mainframes such as the IBM System/360, the GE-600 series, and the PDP-6 and PDP-10 used two's complement, as did minicomputers such as the PDP-5 and PDP-8 and the PDP-11 and VAX. The architects of the early integrated circuit-based CPUs (Intel 8080, etc.) chose to use two's complement math. As IC technology advanced, virtually all adopted two's complement technology. x86, m68k, Power Architecture, MIPS, SPARC, ARM, Itanium, PA-RISC, and DEC Alpha processors are all two's complement.*([Wiki][twocom])

[twocom]: http://en.wikipedia.org/wiki/Signed_number_representations#Two.27s_complement

<br/>

##有符号数和无符号数（摘自 [整数的加减运算][ref1]）
* * *
[ref1]: http://learn.akae.cn/media/ch14s03.html

如果把所有的位数都用来表示数值的大小，那么8 bit 二进制数可以表示的范围是 [0, 255] ，这种称为无符号数 。其实计算机做加法时并不区分操作数是有符号数还是无符号数，计算过程都一样 。

举个栗子：

        #   1000_0010              130                  -126
        # + 1111_1000     =>   +   256          =>  +   -  8
        # --------------      ---------------      -----------
        # 1_0111_1010              122 + 256             122
        
        #                        无符号数（ok）        有符号数（error）

计算机的加法器在做完计算之后，根据最高位产生的进位设置 *进位标志* ，同时根据最高位和次高位产生的进位的异或设置 *溢出标志* 。

如果看作无符号数130和248相加，计算结果是122进1，也就是122+256，这个结果是对的; 如果把这两个操作数看作有符号数-126和-8相加，计算结果是错的，因为产生了溢出 。

至于这个加法到底是有符号数加法还是无符号数加法则取决于程序怎么理解了，如果程序把它理解成有符号数加法，下一步就要检查溢出标志，如果程序把它理解成无符号数加法，下一步就要检查进位标志。

通常计算机在做算术运算之后还可能设置另外两个标志，如果计算结果的所有bit都是零则设置零标志，如果计算结果的最高位是1则设置负数标志，如果程序把计算结果理解成有符号数，也可以检查负数标志判断结果是正是负。

<br>

* * *
从 `原码` 到 `反码`，再到 `补码`，可以清楚看到为了解决问题而改进的技术路线，虽然这些是非常基础知识，可能对我们对写程序没有很大的帮助，但是搞清楚这些不仅让你对计算机底层更加了解，更加关键的是 *这个学习过程* 和 *解决编码问题的思路* 。

<br>

## 参考文献

[Signed number representations——Wiki][snr]

[Ones' complement][oc]

[Two's complement][tc]

[整数的加减运算][ref1]

[机器数——百度百科][baike]

[snr]: http://en.wikipedia.org/wiki/Signed_number_representations
[oc]: http://en.wikipedia.org/wiki/Ones'_complement
[tc]: http://en.wikipedia.org/wiki/Two's_complement
