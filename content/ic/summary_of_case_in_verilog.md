Title: Verilog 的 case 小结
Date: 2015-04-15 15:50
Category: IC
Tags: case
Slug: summary_of_case_in_verilog
Author: Qian Gu
Summary: 总结 case 的用法和需要注意的细节

学习了 Cummings 大神 的 paper：["full_case parallel_case", the Evil Twins of Verilog Synthesis][paper1] 和 [Verilog 编程艺术][book1]

总结一下笔记。

[paper1]: http://www.sunburst-design.com/papers/CummingsSNUG1999Boston_FullParallelCase.pdf
[book1]: http://www.phei.com.cn/module/goods/wssd_content.jsp?bookid=38848

## Def
* * *

### Syntax:

    case (case_expression)
     case_item1 : case_item_statement1;
     case_item2 : case_item_statement2;
     case_item3 : case_item_statement3;
     case_item4 : case_item_statement4;
     default : case_item_statement5;
    endcase

等价于

    if (case_expression === case_item1) case_item_statement1;
    else if (case_expression === case_item2) case_item_statement2;
    else if (case_expression === case_item3) case_item_statement3;
    else if (case_expression === case_item4) case_item_statement4;
    else                                     case_item_statement5;

首先说明一些基本名词的定义：

### Case statement header

header 由 关键字 `case`/`casex`/`casez` + case expression 两部分组成，它们通常写在同一行（上面语法的第一行）。添加 "parallel_case" 或者 "full_case" 综合指令的方法就是把指令当作注释写在 header 的那一行，后续 case item 之前。

### Case expression

`case` 关键字之后，括号中间的内容。它可以是一个常量（如 '1'），也可以是一个表达式，或者更常见的一个 1 bit / n bits 的向量，用来和后面的 case item 做比较。

### Case item

可以是单比特、向量、表达式，用来和 case expression 做比较。和高级编程语言（C 语言）不同的是，verilog 中的 case 自带隐含的 `break` 语句，所以就不用再费心多写代码了。

### Case item statement

case item 内的语句，多于 1 句时，要用 `begin-end`。

### Case default

默认分支，虽然这个分支不是强制要求的，但是在所有分支后面加上 default 分支是一个良好的编程习惯。

### Casez

case 语句的变种，casez 把 expression 或者是 item 中的 "z"/"?" 忽略，当作不关心的值。

> **Guideline:** Exercise caution when coding synthesizable models using the Verilog casez statement
> 
> **Coding Style Guideline:** When coding a case statement with "don't cares," use a casez statement
and use "?" characters instead of "z" characters in the case items to indicate "don't care" bits.

### casex

类似于 casez，不关心的值为 "z" / "?" / "x"。

> **Guideline:** Do not use casex for synthesizable code

### Process

case 的执行过程：

1. 计算 case expression，只计算一次，然后按照代码顺序从上向下和 case item 逐个比较

2. 比较过程中，如果有 default 分支，则暂时先忽略

3. 如果有某个 item 和 expression 匹配，则执行此 item 下的语句

4. 如果匹配失败，有 default 分支，则执行该 default 分支

5. 如果匹配失败，没有 default 分支，则终止

这个按照顺序比较的过程就是可能导致 priority encoder 的原因。

### reverse case

reverse case 是 case 的一个变形，也叫做 `case if true`。这种风格中 case expression 是一个常量，而 case items 是由变量构成的表达式。这种风格通常用在 One-hot FSM 中，并且采用 parallel 方式。

见另外一篇博客：[有限状态机设计][blog1]

[blog1]: http://guqian110.github.io/pages/2014/06/05/fsm_design.html

<br>

下面讨论 full_case 和 parallel_case 的相关问题。很多人都会使用这两个综合指令，他们的理由是：

> + "full_case parallel_case" makes my designs smaller and faster.
>
> + "full_case" removes latches from my designs.
> 
> + "parallel_case" removes large, slow priority encoders from my designs.

然而这些理由都不够准确或者说是危险的，因为这两个综合指令有时候完全不影响设计，有时候反而会使设计速度变慢、面积变大，有时候甚至会改变设计的功能。**通常，这些指令都很危险。** 所以，Cummings 给他的 paper 起了如下的别名...

> An alternate title for this paper could be: "How to add $200,000 to the cost and 3-6 months to the schedule of your ASIC design without trying!"

<br>

## "full" case statement
* * *

"full" 的意思就是 expression 的任何取值都有一个 item/default 分支与其对应，否者就不是 "full case"。

**example1: Non-"full" case**

    #!verilog
    module mux3a (y, a, b, c, d, sel);
        output y;
        input [1:0] sel;
        input a, b, c;
        reg y;
 
        always @* begin
            case (sel)
                2'b00: y = a;
                2'b01: y = b;
                2'b10: y = c;
            endcase
        end
    
    endmodule

在这个例子中，当 sel 的取值是 2'b11 时，由于没有定义输出值 y 为多少，仿真器会保持之前的取值，综合器会综合出一个 latch。

