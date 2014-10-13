Title: VHDL 笔记 2 —— 系统设计
Date: 2014-09-16 20:18
Category: FPGA
Tags: FPGA, VHDL, syntax
Slug: vhdl_notes_2_system_design
Author: Chien Gu
Summary: VHDL 笔记，系统设计

总结 `packege`, `component`, `function`, `procedure` 的相关知识。

这些组成部分添加到代码主体部分，目的是为了实现常用代码共享。通常这些代码被放在 `library` 中，我们可以将自己设计的一些常用代码添加到 `library` 中，这有利于使一个复杂设计具有更清晰的结构。

总之，经常使用的代码可以以 `component`, `function`, `procedure` 的形式放到 `package` 中，然后被编译到目标 `library` 中。

<br>

## Packages and Components
* * *

### Package

除了 `component`, `function`, `procedure` 之外，package 中还可以包含 `TYPE`, `CONSTANT` 的定义。

**syntax**

    #!verilog
    PACKAGE package_name IS
        (declarations)
    END package_name;
    
    [PACKAGE BODY package_name IS
        (FUNCTION and PROCEDURE descriptions)
    END package_name; ]
    
可以看到，语法包括两部分，`PACKAGE` 和 `PACKAGE BODY`。

+ `PACKAGE` 是必需的，包括所有的声明语句
    
+ `PACKAGE BODY`：可选，当第一部分包含一个/多个  FUNCTION，PROCEDURE 声明时，这部分必须包含相应的描述代码。

**example**

    #!verilog
    --------- package define-------------
    LIRRARY IEEE;
    USE IDEE.STD_LOGIC_1164.ALL;
    
    PACKAGE my_package IS
        TYPE state IS (st1, st2, st3, st4);
        CONSTANT vec : STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111111";
    END my_package;
    
    --------- main code ------------------
    
    LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE work.my_package.all;   -- declaration
    
    ENTITY ...
    ...
    
    ARCHITECTURE ...
    ...
    
    --------------------------------------
    
### Componet

VHDL 中的 `component` 和 Verilog HDL 中的 `module` 类似：

一个 component 是一段完整的代码（包括 library, entity, architecture 这些组成部分），如果将这些代码声明为一个 component，那么就可以被其他电路调用，从而使代码具有了层次化的结构。

使用 component 必须先声明这个元件，然后再例化这个元件（类似 C++，变量先声明，在定义）。声明和例化都必须在 architecture 中进行。

**declaration syntax**

    #!verilog
    COMPONENT component_name IS
        PORT (
            port_name: signal_mode signal_type;
            port_name: signal_mode signal_type;
            ...);
    END COMPONENT;
    
**instantiation syntax**

    #!verilog
    label: component_name PORT MAP (port_list);

可以看到：

+ 声明时，component 和 entity 相似，必须声明端口的模式和类型

+ 例化时，必须添加一个标号，就像 Verilog HDL 中例化 module 必须给个名字一样

声明元件时，可以有两种方法：

+ 上面的方法，先声明再例化

+ 使用 package 进行声明，将 component 的声明放在 package 中，则可以避免每次元件例化都要重复声明

这两种方法的区别类似于使用 C++ 中的 namespace 时的不同方法

+ 方法一：每次使用 STL 都添加作用域

        std::cout << "hello world!" << std::endl;
    
+ 方法二：声明一次作用域

        using namespace std;
        
### port map

同 Verilog HDL 一样，两种端口映射的方法：位置映射、名字映射。

位置映射书写简单，但是容易出错；名字映射书写繁琐，但是不易出错，端口连接也更清晰，未连接的端口要使用关键词 `open`。

**example**

    #!verilog
    -- positional
    U1: inverter PORT MAP (x, y);
    
    -- nominal
    U1: inverter PORT MAP (x=>a, y=>b);
    
### generic map

generic 功能类似于 Veriog HDL 中的 parameter，所以在例化时 component 时，可以重载参数，使设计更方便灵活。

**syntax**
    
    #!verilog
    label: component_name GENERIC MAP (param.list) PORT MAP (port list);
    
也就是说，在例化时，添加一段 `GENERIC MAP (param.list)` 就可以了。

<br>

## Functions and Procedure
* * *

function 和 procedure 统称为 子程序，它们和 process 相似，内部包含的都是顺序描述的代码，通常使用相同的顺序描述语句。但是，function 和 procedure 的存在主要是为了建库，以达到代码重用和共享的目的，当然它们也可以直接建立在主代码中。

### Function

一个 function 就是一段顺序描述的代码。

在写代码的过程中，我们通常会遇到一些有共性的问题，我们希望实现这些功能的代码可以被共享和重用，从而使代码变得简洁，易于理解，function 的建立和使用就能达到这个目睹。
function 中可以使用 `if`, `case`, `loop` 等语句，但是不能有 `signal` 和 `component`。

function 的使用方法：先创建函数体本身，再调用函数。

**Function Body**

    #!verilog
    FUNCTION function_name [<parameter list>] RETURN data_type IS
        [declarations]
    BEGIN
        (sequential statements)
    END function_name;

其中，<parameter list> 指函数的输入参数：

    <parameter list> = [CONSTANT] constant_name : constant_type;
    <parameter list> = SIGNAL signal_name : signal_type;
    
参数可以是 constant, signal，但是不能是 variable；参数的个数可以是任意个，类型也任意。

**Function Call**

函数可以单独构成表达式，也可以作为表达式的一部分。

    #!verilog
    --example
    x <= conv_integer(a);
    if x > maximum(a, b) ...

**Function Location**

函数可以存放在两个地方：

+ Package 中，这时候，函数声明在 package 中，函数定义在 package body 中

+ Main Code 中，既可以在 entity 中，也可以在 architecture 中

### Procedure

procedure 和 function 类似，目的也相同，不同之处在于 procedure 可以有多个返回值。

与 function 类似，procedure 也需要定义和调用两个过程。

**Procedure Body**

    #!verilog
    PROCEDURE procedure_name [<parameter list>] IS
        [declarations]
    BEGIN
        (sequential statements)
    END procedure_name;

其中，<parameter list> 指出了 procedure 的输入输出参数：

    #!verilog
    <parameter list> = [CONSTANT] constant_name : mode type;
    <parameter list> = SIGNAL signal_name : mode type;
    <parameter list> = VARIABLE variable_name : mode type;
    
参数可以有任意多个，可以是 in, out, inout 模式的 signal, variable, constant。

和 function 一样，procedure 内部的 wait 语句，signal 声明，component 调用都是不可综合的。

**Procedure Call**

procedure 的调用就是它自己。

    #!verilog
    --example
    compute_min_max (in1, in2, in3, out1, out2);
    divide (dividend, divisor, quotient, remainder);
    
**Procedure Location**

procedure 的存放和 function 类似，通常放在 package 中，当然也可以放在主代码中。

### FUNCTION versus PROCEDURE Summary

+ function 有任意个输入参数和一个返回值，输入参数只能是 constant, signal

+ procedure 有任意个输入/输出/双向参数，可以是 signal, variable, constant

+ function 可以作为表达式的一部分，procedure 直接调用

+ function 和 procedure 内部，wait 和 component 都不可综合

+ function 和 procedure 的存放位置相同，经常位于 package 中，也可以在主代码中

<br>

## Reference

[Circuit Design with VHDL](http://www.amazon.com/Circuit-Design-VHDL-Volnei-Pedroni/dp/0262162245)
