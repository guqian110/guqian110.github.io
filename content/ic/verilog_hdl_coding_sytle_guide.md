Title:Verilog HDL coding style
Date: 2015-04-21 10:12
Category: IC
Tags: Verilog,coding style 
Slug: verilog_hdl_coding_style_guide
Author: Qian Gu
Summary: 参考网上的资料和书籍，总结一份自己的 Coding Style Guide

**Update (2015/04/21):**

参考了网上流传的 华为 coding style guide 和 其他的一些资料，还有 [Verilog 编程艺术][book1] 的内容，重新整理一下自己的 Coding Style Guide，以便做项目的时候参考对比。

[book1]: http://www.amazon.cn/EDA%E7%B2%BE%E5%93%81%E6%99%BA%E6%B1%87%E9%A6%86-Verilog%E7%BC%96%E7%A8%8B%E8%89%BA%E6%9C%AF-%E9%AD%8F%E5%AE%B6%E6%98%8E/dp/B00HNVY3SY/ref=sr_1_1?ie=UTF8&qid=1429188978&sr=8-1&keywords=verilog%E7%BC%96%E7%A8%8B%E8%89%BA%E6%9C%AF

<br>

**Version** : 2.0

**Date** : 2015-04-21

**Author** : Qian Gu (guqian110@gmail.com)
    
**Summary** : This is a personal Verilog HDL coding style guide for designs on FPGA.

<br>

## Goal
* * *

干干净净的代码：

**代码整洁、结构合理、层次清晰、注释明了、没有烂代码、没有冗余代码，合理地建立目录，合理地分配到不同文件中。**

<br>

*下面分几个方面来总结，如何达到这样的目的。*

<br>

## Module Partition
* * *

把代码划分为 模块、函数、任务，形成合理的层次结构。

**划分的原则：高内聚、低耦合**

1. 一般来说，每个模块、函数、任务完成一个功能，隐藏内部实现细节，提供一个干净的接口

2. 灵活掌握，不要划分出太多的模块，不必拘泥于 “模块最好在 500 行左右”（太多的实例和连线反而容易出错）

3. 低耦合的原则就是模块之间尽量用少的连线

4. 提取公共代码、常用代码形成模块、函数、任务，便于使用和以后移植，有可能的话，参数化、通用化、IP化（比如 CRC 计算、时钟分频、同步电路、通用 GPIO 控制等）

5. 划分模块时，将相关组合逻辑划分到同一模块，以便综合时进行优化（一般工具不会越过模块边界来优化）

6. 在模块内部，合理切分逻辑，让相关代码组合在一起形成逻辑块，合理安排逻辑块的顺序，并且用固定长度的横线分割这些逻辑块，加以注释

7. 模块内部不要存在重复的代码（子模块、函数、任务、循环语句、寄存器组、for/generate）

8. 为了减少修改内容、避免出错、移植方便、创建可重用模块，在编写代码的时候使用 define、parameter、localparam 定义可重定义的参数（如 SIZE、WIDTH、DEPTH 等）。如果可能，把所有 define 放在一个 definition.vh 中，编译时首先读取这个文件

<br>

## Coding Style
* * *

灵活合理地运用，才能设计出强壮的、简洁的代码，目标是可以清晰地表达出设计意图。

### Part A

1. 设计时把应用文档和设计文档写好，在设计文档中要把设计思路、数据通路、实现细节等描述清楚，在经过评审之后才能开始编写代码（磨刀不误砍柴工，节约时间，而且项目可控、可实现）

2. 尽量使用可靠的 IP

3. 每个模块放到一个单独的文件中，<文件名>=<模块名>.<扩展名>（很多小模块则可以放到一个文件中，便于管理，如 cell 库）

4. Top 模块只包含子模块的例化（即使有逻辑，也是简单的 glue 逻辑）

5. 按照合理的层次结构组织各个模块，存放在合理的目录结构中

### Part B

1. 避免书写可能导致竞争冲突（race condition）的语句（给仿真调试带来很大的麻烦）

2. 避免实例化具体的门级电路（可读性差、难于理解维护、不可移植）

3. 避免使用内部三态电路，使用 MUX 代替

