Title: 低功耗设计
Date: 2015-06-18 21:42
Category: FPGA
Tags: 
Slug: low_power_design
Author: Qian Gu
Summary:

在一些情况下，是不需要考虑低功耗设计的，但是更多的情况下，低功耗是必须考虑的，总结一下 [THE ART OF HARDWARE ARCHITECTURE][the art] 中介绍的低功耗设计的方法。

[the art]: http://www.amazon.com/The-Art-Hardware-Architecture-Techniques/dp/1461403960

<br>

## Sources of Power Consumption
* * *

首先，分析功耗的来源。

功耗可以分为 3 类：

1. Inrush

    浪涌电流（Inrush current）也叫做启动电流（start-up current）。它指的是设备上电时产生的瞬间最大电流，这个值和设备有关。基于 SRAM 的 FPGA 有很大的浪涌电流，因为它需要从外部 ROM 中下载数据来配置内部逻辑资源，反之，基于 anti-fuse 的 FPGA 因为不需要上电配置，所以也就不存在浪涌电流。

2. Static

    待机电流（Standby current）是指待机状态下的电流，由待机电流产生的功耗称为待机功耗（standby power），也就是静态功耗（static power）。静态功耗和浪涌功耗类似，也和器件的电气特性密切相关。（静态功耗包含了晶体管的漏电流导致的功耗）

3. Dynamic

    动态功耗（Dynamic power）是门电路的逻辑值切换时产生的功耗。动态功耗可以从一个定义式中计算出来。

综上，ASIC 的总功耗定义为：

    Ptotal = Pdynamic + Pstatic

其中，动态功耗占了主要部分，典型应用中，动态功耗占到总功耗的 80% 。

<br>

## Power Reduction Power Reduction
* * *

可以从系统的不同层次来降低功耗，下图展示了不同级别的不同技术，虽然可以在各个级别进行，但是在抽象层次越高的级别，得到的效果越有效，即在系统层（system level）和体系结构层（architecture level）进行。

![level](/images/low-power-design/level.png)

下面一张表展示了各个级别对功耗降低程度的影响：

![opportunities](/images/low-power-design/opportunities.png)

<br>

*下面分别从不同层次总结。*

<br>

## System Level 
* * *

### SoC Approach

对于纳米级高端芯片，I/O 使用比芯片内核更高的电压，占到了总功耗的 50% 以上。如果有很多芯片的话，芯片之间的连线会消耗大量的功耗，所以就提出了 SoC，以缩减面积，降低成本。

### HW/SW Partitioning

相比于硬件，使用软件高级语言编程可以很方便的实现功能。但是，一些功能可以使用硬件来实现，来降低功耗。

比如通信算法中有很多递归运算，实现递归的软件代码可能很少，但是这段只占代码量的 10% 的代码却花费了 90% 的执行时间，如果将这段代码使用硬件实现，就能够节约大量能源，显著降低功耗。

常规的软硬件划分方法如下图所示：

![Partitioning](/images/low-power-design/partitioning.png)

典型的设计流程如下：

1. Specifications

2. Partitioning

3. Synthesis

4. Integration

5. Co-Simulation

6. Verification

首先，设计者根据规范和自身经验对系统性能做出推测，根据推测来决定系统哪部分用硬件实现，哪部分用软件实现。

然后，对软硬件进行描述，硬件用 Verilog/VHDL，软件使用 C 。

下一步对软硬件进行协同仿真，验证设计功能。如果不满足要求，则从系统划分开始重新再来。

### Low Power Software

软件设计部分也可以像硬件设计一样，在设计时就进行一些优化，得到更加绿色、高效的系统。

比如，将下面的两个循环合并为一个：

    // code1
    for i = 1 to n
        do a;
    end

    for i = 1 to n
        do b;
    end

    // code2
    for i = 1 to n
        do a;
        do b;
    end

因为减少了循环计数器（初始化、递增、比较），所以循环指令数目就减少了。

### Choice of Processor

选择处理器会对整体功耗产生明显影响。（高级话题，以后再补）

<br>

## Architecture Level Power Reduction
* * *

### Advanced Clock Gating

同步设计中，时钟占据了整个动态功耗的绝大部分，在许多情况下都可以通过门控时钟将绝大多数不使用的电路关闭掉。

门控时钟有如下的两种：

1. 组合门控时钟

![combinational](/images/low-power-design/combinational.png)

2. 时序门控时钟

![sequential](/images/low-power-design/sequential.png)

### Dynamic Voltage and Frequency Scaling (DVFS)

...

### Cache Based Architecture

缓存一方面可以缓解内存和 CPU 之间速度的差异，还可以用来减少访问内存的次数，把需要频繁访问的数据保存在缓存中，可以使得计算能耗大量下降。

### Log FFT Architecture

对于大规模运算的应用，使用对数系统（ logarithmic number system，LNS）比线性系统更好。LNS 在降低平均位元活跃度的同时用加法和奖罚实现乘除运算，使其效率比线性系统更高。

