Title: VHDL 笔记 1 —— 电路设计
Date: 2014-09-16 14:56
Category: FPGA
Tags: FPGA, VHDL, syntax
Slug: vhdl_notes_1_circuit_design
Author: Chien Gu
Summary: VHDL 笔记, 电路设计

## Code Structure
* * *

+ 一段独立的 VHDL 代码一般至少由 3 部分组成：`LIBRARY declarations`、`ENTITY`、`ARCHITECTURE`

+ Library 用来设计重用和代码共享，使代码结构更清晰

        #!VHDL
        LIBRARY library_name;
        USE library_name.package_name.package_parts;
    
    + 常用的 3 个 Library：`ieee`、`std`、`work`
    
    + 其中 std 和 work 是默认可见的，不需声明，ieee 需要明确的声明

+ Entity 描述电路的输入/输出引脚

        #!VHDL
        ENTITY entity_name IS
            PORT (
                port_name: signal_mode signal_type;
                port_name: signal_mode signal_type;
                ...);
        END entity_name;

    + singal_mode 可以是 4 种类型： `in` `out` `inout` `buffer`
    
    + `OUT` 模式无法回读到电路内部，`Buffer` 模式可以，但是 buffer 不能连接到其他类型的端口，即不能把该模块作为子模块例化，一般使用中间缓冲信号，解决回读问题。

+ Architecture 描述电路的行为和实现的功能

    + Architecture 包含两部分：声明部分和代码部分
    
    + 声明部分（可选）用来声明信号、常量等
    
    + 代码部分（begin ... end）描述电路行为

+ 注释行用 `--` 开始

+ VHDL 不区分大小写

<br>

## Data Types
* * *

前面的 Entity 中的端口定义：

    #!VHDL
    port_name: signal_mode signal_type;
    
还有其它地方声明的信号 `signal` :

    #!VHDL
    signal name : type [range] [:= initial_value];

还有 常量 `constant` 声明：

    #!VHDL
    constant name : type := value;

还有 变量 `variable` 声明：

    #!VHDL
    variable name : type [range] [:= initial_value];

这些声明中都包含了数据类型字段。一个信号/常量/变量的数据类型决定了它能取到什么样的值，还有可以进行什么样的操作。

### Pre-defined Data Types

IEEE 1164 标准中包含了一些预先定义的数据类型。

+ `std` 库中的 `standard` 包集(package) 定义了：`bit`、`boolean`、`integer`、`real` 类型

+ `ieee` 库中的 `std_logic_1164` 包集定义了：`std_logic`、`std_ulogic` 类型

+ `ieee` 库中的 `std_logic_arith` 包集定义了：`signed`、`unsigned` 类型，还有一些数据类型转换函数

+ `ieee` 库中的 `std_logic_signed` 和 `std_logic_unsigned` 包集：包含一些函数，可以使 `std_logic_vector` 类型的数据可以像 `signed` 和 `unsigned` 一样进行运算

#### `bit` & `bit_vector`

+ 用 '0' 和 '1' 赋值

        #!VHDL
        signal x : bit;
        signal y : bit_vector (3 downto 0);

        x <= '1';
        y <= "0011"

#### `std_logic` & `std_logic_vector`

+ `ieee 1164` 标准中引入的 8 逻辑值系统

+ 不同于 bit 类型，可以取 8 种不同的值，但只有 `0`、`1`、`Z` 是可综合的，其他 5 种用来仿真

#### `std_ulogic` & `std_ulogic_vector`

+ `ieee 1164` 标准中定义的具有 9 种逻辑值的数据类型

+ `std_logic` 是 `std_ulogic` 的子集

#### `boolean`

+ 只有两种取值：`true`、`false`

#### `integer`

+ 32 位的整数 (-2 147 483 647 ~ +2 147 483 647)

#### `natural`

+ 非负整数 (0 ~ +2 147483 647)

#### `real`

+ 实数，不可综合

#### `physical literal`

+ 表示物理量，不可综合

#### `character`

+ 单一/一串 ASCII 字符

#### `signed` & `unsigned`

+ `ieee` 库中的 `std_logic_arith` 包中定义的数据类型

+ 和 `std_logic_vector` 类似，但是可以支持与整数类似的算术运算。

### User-defined Data Types

    #!VHDL
    -- integer
    TYPE student_grade IS RANGE 0 TO 100;
    
    -- enumerated
    TYPE state IS (idle, forward, backward, stop);
    TYPE color IS (red, green, blue, white);
    
