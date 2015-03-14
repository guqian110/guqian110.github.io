Title: 锁存器 Latch v.s. 触发器 Flip-Flop
Date: 2014-09-23 23:02
Category: FPGA
Tags: latch, flip-flop
Slug: latch_versus_flip_flop
Author: Qian Gu
Summary: 总结 Latch 和 Flip-Flop


根据 [Wiki: Flip-flop (electronics)][wiki] 上的介绍

> In electronics, a `flip-flop` or `latch` is a circuit that has two stable states and can be used to store state information. A flip-flop is a `bistable multivibrator`. The circuit can be made to change state by signals applied to one or more control inputs and will have one or two outputs. It is the basic storage element in sequential logic. Flip-flops and latches are a fundamental building block of digital electronics systems used in computers, communications, and many other types of systems.

区别一下名字：

> Flip-flops can be either simple (transparent or opaque) or clocked (synchronous or edge-triggered). Although the term flip-flop has historically referred generically to both simple and clocked circuits, in modern usage it is common to reserve the term flip-flop exclusively for discussing clocked circuits; the simple ones are commonly called latches.
>
> Using this terminology, a latch is level-sensitive, whereas a flip-flop is edge-sensitive. That is, when a latch is enabled it becomes transparent, while a flip flop's output only changes on a single type (positive going or negative going) of clock edge.

所以按照现在的约定习惯区分，latch 指的是电平触发的触发器，翻译为 “锁存器”；flip-flop 指边沿触发的触发器，就叫 “触发器”。

[wiki]: http://en.wikipedia.org/wiki/Flip-flop_(electronics

<br>

[TOC]

## History
* * *

*翻译自 [wiki][wiki]:*

第一个电子触发器(electronic flip-flop) 由  William Eccles 和 F. W. Jordan 于 1918 年发明的。它最早被称为 ：  `Eccles–Jordan trigger circuit`，由两个真空管组成。虽然现在由逻辑门 (logic gates)组成的触发器很常见，但是在集成电路(intergrated circuits)中，这种元件及它的晶体管版本仍然也很常见。早期的触发器常用来构成触发电路或者多谐振荡器(multivibrators)。