### Asynchronous (Clockless) Design

同步设计的时钟信号带来的问题很多，同时产生的功耗也很大，所以移除时钟是一个很有诱惑力的想法，这就是异步设计的基本意图，不过异步设计不是简单的移除时钟，仍然需要对电路进行某种控制。异步电路本质上进行自我控制，因此也成为自定时电路。

### Power Gating

...

### Multi-threshold Voltage

...

### Multi-supply Voltage

...

### Gate Memory Power

...

<br>

## Register Transfer Level (RTL) Power Reduction
* * *

在大规模 ASIC 中，在 RTL 级完成时，至少 80% 的功耗已经确定了，后端流程无法解决所有的功耗问题，后端无法解决微架构、RTL 代码风格对动态和静态功耗的影响，所以在 RTL 阶段就要将功耗相关的问题一起解决。

### State Machine Encoding and Decomposition

在各种状态机编码类型中，格雷码是最符合低功耗设计的。因为格雷码相邻码之间只有一位翻转，所以消耗的能量最少。（格雷码是最优的，有个 条件就是状态机是按顺序跳转的，如果状态跳转的次序是不定的，那么格雷码的优势就不存在了）

即使因为一些原因，没有使用格雷码，仍然可以通过降低翻转较多的状态的切换频率，来降低功耗。

还有一种方法是将 FSM 进行分解为两个，两个小的 FSM 组合起来等效于原始的 FSM。当一个的 FSM 激活时，可以关闭另外一个 FSM，这样绝大多数时间内只需要给较小且更有效率的子 FSM 提供时钟，从而降低了功耗。

### Binary Number Representation

虽然在大多数应用中，补码比原码更方便，但是有些特殊应用中，在切换过程中原码更有优势。比如 0 和 -1 分别用原码和补码表示：

    // Signed Magnitude
    0  -> 00000000
    -1 -> 10000001

    // 2's compliment
    0  -> 00000000
    -1 -> 11111111

当从 0 变为 1 时，原码只需要变化两位，而补码所有位都会变化。

### Basic Gated Clock

门控时钟在 Architecture 部分已经说过了，这里从 RTL 的角度再重复一下。RTL 的代码风格会影响到最终的实现结果，所以应该在编写 RTL 的时候需要特别注意。

    // bad example
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            test_ff <= 32'b0;
        else
            test_ff <= test_next;
    end

    assign test_next = load_cond ? test_data : test_ff;

    // good example
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            test_ff <= 32'b0;
        else if (load_cond)
            test_ff <= test_data;
    end

### One Hot Encoded Multiplexer

Mux 的编码方案也可以采用独热码的方式，从而减少开关切换的数目，降低功耗。

### Removing Redundant Transactions

有时候，一些没有意义的数据切换去掉，从而降低功耗。比如前级的逻辑产生一些数据，但是在后级逻辑中没有使用，这时候就可以修改设计，在前面一级就关闭，在需要数据的时候，让真正生成数据的电路工作。

### Resource Sharing

如果有一些相同的操作，那么可以使用资源共享的方法，避免运算逻辑重复出现。

    // bad example
    always @* begin
        case (SEL)
            3'b000: OUT = 1'b0;
            3'b001: OUT = 1'b1;
            3'b010: OUT = (value1 == value2);
            3'b011: OUT = (value1 != value2);
            3'b100: OUT = (value1 >= value2);
            3'b101: OUT = (value1 <= value2);
            3'b110: OUT = (value1 <  value2);
            3'b111: OUT = (value1 >  value2);
        endcase
    end

    // good example
    assign cmp_equal = (value1 == value2);
    assign cmp_greater = (value1 > value2);

    always @* begin
        case (SEL)
            3'b000: OUT = 1'b0;
            3'b001: OUT = 1'b1;
            3'b010: OUT = cmp_equal;
            3'b011: OUT = !cmp_equal;
            3'b100: OUT = (cmp_equal || cmp_greater);
            3'b101: OUT = !cmp_greater;
            3'b110: OUT = !cmp_equal && !cmp_greater;
            3'b111: OUT = cmp_greater;
        endcase
    end

### Using Ripple Counters for Low Power

行波计数器属于异步设计，会给时序分析，电路的可靠性带来很多问题。所以一般要避免使用的。不过在一些低速的应用中（比如数码管显示），仍然可以使用行波计数器来降低功耗。

### Bus Inversion

当总线上的当前数据和下一个数据之间的汉明距离大于 N/2 时（N 是总线宽度），就将下一个数据反向再传输。这样做可以降低总线上出现的转换次数，从而降低功耗。

如下图所示：

![bus](/images/low-power-design/bus_trans.png)

<br>

## Transistor Level Power Reduction

寄存器级别的技术基本属于后端 & 微电子科学了，就不再总结了。

<br>

## Ref

[THE ART OF HARDWARE ARCHITECTURE][the art]
