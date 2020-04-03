Title: 可配置设计
Category: IC
Date: 2015-04-17
Tags: configurable design
Slug: configurable_design
Author: Qian Gu
Summary: 总结可配置设计

[Verilog 编程艺术][book1] 的可配置设计一章 学习笔记。

[book1]: http://www.amazon.cn/EDA%E7%B2%BE%E5%93%81%E6%99%BA%E6%B1%87%E9%A6%86-Verilog%E7%BC%96%E7%A8%8B%E8%89%BA%E6%9C%AF-%E9%AD%8F%E5%AE%B6%E6%98%8E/dp/B00HNVY3SY/ref=sr_1_1?ie=UTF8&qid=1429188978&sr=8-1&keywords=verilog%E7%BC%96%E7%A8%8B%E8%89%BA%E6%9C%AF

## Configurable design
* * *

> 我们做设计的时候，就要考虑做成可以灵活配置的设计，不管是小模块，还是大模块，这样便于以后维护和移植。可配置模块的设计方法如下：
>
> 1. 使用 parameter 和 `define
> 
> 2. 使用 for 语句生成多条语句
> 
> 3. 使用 generate、for、if 等语句生成多条语句和多个实例化
> 
> 4. 通过工具或脚本生成配置参数
> 
> 5. 通过工具或脚本直接生成 Verilog 代码

书里面总结了上面的这些方法，以前总结过另外一篇博客：[Verilog 中的参数化建模][blog1]，里面总结了 条件编译、`define、parameter、localparam 的用法和区别。

[Reuse Methodology Manual for System-on-a-Chip Designs][book2] 是一本很经典的书，里面有全面详细的可重用设计的方法，有时间了看了再补上。

[blog1]: http://guqian110.github.io/pages/2014/07/09/parameterization_modeling_in_veriog.html
[book2]: http://www.amazon.com/Reuse-Methodology-Manual-System-Designs/dp/0387740988

下面是一些实际例子，展示如何设计可配置模块。

<br>

## Gray-2-Binary
* * *

Binary 编码是最自然的、最符合平常的思维的，但是这种编码方式有时候存在一些问题：比如在 DAC 中，数字 3(011) 变为 数字 4(100) 时，每 1 bit 都发生了变化，电路中会产生很大的尖峰电流脉冲。

而 Gray 编码就没有这样的问题，Gray 码有很多优点，应用很广泛，就不再重复了。（比如在 FIFO 设计中，内部就有 Gray 和 Binary 的相互转换）

下面的例子，通过**将端口位宽参数化**，实现了可配置的转换模块：

**example1:**

    #verilog
    module gray2bin #(parameter SIZE = 8)
        (input  [SIZE-1 : 0]    gray,
         output [SIZE-1 : 0]    bin);

        generate
            genvar i;
            for (i = 0; i < SIZE; i = i + 1)
            begin:bit
                assign bin[i] = ^gray[SIZE-1 : i];
            end
        endgenerate

    endmodule

    #verilog
    module bin2gray #(parameter SIZE = 8)
        (input  [SIZE-1 : 0]    bin,
         output [SIZE-1 : 0]    gray);

        assign gray = bin ^ {1'b0, bin[SIZE-1 : 1] };

    endmodule

<br>

## CRC
* * *

Cyclic Redundancy Check，循环冗余检测。不同的协议使用的 CRC 多项式不相同，在硬件上体现在 LSR 的宽度和抽头位置不同，我们可以写一个通用的 CRC 模块。

下面的例子，通过**将端口位宽参数化**，实现了可配置的 CRC 模块。

**example2**

    #!verilog
    module general_crc
        #(parameter  WIDTH = 16,
                     [WIDTH-1 : 0]  INIT_VALUE = 0,
                     [WIDTH-1 : 0]  CRC_EQUATION = 0)

        (input                          clk,
         input                          rst,
         input                          init,       // if init = 1, initialize crc_value 
                                                    // with INIT_VALUE
         input                          enable,     // if enbale = 1, calculate crc_value
                                                    // from din
         input                          drain,      // if drain = 1, crc_value is  shifted
                                                    // out from dout
         input                          din,
         output                         dout,
         output  reg    [WIDTH-1 : 0]   crc_value   // parallel out crc_value
         );

        // implementation code

    endmodule

在调用时，通过传递合适的参数即可实现不同的 CRC 模块。

<br>

## FIFO controller
* * *

略...

<br>

## RAM wrapper
* * *

### problem

FPGA 中的 RAM/ROM 是用厂家的工具生成的，而 ASIC 中的 RAM/ROM 是用 ARM 公司的 Memory Compiler 生成的，两者的端口名不一样，有些控制信号的极性也不相同。

通常的做法是**使用条件编译**，写如下的代码

    #!verilog
    `ifdef  FPGA
        // instantiate module for FPGA
    `else
        // instantiate module for ASIC
    `endif

这种方法的缺点主要有：

1. 但内部有几十个到上百个 RAM/ROM 时，手动连接的工作量很大

2. 做 ATPG 时，手工写代码很容易出错

3. 做 BIST 测试时，需要添加额外的逻辑

另外一种更好的方法是 **写 wrapper**

### wrapper

#### name

命名规范：按照 ARM 公司的规范，

RAM/ROM type:

|Type||little/large||Ports||Comments|
|------||------------||--------||--------------------------------|
| RF1  ||   little   || single ||                                |
| RA1  ||   large    || single ||                                |
| RF2  ||   little   || dual   || one read port & one write port |
| RA2  ||   large    || dual   || two read port & two write port |
| ROM  ||            || single ||                                |

RAM/ROM write enable (WEN) type:

|Type||Description|
|------||--------------------|
|  IW  ||  bit-write-enable  |
|  BW  ||  byte-write-enable |
|  WW  ||  word-write-enable |

命名时按照 `<ram_type>_<wen_type>_<depth>x<width>` 的规则，在 FPGA 上则加上前缀 `F_`，即：

`F_<ram_type>_<wen_type>_<depth>x<width>`

举例：

+ F_RA1_BW_2kx32：RA1 类型，支持 byte 写，4 个 WEN，深度为 2k，宽度为 32-bit

+ F_RF1_IW_128x8：RF1 类型，支持 bit 写，8 个 WEN，深度为 129，宽度为 8-bit

#### generate wrapper

0. 提前写好的 Perl 脚本 和 参数化模块

1. 根据实际需求，写配置文件

2. 运行 Perl 脚本，读取配置文件，生成 wrapper

3. 将生成的 wrapper 加入到 project 中


每个步骤的具体实现方法以后再补...

<br>

## GPIO
* * *

运用模块化的设计思想，提取公共代码，设计子模块，通过子模块实现大模块的设计，虽然参数化以后 GPIO 看起来比较复杂，但是这个模块是很通用的，设计好之后只需要修改参数就可以重复使用了。这在设计期间，修改起来非常方便。

整个 GPIO 由 5  个模块组成：

    gpio.v (module gpio)
     |___gpio_params.v (parameters define)
     |___gpio_reg.v    (module gpio_reg)
     |___gpio_check.v  (module gpio_check)
     |___gpio_sync.v   (module gpio_sync2_reg/gpio_sync3_reg/gpio_sync_pulse)

具体代码略，直接看书

<br>

## BusMatrix
* * *

...

<br>

## Andes Core N801
* * *

...

<br>

## ARM926EJS
* * *

...

<br>

## coreConsultant
* * *

...

<br>

## Ref

[Verilog 编程艺术][book1]