4. 避免任何器件的输入悬空（会导致很大的电流消耗）

5. 避免使用嵌入式的综合指令（synthesis directive）（仿真工具忽略这些指令，仿真和综合结果不一致）

6. 避免 Latch，避免无意中形成的 Latch（常规设计中，只有顶层模块的 clock_gate 会使用 latch，以节省功耗）

### Part C

1. 保证时钟和复位信号没有 glitch

2. 尽量保持时候总和复位信号的简单，不要使用复杂的组合逻辑（便于测试、后端生成时钟树和复位树）

3. 尽量做到所有寄存器同时复位

4. 小心使用门控时钟（Gated clock）

5. 避免在模块内部产生时钟，最好使用同步设计，用 clock enable 来实现低频时钟操作

6. 避免在模块内部产生复位

7. 如果确实要使用门控时钟、内部时钟、内部复位，把这些信号的代码放到一个独立的模块里，并在顶层模块例化这个独立模块

8. 一个模块内尽量只使用一个时钟。多时钟设计中，时钟域隔离带逻辑（同步电路）放到一个独立的模块中
只使用时钟的一个沿（上升 or 下降）

9. 对跨时钟域的信号要进行同步处理

10. 避免多周期路径（multicycle_path）和假路径（false_path），一旦有这种路径，在代码和设计文档中标注写明
写可测性的设计（DFT, Design for Test）

### Part D

1. 对于组合逻辑，使用 always @*

2. 注意 "=" 和 "<="

    不要在一个 always 块中混杂使用两者

    组合逻辑，使用 "="

    时序逻辑，使用 "<="

3. 编写合理的 FSM

4. 无优先级的多路复用器使用 case，有优先级的多路复用器使用 if-else 或者是 ? :

    通常，case 的时序比 if-else 的时序好，优先级编码器只有在信号先后到来的时候才使用。

### Part E

1. 模块的输入信号尽量用 DFF 先锁存再使用（若输入是其他的寄存器输出则不必）

2. 模块的输出信号尽量用 DFF 先锁存再输出（便于综合和 STA，处理起来简单，Timing 更好）

3. 使用端口名映射法进行模块实例化

4. 声明每一个用到的信号（若无声明，默认是 1 bit 的 wire）

5. 设计代码中，reg 只能在一个 always 中复制；验证代码无此要求

6. 设计代码中，函数、任务不要使用全局变量；验证代码无此要求

### Part F

1. `include 的文件名不要包含路径名（后期编译、综合、移植困难）

2. 常用 `define 做常数声明，把 `define 定义的参数放在一个独立的文件中，然后在模块头部 `include 这个文件。

3. 头文件保护

4. 只有全局的，不会被修改的常量采用 define 定义

5. 作用域只在一个模块内，使用 localparam 代替 `define

6. 为了模块可配置、可移植，使用 parameter

### Part G

1. 使用简洁的写法（可省略的 begin-end 省略不写）

    我看到有一些 coding style 中要求即使只有一条语句，if-else、case 等语句的 begin-end 也要写上，这样是为了方便以后添加代码，而且减少出错的机会。

    不过我更认同 Cummings 的观点：[The Sunburst Design - "Where's Waldo" Principle of Verilog Coding][page1]

    > I am a big fan of very concise coding. In general (but not always), the shorter the code,
the better. The more code I can see, nicely spaced and formatted on one page, the easier
it is to understand the intent of the design or verification code.
    > 
    > I call this the "Where's Waldo" Principle based on the child puzzle-books of the same
name. Even though Waldo is dressed in a bright red and white stripped shirt, when he is
surrounded by enough additional clutter, he is hard to find. Just as Waldo is hard to find
when surrounded by clutter, simple RTL coding bugs can be obscured when surrounded
by poorly spaced and formatted RTL code and silly comments that state the obvious.

    比如下面这段 11 行、129 个字符的代码可以使用 3 行、57 个字符的代码代替：


        #!verilog
        // code1
        always @(posedge clk or negedge rst_n)
        begin
            if (!rst_n)
                begin
                    q <= 0;
                end // end-if-begin
            else
                begin
                    q <= d;
            end // end-else-begin
        end // end-always-begin

        // code2
        always @(posedge clk or negedge rst_n)
            if (!rst_n) q <= 0;
            else q <= d;

[page1]: http://www.sunburst-design.com/papers/Wheres_Waldo_Coding.pdf

<br>

## Naming
* * *

1. 建立一套命名约定和缩略语清单，以文档的形式记录下来，严格遵守

2. 使用有意义而且有效的名字，含义清楚、名副其实，避免含糊误导

3. 模块名大写，所在文件名小写

3. 函数、任务、信号、变量、端口名字用小写字母

4. `define、parameter、localparam、const、enum 用大写字母