### Subtypes

    #!VHDL
    SUBTYPE my_color IS color RANGE red TO blue;
    -- my_color = (red, green, blue);
    
### Arrays

+ 可以认为 VHDL 预定义的数据类型只有 `scalar`(single bit) 和 `vector`(one-dimensional array of bits) 两种类型。

+ 这两种类型中只有一下类型是可综合的：

    + scalars: bit, std_logic, std_ulogic, boolean

    + vectors: bit_vector, std_logic_vector, std_ulogic_vector, integer, signed, unsigned

+ syntax:

        #!VHDL
         TYPE type_name IS ARRAY (specification) OF data_type;

+ example:

        #!VHDL
        --1D array
        TYPE matrix IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
        --2D array
        TYPE matrix2D IS ARRAY (0 TO 3, 7 DOWNTO 0) OF STD_LOGIC;
        
### Port Array

有时在定义端口时，需要把端口定义为矢量阵列。但是在 `Entity` 中不允许使用 `type` 定义，所以我们必须自己定义包集 (package)，然后使用 `use` 声明使用该用户自定义的包集，最后才能在 Entity 中使用这种新定义的类型。

### Signed and Unsigned Data Types

+ `ieee` 库中的 `std_logic_arith` 包中定义了有符号数 (`signed`) 和无符号数 (`unsigned`) 两种数据类型。

+ 只有先声明使用这个库下的包，才能在代码中使用 signed/unsigned

        #!VHDL
        use ieee.std_logic_arith.all;
        
        signal x signed (7 downto 0);
        signal y unsigned (0 to 3);
    
+ 使用它们主要是为了进行算术运算，但是它们不支持逻辑运算。( std_logic_vector 不支持算术运算，但是支持逻辑运算)

+ 如果信号的类型只能是 std_logic_vector，那么通过其他方法也是可以进行算术运算的，解决方案就是声明使用 `ieee` 的 `std_logic_unsigned` 和 `std_logic_signed` 两个包集，声明之后，std_logic_vector 就可以像 signed/unsigned 一样进行算术运算了。

        #!VHDL
        use ieee.std_logic_signed.all;
        -- use ieee.std_logic_unsigned.all;
        
        signal a in std_logic_vector (7 downto 0);
        signal b in std_logic_vector (7 downto 0);
        signal x out std_logic_vector (7 downto 0);
        
        x <= a + b;     --legal, arithmetic
        x <= a and b;   --legal, logiccal
        
    + 需要注意的是，这两个包不能同时存在于同一份代码中，因为这样会引入二义性。比如上面例子中的 “+” 运算，如果我们同时包含了这两个包集，那么编译器不知道我们定义的运算到底应该重载哪一个，综合时会报错。
        
### Data Conversion

+ 在 VHDL 中，不同类型的数据是不能直接进行算术/逻辑运算的，所以必要时必须进行类型转换操作。

+ 有两种方法实现类型转换：

    + 使用包中预定义的数据类型转换函数
    
    + 手动写一段专门用于数据类型转换的代码

+ `std_logic_arith` 中包含了很多数据类型转换函数，可以实现不同数据之间的转换。

<br>

## Operators and Attributes
* * *

VHDL 语法虽然枯燥无味，但是只有对数据类型、运算操作符及其属性有了深刻认识，才能写出高质量和高效率的代码。

### Opreators

+ VHDL 提供了 6 种预定义的预算符：
    
    + 赋值 assignment
    
    + 逻辑 logical
    
    + 算术 arithmetic
    
    + 关系 relational
    
    + 移位 shift
    
    + 并置 concatenation

#### `assignment`

一共 3 种：

+  `<=` 用于给 `signal` 对象赋值

+  `:=` 用于给 `variable`, `constant`, `generic` 赋值，还可用于赋初值

+  `=>` 用于给矢量(vector)对象的某些位赋值，常和 `others` 一起使用

#### `logical`

进行逻辑运算，操作数必须是 `bit`, `std_logic`, `std_ulogic` 类型或者它们的扩展，即`bit_vector`, `std_logic_vector`, `std_ulogic` 类型。

+ `NOT`, `AND`, `OR`, `NAND`, `NOR`, `XOR`

#### `arithmetic`

+ 操作数是 `signed`, `unsigned`, `integer`, `real`，其中 `real` 类型是不可综合的

+ 如果声明了 `std_logic_signed` 或者 `std_logic_unsigned`，则 `std_logic_vector` 类型也可以进行加减运算。
+ `+`, `-`, `*`, `/`, `**`, `MOD`, `REM`, `ABS`

#### `comparison`

一共有 6 种：`=`, `/=`, `>`, `<`, `>=`, `<=`

