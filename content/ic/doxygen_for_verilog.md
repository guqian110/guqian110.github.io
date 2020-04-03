Title: 针对 Verilog 的 Doxygen
Date: 2015-01-21 10:25
Category: IC
Tags: doxygen, doxverilog, verilog
Slug: doxygen_for_verilog
Author: Qian Gu
Summary: 学习 Doxverilog。

最近学习了 Doxygen，它可以帮助我们生成美观的文档。Doxygen 支持的程序语言中包含 VHDL，但是不包含 Verilog。

那么问题就又来了：**有没有一个支持 Verilog 的类似 Doxygen 的程序？**

答案当然是：**有， Doxverilog**

机智的网友早就遇到了和我一样的问题：

[Documentation generator for Verilog][page1]

[Documenting Verilog (AMS) using Doxygen/Doxverilog][page2]

[Doxverilog has been updated][page3]

我搜到了两个工具：一个是 perl 脚本[v2html][v2html]，另一个就是 Doxverilog。前者生成的页面美观性实在不敢恭维，理想工具当然是 Doxverilog。

[page1]: http://www.edaboard.co.uk/documentation-generator-for-verilog-t241923.html

[page2]: http://sndegroot.blogspot.com/2011/08/documenting-verilog-ams-using.html

[page3]: http://sndegroot.blogspot.com/2014/04/doxverilog-has-been-updated.html

[v2html]: http://www.burbleland.com/v2html/v2html.html

## Doxverilog
* * *

> Doxverilog  is a nativ verilog parser (Verilog 2001) for Doxygen. After installing this patch you can documentate your verilog project  similar to VHDL in Doxygen.
> Patch against the doxygen-1.7.0 version. 
 
Doxverilog基于 Doxygen ，只是额外添加了对 Verilog 语言的支持。它托管在 [sourceforge][sourceforge] 上的压缩包貌似是损坏的，不能正常解压，幸好在 Github 上的还是好的：

[Doxverilog on Github][github]

关于 Doxverilog 的安装使用方法，github 上已经说的很清楚了，下面只记录一下我遇到的问题。

[github]: https://github.com/ewa/doxverilog/tree/master/Doxverilog2.7
[sourceforge]: http://sourceforge.net/projects/doxverilog.berlios/

### Installation

安装步骤：

1. patch

		patch -F3 -p0  < linux.patch

2. compile

		./configure
		make
		make install

+ 写本文时，Doxverilog 的版本号是 2.7，对应的 Doxygen 的版本号是 1.8.1，而 Doxygen 官网上的版本已经更新到了 1.8.9，如果最新版本可能在编译的时候报错。

+ 在 patch 时，可能会遇到询问，一路 y 下去即可。

+ 在 compile 时，可能会报错，我遇到的报错是 vhdlparse.cpp 缺少行末分号的小问题，自己添加就行。

+ 编译安装完成之后，我们应该可以使用一个文档来测试一下，如果生成的配置文件中包含 `OPTIMIZE_OUTPUT_VERILOG` 这个选项，那么就说明破解安装成功了。

### Configuration

在修改配置文档时，除了常规的配置选项之外，对于 Verilog 我们还需要额外注意一下几个选项：

+ `OPTIMIZE_OUTPUT_VERILOG = YES` 针对 Verilog 进行输出优化

+ `FILE_PATTERNS = *.v` 标明选择 verilog 源文件

### Documenting Verilog/VHDL

注释规则：

+ 对于 Verilog 的注释规则，和 VHDL 类似，唯一的不同之处在于 VHDL 使用 `--!` 来开始注释，Verilog 使用 `//%` 作为注释的开头。

+ VHDL 中使用单行的 `--!` 来开始 brief description，使用多行的 `--!` 开始 detailed description。

+ Verilog 使用单行的 `//%` 开始 brief description，使用多行的 `//%` 开始 detailed description。

+ 所有的注释都在对应代码的前面，只有一个例外：端口的 brie description 可以写在代码后，而且不用像 C++ 中一样修改注释的头部

**example:**

下面是 Doxygen 官网是 VHDL 注释的例子：

    #!VHDL
	-------------------------------------------------------
    --! @file
    --! @brief 2:1 Mux using with-select
    -------------------------------------------------------
    
    --! Use standard library
    library ieee;
    --! Use logic elements
        use ieee.std_logic_1164.all;
   
   	--! Mux entity brief description
   
   	--! Detailed description of this 
    --! mux design element.
    entity mux_using_with is
        port (
            din_0   : in  std_logic; --! Mux first input
            din_1   : in  std_logic; --! Mux Second input
            sel     : in  std_logic; --! Select input
            mux_out : out std_logic  --! Mux output
        );
    end entity;
    
    --! @brief Architecture definition of the MUX
    --! @details More details about this mux element.
    architecture behavior of mux_using_with is
    begin
        with (sel) select
        mux_out <= din_0 when '0',
                   din_1 when others;
    end architecture;

生成的 [结果](http://www.stack.nl/~dimitri/doxygen/manual/examples/mux/html/index.html)。

我写的 Verilog 的注释：

    #!verilog
    //% @file mycounter.v
    //% @brief Implementation file of module mycounter.
    //% 
    //% @author Qian Gu
    //% @version 1.0
    //% @date 2015-01-20
    
    //% This is a test project,
    //% it's a increase counter module 256.
    //%
    module mycounter(
    	clk,rst,dout
     );

    // Port Declaratiosn
    	input clk; //% clock signal
    	input rst; //% reset siganl, active high
    	
    	output reg [7:0] dout; //% count result
    
    // Main Body of Code
    
    always @ (posedge clk or negedge rst) begin
    	if (!rst) begin
    		dout <= 8'b0;
    	end
    	else begin
    		dout <= dout + 1;
    	end
    end
    
    endmodule


<br>

## Ref

[doxygen manual](http://www.stack.nl/~dimitri/doxygen/manual/docblocks.html#vhdlblocks)

[doxverilog][github]