![flip-flop](http://upload.wikimedia.org/wikipedia/commons/9/98/Eccles-Jordan_trigger_circuit_flip-flip_drawings.png)

根据一个 JPL 的工程师，P. L. Lindley介绍，Montgomery Phister 于 1954 年在 UCLA 的 computer design 的课程上第一次对触发器进行了分类的讨论（RS、D、T、JK），然后在他的书 Logical Design of Digital Computers 中也进行了讨论。Lindley 当时在 Hughes Aircraft 的 Eldred Nelson 手下工作，而Nelson 命名了 JK 触发器。其他的名字则是 Phister 命名的。Lindley 解释说他是从 Nelson 口中得知 JK 触发器的故事的，当时 Hughes Aircraft 使用的触发器都是 JK 触发器。在设计逻辑系统时，Nelson 给触发器的输入命名为 A&B、C&D、E&F、G&H、J&K。在 1953 年 Nelson 申请专利时，采用了 J&K 的命名方案。

<br>

## Implementation
* * *

> Flip-flops can be either simple (transparent or asynchronous) or clocked (synchronous); the transparent ones are commonly called latches. The word latch is mainly used for storage elements, while clocked devices are described as flip-flops.

不会翻译了...大意就是说 flip-flop 可以分为两类：

+ simple

    也可以说是 透明的(transparent) 或者是 异步的(asynchronous)，通常称为 `锁存器Latch`

+ clocked

    也可以说是 同步的(synchronous)，称为 `触发器flip-flop`

下面分类讨论：

### Latch

Latch 可以由一对真空管、三极管、场效应管组成，在实际应用中也可以用逻辑门组成 latch。

#### SR Latch

当使用逻辑门搭建模块时，最基本的 latch 就是 `SR latch` (set-reset latch)，所有的 latch 和 flip-flop 都是建立在它的基础之上。

SR latch 的实现可以有两种方案：

+ **SR NOR Latch**

    使用或非门搭建：
    
    ![nor](http://upload.wikimedia.org/wikipedia/commons/c/c6/R-S_mk2.gif)
    
    功能表：
    
    ![nor](/images/latch_versus_flip_flop/nor.png)
    
+ **S'R' NAND Latch**

    使用与非门搭建：
    
    ![nand](http://upload.wikimedia.org/wikipedia/commons/thumb/9/92/SR_Flip-flop_Diagram.svg/500px-SR_Flip-flop_Diagram.svg.png)
    
    功能表：
    
    ![nand](/images/latch_versus_flip_flop/nand.png)
    
    
#### D Latch

Latch 是 `透明的(transparent)`，就是说输入的变换立即就能传递到输出端口，当几个透明的 latch 级联时，输入端的信号也能立即传递到输出端。当给 latch 添加额外的逻辑电路（比如使能信号 enable 无效时），就会使它变为 `不透明的(non-transparent)`。下面的 D latch 就是这样的例子。

仔细观察 SR latch 的功能表，就可以发现，R 的取值为 S 的补。D latch 利用了这一特点，而且避免了 SR latch 中的禁止状态的出现。

因为 SR latch 的实现有两种，所以 `D latch` 的实现也对应有两种：

+ **NOR D Latch**

    ![nor d latch](http://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/D-type_Transparent_Latch_%28NOR%29.svg/500px-D-type_Transparent_Latch_%28NOR%29.svg.png)

+ **NAND D Latch**

    ![nand d latch](http://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/D-Type_Transparent_Latch.svg/500px-D-Type_Transparent_Latch.svg.png)
    
D latch 的功能表：

![d latch](/images/latch_versus_flip_flop/d_latch.png)

D latch 也称为  non-transparent、data latch、gated latch。它有一个数据输入端和一个使能端 enable(clock、control)。之所以叫透明，是因为当它使能时，输入端口的信号立刻就能传递到输出端口。

### Flip-Flop

如果 D latch 的控制端口加入时钟信号，就得到了基本触发器，只要时钟信号 CP = 1，则触发器就会受到触发，当 CP 保持为 1 时，数据输入端口的任何变化都将影响到 latch 的状态。

latch 的这个特点应用到 时序电路中，就会出现比较严重的问题：

一般时序逻辑的输出会经过组合电路的反馈通道，返回到时序逻辑的输入。当时钟信号有效时，latch 的输出通过组合电路反馈到 latch 的输入端，如果经过组合逻辑后，反馈的信号和之前的信号不同，则反馈信号会导致 latch 的输出变为新的值。在时钟信号有效的期间内，latch 的输出一直在变化，出现了不可预测的结果，这是不可靠的工作。

latch 的**问题**就在于：*它在时钟有效期间内一直在被触发，这种触发时间过长。*

这个问题的**解决方法**就是：*将触发条件变为时钟沿触发，这样就得到了触发器 `flip-flop`*

#### D flip-flop

将 latch 改造为边沿敏感的触发器，最简单的就是 `D flip-flop` (data or delay)，搭建电路最经济有效的方法就是使用 DFF，因为它需要的门电路最少，其他类型的触发器都是在 DFF 的基础上得到的。

实现 DFF 可以有两种方法：

+ **Classical positive-edge-triggered D flip-flop**

    ![classical](http://upload.wikimedia.org/wikipedia/en/thumb/9/99/Edge_triggered_D_flip_flop.svg/500px-Edge_triggered_D_flip_flop.svg.png)

+ **Master–slave edge-triggered D flip-flop**

    ![master-slave](http://upload.wikimedia.org/wikipedia/en/thumb/5/52/Negative-edge_triggered_master_slave_D_flip-flop.svg/500px-Negative-edge_triggered_master_slave_D_flip-flop.svg.png)
    
    clk = 1 时，master D-latch 使能，D 传递到输出端 Q；
    
    clk = 0 时，slave D-latch 使能，输入 D (master D-latch 的输出 Q) 传递到输出 Q；
    
    可以看到，当 clk 从 1 变为 0 时，输入端的 D 才传递到输出端 Q，也就是说在时钟的下降沿才触发，其他时刻都保持输出不变。（如果需要上升沿触发，只需要在 clk 输入端键入一个反相器）
    
DFF 的特点就是在时钟信号的特定点触发（上升沿 or 下降沿），功能表：

![dff](/images/latch_versus_flip_flop/dff.png)
    
#### JK flip-flop

在 DFF 的基础上，可以得到 JK FF。

JK FF 的特点和 SR latch 类似，可以将 J 看作是 S，K 看作是 R，它和 SR latch 的区别在于它是边沿触发，并且将 S = R = 1 状态设置为 `翻转 (toggle)`，也就是在下一个时钟边沿，输出取反。当 J = K = 0 时，得到的并不是 DFF，而是保持输出不变。

功能表：

![jk](/images/latch_versus_flip_flop/jk.png)

#### T flip-flop

将 JK FF 的输入端 J 和 K 连接到一起，就可以得到 `T FF` (toggle flip-flop)。

当 T = 0 (J = K = 0) 时，输出保持不变，时钟边沿不影响状态；当 T = 1 (J = K = 1) 时，在时钟边沿输出反相，也就是翻转。

功能表：

![tff](/images/latch_versus_flip_flop/tff.png)

可以看到 TFF 有 1/2 分频的作用，这一特点在很多电路中得到了应用。

<br>

## Timing considerations
* * *

### Metastability

伴随着 flip-flop 的一个问题是 `亚稳态 Metastability`。当两个输入端口 (比如 data 和 clk，或者 reset 和 clk)同时变化时，就会发生亚稳态的问题，需要消耗更长的时间来使输出达到稳定状态，而且这个稳定状态是不可预测的，有可能是 1，也有可能是 0。

在计算机系统中，如果发生亚稳态，如果在下一个时钟使用数据时，还没有达到稳定状态，会导致数据传输错误或者程序崩溃。如果有两条路径同时用到了这个数据，有可能一条将它当作 1，另一条把它当作 0，这样会导致系统进入不一致的状态。

### Setup, hold, recovery, removal times

> **Setup time** is the minimum amount of time the data signal should be held steady **before** the clock event so that the data are reliably sampled by the clock. This applies to synchronous input signals to the flip-flop.
> 
> **Hold time** is the minimum amount of time the data signal should be held steady **after** the clock event so that the data are reliably sampled. This applies to synchronous input signals to the flip-flop.
> 
> Synchronous signals (like Data) should be held steady from the set-up time to the hold time, where both times are relative to the clock signal.

![meta](http://upload.wikimedia.org/wikipedia/en/thumb/d/d9/FF_Tsetup_Thold_Toutput.svg/500px-FF_Tsetup_Thold_Toutput.svg.png)

如图所示，对于同步信号 (同步信号的意思是想对于时钟信号而言，它的变化和时钟是同步的，比如 data)，必须满足 `setup time` 和 `hold time` 要求。

在有效时钟沿到来之前的 setup time 时间段内，同步信号必须保持稳定，在有效时钟沿到来之后的 hold time 时间段内，同步信号也必须保持稳定，也就是说从 setup time 到 hold time 之间，它必须保持稳定不变化，这样才能让时钟信号采样到正确的值。

同理，对于异步信号，有类似的要求：

> **Recovery time** is like setup time for asynchronous ports (set, reset). It is the time available between the asynchronous signals going inactive and the active clock edge.
> 
> **Removal time** is like hold time for asynchronous ports (set, reset). It is the time between active clock edge and asynchronous signal going inactive.

找到一个更清晰的解释：

> **Recovery time** is the minimum length of time an asynchronous control signal, for example, and preset, must be stable **before** the next active clock edge. The recovery slack time calculation is similar to the clock setup slack time calculation, but it applies asynchronous control signals.

> **Removal time** is the minimum length of time an asynchronous control signal must be stable **after** the active clock edge. The TimeQuest analyzer removal time slack calculation is similar to the clock hold slack calculation, but it applies asynchronous control signals.

> recovery time specifies the time the inactive edge of the asynchronous signal has to arrive before the closing edge of the clock.

> Removal time specifies the length of time the active phase of the asynchronous signal has to be held after the closing edge of the clock.

也就是说 Recovery / Removal time 类似于 Setup / Hold Time，不过是用于异步信号，比如 set，reset 信号。

![recovery-removal](/images/latch_versus_flip_flop/recovery-removal.jpg)

如图所示，在时钟沿到来之前的 recovery time 之前，异步信号必须释放 (变无效)，在时钟沿到来之后的 removal time 之后，异步信号才能变有效，也就是说在从 recovery time 到 removal time 这段时间内，异步信号是不能有效的。

如果使 flip-flop 的输入满足 setup time 和 hold time，那么就可以避免亚稳态的出现，一般器件的手册上都会标明这些参数，从几 ns 到几百 ps 之间。根据 flip-flop 内的组织情况而定，有时候可以将 setup time 或者 hold time 两者中的一个（只能是其中之一）变为 0 甚至是负数。

但是，并不是总能满足这一标准，因为有可能 flip-flop 的输入端连到了外界的，设计者无法控制的一个不断变化的信号，这时候设计者所能做的事就是根据电路要求，将发生错误的概率降低到一个确定的水平。通常使用的方法就是将信号通过一条链在一起的 flip-flop 组，这样子可以将发生亚稳态的概率降低到一个可以忽略的程度，但是还是不等于 0。链中的 flip-flop 越多，这个概率就越趋近于 0，通常的情况是采用 1 个或者两个 flip-flop。

即使现在出现了所谓的 `metastable-hardened flip-flops`，它可以尽可能地减小 setup time 和 hold time，但是仍然无法完全避免问题的出现。**这是因为亚稳态并不是简单的设计方法上的问题。**当时钟信号和其他信号在相隔很近的时间内变化，flip-flop 必须判断哪一个先发生变化，哪一个后发生变化，无论我们的器件速度有多快，仍然有可能出现两者相隔的太近，以至于无法判断。所以理论上是不可能造出一个完美避免亚稳态的 flip-flop。

### Propagation delay

flip-flop 还有一个参数叫做 clock-to-output delay (common symbol in data sheets: `tco`) 或者是 propagation delay (`tp`)，表示的是 flip-flop 从有效时钟沿开始到输出发生变化所消耗的时间。有时候从高电平变为低电平的时间 (high-to-low transition, tPHL))和从低电平变为高电平的时间 (low-to-high transition, tPLH) 不相等。

当用同一时钟来驱动级联的 flip-flop (比如移位寄存器 shift register)时，必须保证前一级的 tco 要大于后一级的 th。这是因为必须要保证前一级的数据能够正确移位到后一级中。当有效时钟沿到来时，前后两级的 ff 在同时变化，采样前一级的输出作为本级的输入，然后经过 tco 输出更新的值。当后一级 ff 在 tsu 到 th 段内采样时，必须保证前一级的输出保持不变，也就是说前一级 ff 的响应速度不能太快，至少要等后一级正确采样完成之后才能变化，即 `tco > th`。如果采用物理构造完全相同的 ff，那么通常是可以保证这一条件的。

<br>

## in FPGA
* * *

latch 和 flip-flop 的特点决定了它们各自的应用场景

**latch 的优点：**

1. 面积比 ff 小

    门电路是构建组合逻辑电路的基础，而锁存器和触发器是构建时序逻辑电路的基础。门电路是由晶体管构成的，锁存器是由门电路构成的，而触发器是由锁存器构成的。也就是 晶体管->门电路->锁存器->触发器，前一级是后一级的基础。latch完成同一个功能所需要的门较触发器要少，所以在asic中用的较多。
    
2. 速度比 ff 快

    用在地址锁存是很合适的，不过一定要保证所有的latch信号源的质量，锁存器在CPU设计中很常见，正是由于它的应用使得CPU的速度比外部IO部件逻辑快许多。
    
**latch 的缺点：**

1. 电平触发，非同步设计，受布线延迟影响较大，很难保证输出没有毛刺产生

2. latch将静态时序分析变得极为复杂

**flip-flop 的优点：**

1. 边沿触发，同步设计，不容易受毛刺的印象

2. 时序分析简单

**flip-flop 的缺点：**

1. 面积比 latch 大，消耗的门电路比 latch 多


目前 latch 只在极高端的电路中使用，如 intel 的 P4 等 CPU。而在 PLD / FPGA 中，基本单元 LE 是查找表 LUT 和触发器 FF 组成的，如果要实现 latch，反而需要更多的资源。

**一般的设计规则是：**

在绝大多数设计中避免产生 latch。它会让您设计的时序完蛋，并且它的隐蔽性很强，非老手不能查出。latch 最大的危害在于不能过滤毛刺。这对于下一级电路是极其危险的。所以，只要能用 DFF 的地方，就不用 latch。

### Reason & Solution to unexpected latch

在电路设计中，要对Latch特别谨慎，如果综合出和设计意图不一致的 Latch，会导致设计错误，包括仿真和综合。因此，要避免产生意外的 Latch。

#### Reason

如果组合逻辑完全不使用 always 语句，那么就不会产生 latch，比如

    #!verilog
    assign dout = din ? x : y;
    
电路不需要保存 dout 的前一个值，所以不会产生 latch。
    
如果组合逻辑使用了 always 语句，那么就有可能产生 Latch ：

1. 不完整的 if-else

    code:
    
        #!verilog
        always @(din_a or din_b) begin
            if (din_a) begin
                dout = din_b;
            end
        end

    RTL Schematic:
    
    ![if_latch](/images/latch_versus_flip_flop/if_latch.png)

2. 不完整的 case

    code:
    
        #!verilog
        always @(din_c or din_a or din_b) begin
            case (din_c)
                2'b00: dout = din_a;
                2'b01: dout = din_b;
            endcase
        end
        
    RTL Schematic:
    
    ![case_latch](/images/latch_versus_flip_flop/case_latch.png)
    
#### Solution

知道了原因，那么解决方法也就显而易见了：

1. 使用完整的 if-else

    code:
    
        #!verilog
        always @(din_a or din_b) begin
            if (din_a) begin
                dout = din_b;
            end
            else begin
                dout = din_a;
            end
        end

    RTL Schematic:
    
    ![if-else](/images/latch_versus_flip_flop/if_else.png)
    
2. 使用完整的 case，添加 default 分支

    code:
    
        #!verilog
        always @(din_c or din_a or din_b) begin
            case (din_c)
                2'b00: dout = din_a;
                2'b01: dout = din_b;
                default: dout = 2'b00;
            endcase
        end

    RTL Schemtatic:
    
    ![case-default](/images/latch_versus_flip_flop/case_default.png)
    
### Application

[《Verilog HDL 程序设计与实践》][verilog] 笔记：

> latch 作为一种电路单元,必然有其存在的理由以及应用场景,并不像目前的很多书籍简单地将锁存器列为“头等敌人”。其实在实际中,有些设计是不可避免地要用到锁存器,特别是在总线应用上,锁存器能提高驱动能力、隔离前后级。例如,常见的应用包括地址锁存器、数据锁存器以及复位信号锁存器等。但在更多的情况下,很容易在代码中产生未预料到的锁存器,使得逻辑功能不满足要求,浪费了大量的调试时间,从而使得大多数设计人员“闻虎色变”。
> 
> 因此较好的应用规则是:**要学会分析是否需要锁存器以及代码是否会产生意想不到的锁存器。只有这样才能灵活运用锁存器。**
> 
> 下面通过实例来给予说明。
>
> **example1**: 通过Verilog HDL实现序列最大值搜索程序，并保持检测到的最大值
>
>       module latch_demo(  
>               din,dout  
>           );  
>           input   [7:0] din;  
>           output [7:0] dout;  
>     
>           reg      [7:0] dout;  
>     
>       always @ (din) begin  
>            if (din > 127)  
>                 dout = din;  
>       end  
>  
>       endmodule  
>
> 上述代码在ISE中的综合结果会给出设计中包含Latch的警告。但实际上，abmax_tmp锁存器正是我们需要的，所以，虽然有警告，但是代码设计是没有问题的。将上述代码的if语句补全：
> 
>      if (a > abmax_tmp)  
>           abmax_tmp = a;  
>       else  
>           abmax_tmp = abmax_tmp;  
>
> 经过综合后，仍然有Latch的警告。无论Latch是否是用户需要的，ISE都会给出警告，主要原因就是Latch对整个设计的时序性能影响较大。所以，在设计中要尽量避免Latch，但是确实需要使用的情况，也可以使用。
>
> **example2:** 用Verilog HDL实现一个锁存器，当输入数据大于127时，将输入数据输出，否则输出0
> 
> 不期望的 latch 指的是与设计意图不符，产生的 Latch。主要问题在于设计人员没有合理使用Verilog HDL语言，常见的原因是对条件语句（if、casse）的分支描述不完整，导致电路的功能不是预期的，发生了错误。
>
>       module latch_demo(  
>           din,dout  
>       );  
>       input   [7:0] din;  
>       output  [7:0] dout;  
>  
>       reg      [7:0] dout;  
>  
>       always @ (din) begin  
>            if (din > 127)  
>                 dout = din;  
>       end  
>  
>       endmodule  
>
> 综合后的结果，在比较器后面级联了锁存器，这是因为if语句缺少else分支造成的。查看仿真结果，当输入小于127时，输出保持了上次的127，不是0，没有达到设计要求。修改方法很简单，就是将if-else补全。
>
>        if (din > 127 )
>            dout = din;  
>        else  
>            dout = 0;
>
> 在ISE中综合后的结果中，可以看到补全if-else后，在比较器后面级联了与门，代替原来的锁存器，仿真结果也正确。

### Conclusion

锁存器 latch 是一种基本电路单元,会影响到电路的时序性能,应该尽量避免使用,但出现锁存器造成设计和原始意图不符的情况,则是由于设计人员代码输入不正确造成的。

[verilog]: http://book.douban.com/subject/3522845/

<br>

## Reference

[Flip-flop (electronics) --wikipedia][wiki]

[数字设计](http://book.douban.com/subject/2883561/)

[Verilog HDL 程序设计与实践][verilog]

[锁存器、触发器、寄存器和缓冲器的区别](http://blog.csdn.net/surgeddd/article/details/4683657)