#### `shift`

VHDL93 中引入的操作，语法：

    #!VHDL
    <left operand><shift operator><right operand>;
    
+ left operand 必须是 `bit_vector` 类型

+ right operand 必须是 `integer` 类型

+ shift operator 有：`sll`, `srl`, `sla`, `sra`, `rol`, `ror`

#### `concatenation`

用于位的拼接。

+ 操作数：任何支持逻辑运算的数据类型

+ 操作符：`&`, `(, , ,)`

### Attributes

VHDL 中的属性语句可以获得相关数据/对象 的信息，使代码更加灵活。

#### Pre-defined

内置的预定义属性可以分为两大类：数值类属性 和 信号类属性。

+ **data attributes**

+ **signal attributes**

    大多数信号类属性都是不可综合的，只有 `s'event` 和 `s'stable` 是可综合的。

#### User-defined

也可以用户自己定义一个新的属性，并描述某个对象的这个属性的值是多少，之后就可以使用这个属性了。

**syntax**

    #!VHDL
    ATTRIBUTE attribute_name: attribute_type;  -- declaration
    ATTIRBUTE attribute_name OF target_name: class IS value;  -- specification

example：

    #!VHDL
    ATTRIBUTE number_of_inputs: INTEGER;
    ATTRIBUTE number_of_inputs OF nand3: SIGNAL IS 3;
    
    input <= nand3'number_of_inputs;
    
首先定义了一个新的属性，名字叫 `number_of_inputs`，表示输入端口的个数，然后针对对象 nand3 (3输入的与非门) 这个对象，描述它的这个属性的类型为 signal 类型，取值为 3；最后，使用这个属性，将 nand3 的这个属性的值赋值给 input 对象。

### Operator Overloading

用户不仅可以自定义属性，还可以自定义操作符。预定义的操作符的操作数必须是特定的类型，对于某些类型，我们可以自定义操作符对应的操作。

VHDL 中的自定义操作符作用和 C++ 中的操作符重载 方法、目的都很类似。首先构造一个函数，然后调用这个函数即可。

### GENERIC

`generic` 必须在 ENTITY 中声明，它可以指定常规参数，所指定的参数是**静态的**，**全局的**。感觉类似于 Verilog 中的 `define` 吧，但是显然 Verilog 中的 `parameter` 是更好的设计，因为全局变量/常量很不安全。

**syntax**

    #!VHDL
    GENERIC (parameter_name: parameter_type := parameter_value);
    
**example**

    #!VHDL
    ENTITY my_entity IS
        GENERIC (n: INTEGER := 8);
        PORT (...);
    END my_entity;
    
<br>

## Concurrent Code
* * *

从本质上讲，HDL 是 描述 (Description) 语言，对应的是硬件电路，而硬件电路是时刻工作的，所以，它的代码是并发执行的。只有 `process`，`function`，`procedure` 中的代买是顺序执行的，而且当这些模块作为一个共同的整体时，它们之间也是并行的。

在并发代码中可以使用下列各项：

+ 运算操作符

+ `when` 语句（when/else 和 with/select/when）

+ `generate` 语句

+ `block` 语句

仔细观察可以发现，其实 when, generate, block 语句和预算语句相比，只是添加了一些条件判断，它们主要的核心还是运算操作符组成的运算，所以，并行代码的核心就是这些并行的运算语句。

### `when`

**When/else syntax:**

    #!VHDL
    assignment WHEN condition ELSE
    assignment WHEN condition ELSE
    ...;
    
**with/select/when syntax:**

    #!VHDL
    WITH identifier SELECT
    assignment WHEN value,
    assignment WHEN value,
    ...;
    
### `generate`

功能类似于 Verilog HDL 中的 generate，它常和 for/if 一起使用。
因为描述的对象是电路，最终的电路是固定的，功能也是静态的，所以，对于 generate，它的循环操作的上下界必须是静态的，否则代码是不可综合的。

实际上，引入 generate 的主要目的是为了写出更加通用的代码，达到修改最少代码，实现不同设计的目的，也就是动态编译。而引入 for 循环，只是为了减少代码量。

### `block`

VHDL 中存在两种类型的块 block：简单块 (simple block) 和 卫式块 (guarded block):

**simple block**

simple block 只是对原有代码进行了区域分割，目的也仅仅是为了增强代码的可读性和可维护性。

syntax:

    #!VHDL
    label: BLOCK
        [declarative part]
    BEGIN
        (concurrent statement)
    END BLOCK label;
    
**guarded block**