5. 子模块的名字应该使用调用模块的名字作为前缀，如 emi、emi_ahb、emi_reg、emi_sram

6. 使用协议定义的标准名字，根据需要在这些名字前附加前缀（模块名）

7. 同一信号的名字在各个子模块中保持一致

8. 进入到同一个模块的连线用模块的名字作前缀（前缀比后缀更清晰）

9. 每行定义一个信号，上面一行/同一行的尾部加上简短注释

10. 信号名的定义顺序：控制信号、相应信号、数据信号

11. **模块名**

    单词首字母缩写，大写。举例
    
        #!verilog
        DMI     // Data Memory Interface
        DEC     // Decoder

12. **模块间信号名**

    分为两部分，第一部分表示信号方向，大写，第二部分表示信号意义，小写，下划线连接。举例
    
        #!verilog
        wire CPUMMU_wr_req;     // write request form CPU to MMU

13. **模块内命名**

    单词缩写，下划线连接，小写。举例
    
        #!verilog
        wire sdram_wr_en;       // SDRAM write enable

14. **系统级命名**

    时钟信号、置位信号、复位信号等需要输送到各个模块的全局信号，以 `SYS_` 前缀开头。举例
    
        #!verilog
        wire SYS_clk_100MHz;         // system clock
        wire SYS_set_cnt;            // system counter set
        wire SYS_rst_cnt;            // system counter reset
    
15. **低电平有效信号命名**

    低电平有效信号加后缀 `_n`，举例
    
        #!verilog
        wire rst_n;             // low valid reset

16. **经过锁存器的信号**

    经过锁存器的信号加后缀 `_r`，以和锁存前区别。举例
    
        #!verilog
        reg din_r;              // latch input data

17. **参数名**

    parameter 全部大写，用 parameter 定义有实际意义的常数，比如 LED 亮灯状态、状态机状态等，避免 "magic number"。举例：
    
        #!verilog
        parameter   IDLE = 10'd0,
                    WAIT = 10'd1;
        
**常用信号名缩写：**

|name|short||name|short||name|short|
|----|-----||----|-----||----|-----|
|acknowledge  |ack||error|err||ready|rdy|
|adress|addr||enable|en||receive|rx|
|arbiter|arb||frame|frm||request|req|
|check|chk||generate|gen||resest|rst|
|clock|clk||grant|gnt||segment|seg|
|config|cfg||increase|inc||source|src|
|control|ctrl||input|in||statistic|stat|
|counter|cnt||length|len||switcher|sf|
|data in|din||output|out||timer|tmr|
|data out|dout||packet|pkt||tmporary|tmp|
|decode|de||priority|pri||transmit|tx|
|decrease|dec||pointer|ptr||valid|vld|
|delay|dly||read|rd||write enable  |wr_en|
|disable|dis||read enbale  |rd_en||write|wr|

<br>

## Format
* * *

### Poart Declaration

1. 尽量使用 Verilog-2001 标准，减少代码行，便于修改和删除

2. 每行只声明一个端口，这样可以在上面/后面添加简短注释

3. 声明顺序：按照功能分组，分组前添加注释，分组之间空行分割，便于阅读

4. 在功能分组内，哪个信号最主控，哪个就最靠前。（控制信号、数据信号），顺序如下：

    1. test_mode 信号，工作模式（=0）或 测试模式（=1）

    2. 异步复位

    3. 时钟信号

    4. 使能信号

    5. 控制信号

    6. 地址信号

    7. 响应信号

    8. 数据信号

