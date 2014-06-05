Title:BUPT MITC lab Verilog HDL coding style guide 
Date: 2014-05-19 10:12
Category: FPGA
Tags: FPGA,Verilog,coding style 
Slug: bupt_mitc_lab_verilog_hdl_coding_style_guide
Author: Chien Gu
Summary: 和实验室的同学一起做项目，总结一份编码风格 。 

**Version** : 1.1

**Date** : 2014-5-24

**Author** : Chien Gu (guqian110@gmail.com)
    
**Summary** : This is a brief Verilog HDL coding style guide for BUPT MITC lab to design circuits on FPGA. This guide is only concerned about code format and dose not involve principles for writing synthesisable codes.

<br>

## 总则
* * *

+ **代码模块化**

    顶层模块只有子模块的例化，不包含任何逻辑 ；常用、通用功能模块化，避免在多个模块中重复实现多次；模块内容过多时考虑分解为多个模块；模块按照功能、信号传递流程原则划分 。

+ **模块结构化**

    分节书写，合理使用空格、括号，使代码更容易查看 。
    
+ **使用缩写**

    约定命名规则、大小写规则、常用单词缩写规则，避免过长的信号名 。

<br>

## 分述
* * *

### head of file

Xilinx ISE 自动生成的标准文件头部，添加 `Email`、`File Name` 两个信息，最终结果：

    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // Email:
    // 
    // Create Date:    20:43:36 11/12/2013 
    // Design Name: 
    // Module Name:    CLKMGN
    // File Name:      clkmgn.v
    // Project Name: 
    // Target Devices: 
    // Tool versions: 
    // Description: 
    //
    // Dependencies: 
    // 
    //
    // Revision: 
    // Revision 0.01 - File Created
    // Additional Comments: 
    //
    //////////////////////////////////////////////////////////////////////////////////

### module

**模块命名大小写：**

+ 文件名：xxx.v (小写)
+ 模块名：XXX (大写)
+ 例化名：U_XXX (大写)

**模块端口定义顺序：**

1. 输入
2. 输出
3. 双向

**模块调用规范：**

使用 *信号映射法*

举例说明：

    ///////////////////////////////////////////////////////////////////////////////////
    // Module Declaration                                                            //
    ///////////////////////////////////////////////////////////////////////////////////
    module MODULE_NAME (
        // input ports
        port_1, port_2, ... port_n,
        // output ports
        port_1, port_2, ... port_m
        );
    
    ////////////////////////////////////////////////////////////////////////////////////
    // Port Declarations                                                              //
    ////////////////////////////////////////////////////////////////////////////////////
        //input ports
        input   port_1;         // comments
        input   port_2;
        ...
        input   port_n;
    
        //output ports
        output  port_1;         // comments
        output  port_2;
        ...
        output  port_m;
        
    ///////////////////////////////////////////////////////////////////////////////////
    // Parameter Declarations                                                        //
    ///////////////////////////////////////////////////////////////////////////////////
        parameter   DIN     = 16,
                    DOUTA   = 16,
                    DOUTE   = 16,
                    DOUTCTR = 16;
    
    ///////////////////////////////////////////////////////////////////////////////////
    // Wire & Reg Declarations                                                       //
    ///////////////////////////////////////////////////////////////////////////////////
        wire    wire_1;
        wire    wire_2;
        ...
        wire    wire_x;
        
        reg     reg_1;
        reg     reg_2;
        ...
        reg     reg_y;
    
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
    
        always @(posdge clk or negdege rst_n) begin
            if (!rst_n) begin
                // reset
                ...
            end
            else begin
                // do something
                ...
            end
        end
        
        assign wire_1 = wire_2;
        ...
        
    endmodule
    
### FSM

有限状态机(Finite State Machine) 使用三段式格式。举例

    // FSM-1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            CS <= IDLE;
        end
        else begin
            // next state
            CS <= NS;
        end
    end
    
    // FSM-2
    always @* begin
        NS = 8'bx;
        case (CS)
            IDLE: begin
                // ...
            end
            S1: begin
                // ...
            end
            default: begin
                NS = IDLE;
            end
        endcase
    end
    
    // FSM-3
    always @(posdge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            
        end
        else begin
            // default output
            // ...
            case (NS)
                IDLE: begin
                    // ...
                end
                defaut: begin
                    // ...
                end
            endcase
        end
    end

### always

+ 一个 `always` 中不要同时含有 *组合逻辑* 和 *时序逻辑*，分开写在不同的 `always` 块中。
+ 组合逻辑使用 *阻塞赋值(=)*，时序逻辑使用 *非阻塞赋值(<=)*
+ 不要在多个 `always` 中对同一信号赋值，也不要在一个 `always` 中对一个信号进行多次赋值

标准 `always` 格式

    always @(posdge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            
        end
        else begin
            // do somethig
            
        end
    end

### parameter

parameter 全部大写，用 parameter 定义有实际意义的常数，比如 LED 亮灯状态、状态机状态等，避免 "magic number"。举例：

    ///////////////////////////////////////////////////////////////////////////////////
    // Parameter Declarations                                                        //
    ///////////////////////////////////////////////////////////////////////////////////
        parameter   DIN     = 16,
                    DOUTA   = 16,
                    DOUTE   = 16,
                    DOUTCTR = 16;

### if-else

标准 `if-else` 格式

    if (condition) begin
        // do something
        
    end
    else begin
        // do something
        
    end

### case-default

标准 `case` 格式

    case (variable)
        vaule1: begian
            // do something
            
        end
        value2: begin
            // do something
            
        end
        default: begin
            // do something
        end
    endcase

### naming

1. **模块名**

    单词首字母缩写，大写。举例
    
        DMI     // Data Memory Interface
        DEC     // Decoder

2. **模块间信号名**

    分为两部分，第一部分表示信号方向，大写，第二部分表示信号意义，小写，下划线连接。举例
    
        wire CPUMMU_wr_req;     // write request form CPU to MMU

3. **模块内命名**

    单词缩写，下划线连接，小写。举例
    
        wire sdram_wr_en;       // SDRAM write enable

4. **系统级命名**

    时钟信号、置位信号、复位信号等需要输送到各个模块的全局信号，以 `SYS_` 前缀开头。举例
    
        wire SYS_clk_100MHz;         // system clock
        wire SYS_set_cnt;            // system counter set
        wire SYS_rst_cnt;            // system counter reset
    
5. **低电平有效信号命名**

    低电平有效信号加后缀 `_n`，举例
    
        wire rst_n;             // low valid reset

6. **经过锁存器的信号**

    经过锁存器的信号加后缀 `_r`，以和锁存前区别。举例
    
        reg din_r;              // latch input data

7. **参数名**

    实际意义缩写，大写。举例
    
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


### incedent

+ **tab**

    所有的 `tab` 全部用 *4 个 `space`* 代替！不同层次之间用 `tab(4 sapce)` 缩进 。

+ **space**

    + 信号端口定义，关键字、宽度说明、信号名之间对齐。举例

            input          clk;
            input          rst_n;
            input  [7:0]   din;
            
            output [7:0]   dout;
            
    + 二元运算符用 `space` 隔开
    
            assign dout = dout_en ? result : NULL;


### comments

采用英文，合理注释。修改代码一定要注释，添加 Revision 信息 。

<br>

## 建议
* * *

**开发工具：**

+ 管理工程： Xilinx ISE
+ 综合工具： Xilinx Synthsis Tools
+ 仿真平台： ModelSim SE
+ 代码编辑： Sublime Text 2 + Verilog 插件