guarder block 是一种特殊的 block，它比 simple block 多了一个表达式，叫做 `guard expression`，只有当这个表达式为 True 时，这个 block 才会执行。

syntax:

    #!VHDL
    label: BLOCK (guard expression)
        [declarative part]
    BEGIN
        (concurrent guarded and unguarded statements)
    END BLOCK label;
    
<br>

## Sequential Code
* * *

VHDL 本质是并发执行的代码，但是在 `process`, `function`, `procedure` 内部的代码是顺序执行的，当它们作为一个整体时，相互之间也是并发执行的。

顺序代码并非只能与时序逻辑 (`sequential logic`) 对应，同样也可以用它们来实现组合逻辑 (`combinational logic`)。

顺序代码也称为描述代码 (`behavioral code`)。

这里主要讨论顺序代码，也就是这 3 个块中的代码，包括 `if`, `wait`, `case`, `loop` 语句。

### `process`

作用类似于 Verilog HDL 中的 always 语句。

**syntax**

    #!VHDL
    [lable:] PROCESS (sensitivity list)
        [VARIABLE name: type [range][ := initial_value;]]
    BEGIN
        (sequential code)
    END PROCESS [label];

### `if`

**syntax**

    #!VHDL
    IF conditions THEN assignments;
    ELSIF conditions THEN assignments;
    ...
    ELSE assignments;
    END IF;
    
### `wait`

如果在 process 中使用了 wait 语句，那么 process 就不能含有敏感信号列表了，所以此时 wait 必须是 process 的第一条语句。

**syntax1**

    #!VHDL
    WAIT UNTILL signal_condition;
    
**syntax2**

    #!VHDL
    WAIT ON signal1 [, signal2, ...];

**syntax3**

    #!VHDL
    WAIT FOR time;  --simulation only
    
### `case`

case 和 when 的区别在于，case 允许在每个测试条件下执行多个赋值操作，而 when 只能执行一个赋值操作。

**syntax**

    #!VHDL
    CASE identifier IS
        WHEN value => assignment;
        WHEN value => assignment;
        ...
    END CASE;

### `loop`

**syntax1: FOR/LOOP repeat a fix number of times**

    #!VHDL
    [label:] FOR identifier IN range LOOP
        (sequential statements)
    END LOOP [label];
    
**syntax: WHILE/LOOP**

    #!VHDL
    [label:] WHILE condition LOOP
        (sequential statements)
    END LOOP [label];
    
**syntax3: EXIT**

    #!VHDL
    [label:] EXIT [label] [WHEN condition];
    
**syntax4: NEXT**

    #!VHDL
    [label:] NEXT [loop_label] [WHEN condition];

<br>

## Signals & Variables
* * *

VHDL 提供了 `signal` 和 `variable` 两种对象来处理非静态数据；提供了 `constant` 和 `generic` 来处理静态数据。

`constant` 和 `signal` 是全局的，可以在顺序执行的代码中，也可以在并发执行的代码中；`variable` 是局部的，只能值顺序代码中，并且它们的值是不能向外传递的(如果像传递出去，必须先把这个变量值传递给一个信号，再由这个信号传递出去)。

### `constant`

constant 可以定义在 package, entity, architecture 中，对应的作用域也不同。

+ 定义在 package 中的 constant 是真正的全局的，可以被所有调用该 package 的 entity 使用

+ 定义在 entity 中的 constant 对于该 entity 的所有 architecture 而言是全局的

+ 定义在 architecture 中的 constant 仅在该 architecture 中是全局的

**syntax**

    #!VHDL
    CONSTANT name : type := value;
    
### `signal`

VHDL 中的 `signal` 代表的是逻辑电路中的 “硬”连线，既可以用于电路的输入输出端口，也可以用于 内部单元之间的连接。

**syntax**

    #!VHDL
    SIGNAL name : type [range] [:= initial_value];
    
+ 和 Verilog HDL 的 always 中的 reg 类似，VHDL 的 process 中的 signal 也是在进程结束时更新值。

+ 对同一个信号多次重复赋值，结果取决于编译器。(Xilinx XST 不报错，认为最后一次赋值是有效的)

### `variable`

相比于 signal 是局部的，variable 只能在 process，function，procedure 中使用，而且对它的赋值是立即更新的，新的值可以在下一行代码中立即使用。

**syntax**

    #!VHDL
    VARIABLE name : type [range] [:= initial_value];

<br>

## Reference

[Circuit Design with VHDL](http://www.amazon.com/Circuit-Design-VHDL-Volnei-Pedroni/dp/0262162245)