（基于 Virtex-4 器件，XST 的 synthesis report 给出的结果是 1 bit latch + 1 bit 3-to-1 multiplexers）

### HDL full case

从 HDL 仿真器的角度看，full case 语句就是 case item 包含了 expression 可以取的任何值。

### Synthesis full case

从综合工具的角度看，full case 语句就是 expression 的每种可能的取值组合都被包含在 item 中。

虽然 Verilog 语法不要求 case 语句必须是 HDL full 或者 synthesis full ，但是我们可以通过手动添加一个 default 分支来使得 case 变为 full。

**example2: "full" case**

    #!verilog
    module mux3a (y, a, b, c, d, sel);
        output y;
        input [1:0] sel;
        input a, b, c;
        reg y;
 
        always @* begin
            case (sel)
                2'b00: y = a;
                2'b01: y = b;
                2'b10: y = c;
                default: y = 1'bx;
            endcase
    
    endmodule

在这个例子中，因为有了 default 分支，所以它是一个 full case。在仿真时，如果 sel 是 2'b11，那么 y 取值为 x（不确定，unknown），而综合器会把 x 当作 “不关心”（don't care，有可能为 1，也有可能为 0）。这就导致了仿真和综合不一致。解决这个问题的方法就是给 y 赋值一个常数 or 像其他 item 一样赋值一个输入。

（基于 Virtex-4 器件，XST 的 synthesis report 给出的结果是 1 bit 3-to-1 multiplexers）

P.S. 我们可以利用前后仿真不同这一点来帮助我们调试。在设计 FSM 时，default 分支处，next_state 赋值为 x，这样如果存在错误转换，next_state 就会保持为 x，在波形上很方便看到。