### Module Instantiate

1. 例化名和模块名保持一致，加统一的前缀，如 u1_<module_name>、u2_<module_name>

2. 端口名映射法，not 位置映射法

3. 例化端口顺序 = 模块端口声明顺序，不用的端口也列出来

4. 例化*大模块*时，每个端口占用一行，`.port_name` 对齐，`.(signal_name)` 也对齐

5. 例化*大量小模块*时，可以多个端口放在同一行的紧凑形式（如大量 PAD 实例化）

### Task & Function

使用 C 语言的习惯，在合适的位置添加空格

### Statement

1. 每个语句单独成行

2. 对于 always、for、while 语句，begin 最好在它们的下一行

3. 对于 initial、if、elseif、else 语句，begin 最好与它们同行

4. end 占用单独一行

5. 一个逻辑块内不加空行，表明它们之间的紧密关系

6. 不同逻辑块之间添加空行，表明每个逻辑块实现不同的功能

7。 每行不多于 80 个字符，以提高可读性

8. 采用缩进，不要嵌套太深

9. 合理使用 tab （1 tab = 4 space）

### Expression

1. 使用括号表示优先级（括号有可能影响综合结果的情况不在此列）

2. 双目、三目操作符左右空格，如 =、+、-、×、/、%、<<、>>、&、&&、|| 等

3. 逗号(,) 只在逗号后加空格

4. 分号(;) 只在分号后加空格

5. 行尾不加空格

6. 上下行有关时，使用空格对齐

7. 表达式很长时，适当位置断行，使用空格对齐某些变量

### Comments

1. 文件头，使用 doxverilog 注释

2. 在逻辑块、重要代码行的上方添加注释

3. 注释简明扼要，足够说明设计意图

4. 保证注释和代码一致

5. 有效实用的注释格式，Doxygen

6. 英文注释，标点后空一格，英文习惯

7. 解释复杂过程，列出要点和步骤

8. 模块开始要有模块级的注释

9. 模块端口，简要注释，描述功能和有效电平

10. 特殊注释：note、warning、todo

### Lint

1. 编译时，打开 vcs 或 ncveriog 的 lint 检查

2. 检查编译的输出结果，Warning 可能导致仿真失败、综合失败，尽量修正

3. 检查是否生成 latch

4. 检测 always 敏感列表是否完全

<br>

## Appdidx
* * *

FSM 的模板[另外一篇博客][blog1]中已经总结过了。下面是一个简单的模块模板格式。

[blog1]: http://guqian110.github.io/pages/2014/06/05/fsm_design.html

    #!verilog
    ///////////////////////////////////////////////////////////////////////////////////
    // Module Declaration                                                            //
    ///////////////////////////////////////////////////////////////////////////////////
    module MODULE_NAME #(parameter  PARAM1 = xxx, PARAM2 = xxx)
        (
         //----------------------------------
         // Interface1
         port_1,    // comments
         port_2,
         ... 
         //----------------------------------
         // Interface2
         port_n
        );
        
    ///////////////////////////////////////////////////////////////////////////////////
    // Parameter Declarations                                                        //
    ///////////////////////////////////////////////////////////////////////////////////
        localparam  DIN     = 16, 
                    DOUTA   = 16,
                    DOUTE   = 16,
                    DOUTCTR = 16;
    
    ///////////////////////////////////////////////////////////////////////////////////
    // Main Body of Code                                                             //
    ///////////////////////////////////////////////////////////////////////////////////
    
        ///////////////////////////////////////////////////////////
        // Instantiate sub module                                //
        ///////////////////////////////////////////////////////////
        MODULE_NAMW_A U_MODULE_NAMW_A (
            .A(A)
            .B(B)
            ...
            );
    

        ///////////////////////////////////////////////////////////
        // Some Logic                                            //
        ///////////////////////////////////////////////////////////

        //----------------------------------------
        // sequential logic
        always @(posdge clk) begin
            if (rst) begin
                // reset
                ...
            end
            else begin
                // do something
                ...
            end
        end
        
        //---------------------------------------
        // combinational logic
        assign wire_1 = wire_2;
        ...
        
    endmodule