还有一种方法是在所有的 item 之前，给输出赋一个默认值，这样即使不是 full，也不会产生 latch：

    #!verilog
    always @(a or b or c or sel)
        y = 1'b0;
        case (sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
        endcase

### XST full case

综合指令是一些特殊的可以被综合工具识别，并指导综合工具工作的语句。不同的综合工具的综合指令语法不相同。我用的是 ISE 自带的 XST。查看 XST User Guide 就可以找到 full case 的相关指令：

这个指令与架构（Architecture）无关、只适用于 verilog 的 case 语句：

+ 只对 Verilog 有效

+ 标识所有的取值都被包含在 item 中

+ 阻止 XST 对那些没有被包含的情况生成额外的电路

使用这个指令的方法有很多：

1. **Verilog Syntax**

        (* full_case *)

    在 case header 的上面一行

    or

        // synthesis full_case

    这种方式，注释必须在 case header 的同一行

    example3:

        (* full_case *)
        casex select
            4’b1xxx: res = data1;
            4’bx1xx: res = data2;
            4’bxx1x: res = data3;
            4’bxxx1: res = data4;
        endcase

    example4:

        casex select // synthesis full_case
            4’b1xxx: res = data1;
            4’bx1xx: res = data2;
            4’bxx1x: res = data3;
            4’bxxx1: res = data4;
        endcase

2. XST Command Line

        xst run -vlgcase [full|parallel|full-parallel]

3. ISE Design Suit

    Process > Process Properties > Synthesis Options > Full Case.

在 XST User Guide 中：

> XST automatically determines the characteristics of the case statements and generates
logic using multiplexers, priority encoders, and latches that best implement the exact
behavior of the case statement.

也就是说，如果我们不添加综合指令，XST 会根据代码自动判断，选择 MUX、priority encoder、latch 来生成最合适的实现电路。

1. 如果生成 MUX，那么 synthesis report 在 Macro Recognition 步骤中会给出 MUX  macro 的内容

    注意，XST 是否会把 case 推译成 MUX，还取决于器件。对于 LUT4-based 器件，如果输入端口是 4 个，输出是 1 个，那么就会推译出 MUX；对于 LUT6-based 的器件，如 Virtex-5，那么需要输入端口是 8 个以上。

2. 如果生成 Latch，那么 synthesis report 会给出 warning（只要生成 latch，不管是设计有意还是设计失误无意产生的，都会给出 warning，毕竟 latch 是很容易导致错误的）

如上面的例子，如果改成

    always @* begin;
        (* full_case *)
        case (sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
        endcase
    end

或者是

    always @* begin
        case (sel)  // synthesis full_case
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
        endcase
    end

那么就只会生成 1 bit 3-to-1 multiplexers，不会有多余的 latch。

虽然这些指令有好处，但是一定要谨慎使用，而且使用时需要注意：

1. 这些综合指令只对综合工具有用，仿真工具会自动忽略这些指令，所以有可能造成前后仿真不一致的问题

2. 有时候使用指令，会适得其反，导致结果面积变大、速度变慢

3. 一般有迷信的说法：“使用 full case 指令，可以消除 latch。” 这个说法太绝对了，事实上并不总是这样。如果有多个输出需要赋值，而有些分支只忽略了一些赋值，那么即使使用 full_case 指令，也不能避免 latch 的产生。

    举例，在下面的例子中，仍然会产生 latch

        always @* begin
            casez (sel) // synthesis full_case
                3'b100: y1 = 3'b100;
                3'b010: y1 = 3'b010;
                3'b001: y2 = 3'b001;
            endcase
        end

    我们使用 full case 指令的目的就是为了避免生成意外的 latch，但是这种方法有以上的各种弊端。其实还有一种更加简单的方法来避免 latch，就是前面说的，**在 case 前，给所有的输出赋一个默认值。**

<br>

## "parallel" case statement
* * *

"parallel" 的意思就是 expression 的取值每次有且只有一个 item 与其对应，否则就不是 "parallel" case，而匹配的 items 称为 "overlapping" case items。

### Non-parallel case statements

    always @sel begin
        casez (sel)
            3'b1??: y = 3'b100;
            3'b?1?: y = 3'b010;
            3'b??1: y = 3'b001;
        endcase
    end

当输入是 3'b011, 3'b101, 3'b110, 3'b111 时，会有多个 item 与 expression 对应，所以不是 parallel 的，会综合出一个 priority encoder。

### Parallel case statements

对上面的例子稍微修改一下，就得到了 parallel case：

    always @sel begin
        casez (sel)
            3'b1??: y1 = 1'b1;
            3'b01?: y2 = 1'b1;
            3'b001: y3 = 1'b1;
        endcase
    end

### XST parallel case

语法同 full case，只需要将 full_case 替换为 parallel_case 即可。如果 case 本来就是 parallel 的，那么这个指令就完全不起作用，只是一些额外的代码。

不要故意使用 Non-parallel case 来推译 priority encoder，这是不好的编程习惯。如果我们的目的就是要生成 priority encoder，应该使用级联的 if-else 语句，这样更能表达意图。

下面的这些 guideline 可以帮助我们避免 case 生成 priority encoder，从而避免前后仿真不一致：

> **Guideline:** Code all intentional priority encoders using if-else-if statements. It is easier for a typical design engineer to recognize a priority encoder when it is coded as an if-else-if statement.
> 
> **Guideline:** Case statements can be used to create tabular coded parallel logic. Coding with case statements is recommended when a truth-table-like structure makes the Verilog code more concise and readable.
> 
> **Guideline:** Examine all synthesis tool case-statement reports 
>
> **Guideline:** Change the case statement code, as outlined in the above coding guidelines, whenever the synthesis tool reports that the case statement is not parallel (whenever the synthesis tool reports "no" for "parallel_case")

<br>

## Synthesis coding styles
* * *

在总结了 full_parallel_case 之后，Cummings 大神给出了建议：

> Sunburst Design Assumption: it is generally a bad coding practice to give the synthesis tool
different information about the functionality of a design than is given to the simulator.
> 
> Guideline: In general, do not use "full_case parallel_case" directives with any Verilog case
statements.
> 
> Guideline: There are exceptions to the above guideline but you better know what you're doing if
you plan to add "full_case parallel_case" directives to your Verilog code.
> 
> Guideline: Educate (or fire) any employee or consultant that routinely adds "full_case
parallel_case" to all case statements in their Verilog code, especially if the project involves the
design of medical diagnostic equipment, medical implants, or detonation logic for thermonuclear
devices!
> 
> Guideline: only use full_case parallel_case to optimize onehot FSM designs.

甚至建议要开除写 full_parallel_case 的员工...

<br>

## Summary
* * *

总结一下所有的 guidelines：

> **Guideline:** Exercise caution when coding synthesizable models using the Verilog casez statement
> 
> **Guideline:** Do not use casex for synthesizable code
> 
> **Guideline:** In general, do not use "full_case parallel_case" directives with any Verilog case
> statements.
> 
> **Guideline:** There are exceptions to the above guideline but you better know what you're doing if you plan to add "full_case parallel_case" directives to your Verilog code.
> 
> **Guideline:** Code all intentional priority encoders using if-else-if statements. It is easier for a typical design engineer to recognize a priority encoder when it is coded as an if-else-if statement.
> 
> **Guideline:** Coding with case statements is recommended when a truth-table-like structure makes the Verilog code more concise and readable.
> 
> **Guideline:** Examine all synthesis tool case-statement reports.
> 
> **Guideline:** Change the case statement code, as outlined in the above coding guidelines, whenever the synthesis tool reports that the case statement is not parallel (whenever the synthesis tool reports "no" for "parallel_case").
> 
> **Guideline:** only use full_case parallel_case to optimize onehot FSM designs.
> 
> **Coding Style Guideline:** When coding a case statement with "don't cares," use a casez statement and use "?" characters instead of "z" characters in the case items to indicate "don't care" bits.
> 
> **Guideline:** Educate (or fire) any employee or consultant that routinely adds "full_case parallel_case" to all case statements in their Verilog code.
> 
> **Conclusion:** "full_case" and "parallel_case" directives are most dangerous when they work! It is better to code a full and parallel case statement than it is to use directives to make up for poor coding practices.

<br>

## Ref

["full_case parallel_case", the Evil Twins of Verilog Synthesis][paper1]

[Verilog 编程艺术][book1]
