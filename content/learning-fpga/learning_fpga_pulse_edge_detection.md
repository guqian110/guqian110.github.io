Title: 学习 FPGA 脉冲边沿检测
Date: 2014-04-08 18:33
Category: FPGA
Tags: FPGA
Slug: learning_fpga_pulse_edge_detection
Author: Chien Gu
Summary: 总结 FPGA 中的脉冲边沿检测方法

脉冲边沿检测是 FPGA 设计中经常用到的方法，本文总结一下其原理和实现代码，可以将其加入我们自己的代码库中，以备以后使用 。

<br>

## 脉冲边沿检测原理
* * *


![pulse](/images/learning_fpga_pulse_edge_detection/pulse.jpg)

如图，任何一个脉冲既有上升沿也有下降沿，系统的时钟周期一定要比脉冲宽度小，而且越小越好，即频率越高越好 。

**脉冲边沿的特点就是：边沿两侧的电平发生了变化 。** 利用这一点，我们就可以设计出检测边沿的方法 。

**操作方法：** 建立 2 个寄存器，形成二级寄存器，在时钟触发中，首先把数据送入第一个寄存器中，然后在下一个时钟上沿到来时，将第一个寄存器中的数据存入第二个寄存器，也就是说第二个寄存器中的数据始终比第一个寄存器晚一个周期，即晚一个数据 。根据系统时钟检测，如果前后进来的信号发生了变化，可以用异或运算，异或结果为1，说明电平发生了变化，有边沿产生。

<br>

## 脉冲边沿检测方法
* * *

### 检测是否有边沿

**程序：**

```verilog
    module DETECT_EDGE (  
        clk,rst_n,trig_in,trig_edge  
        ); 
        
        input clk;  
        input rst_n;  
        input trig_in;  
      
        output trigedge;  
        
        reg trig_r1;  
        reg trig_r2;  
        
        always @ (posedge clk or negedge rst_n) begin  
            if (!rst_n) begin  
                trig_r1 <= 1'b0;  
                trig_r2 <= 1'b0;  
            end  
            else begin  
                trig_r1 <= trig_in;  
                trig_r2 <= trig_r1;  
            end  
        end  
      
        assign trigEdge = trig_r1 ^ trig_r2;  
        
    endmodule
```

**综合结果：**

![rtl1](/images/learning-fpga-pulse-edge-detection/rtl1.png)

**仿真结果：**

![sim1](/images/learning-fpga-pulse-edge-detection/sim1.png)

### 检测 上/下 边沿

**下降沿检测原理：** 将第一个寄存器中的数据取反与第二个寄存器的数据相与，产生的数存入一个新的寄存器里，这样产生的结果是当第一个寄存器中的数据由 1 变为 0 时，就会在新的寄存器里产生一个高电平，并维持一个周期 。

**上升沿检测原理：** 将第二个寄存器中的数据取反与第一个寄存器的数据相与，产生的数存入一个新的寄存器里，这样产生的结果是当第一个寄存器中的数据由 0 变为 1 时（上升沿，此时 r1 变为 1，但 r2 仍保持前一周期的 0），就会在新的寄存器里产生一个高电平，并维持一个周期 。

**程序：**

```verilog
    module DETECT_EDGE (  
        clk,rst_n,trig_in,trig_pos_edge,trig_neg_edge  
        );  
  
        input clk;  
        input rst_n;  
        input trig_in;  
      
        output trig_pos_edge;  
        output trig_neg_edge;  
  
        reg trig_r0;  
        reg trig_r1;  
        reg trig_r2;  
        
        always @ (posedge clk or negedge rst_n) begin  
            if (!rst_n) begin  
                trig_r0 <= 1'b0;  
                trig_r1 <= 1'b0;  
                trig_r2 <= 1'b0;  
            end  
            else begin  
                trig_r0 <= trig_in;  
                trig_r1 <= trig_r0;  
                trig_r2 <= trig_r1;  
            end  
        end  
      
        assign trig_pos_edge = trig_r1 & (!trig_r2);    // Detect posedge  
        assign trig_neg_edge = (!trig_r1) & trig_r2;    // Detect negedge  
        
    endmodule  
```

**综合结果：**

![rtl2](/images/learning-fpga-pulse-edge-detection/rtl2.png)

**仿真结果：**

![sim2](/images/learning-fpga-pulse-edge-detection/sim2.png)

<br>

**另外一种写法：**
```verilog
    module DETECT_EDGE (  
        clk,rst_n,trig_in,tirg_pos_edge,trig_neg_edge  
        );  
           
        input clk;  
        input rst_n;  
        input trig_in;  
      
        output trig_pos_edge;  
        output trig_neg_edge;  
        
        reg [2:0] trig_r;  
        
        always @ (posedge clk or negedge rst_n) begin  
            if (!rst_n)  
                trig_r <= 3'b0;  
            else  
                trig_r <= {trig_r[1:0],trig_in};  
        end  
      
        assign trig_pos_edge = (trig_r[1:0] == 2'b01);  
        assign trig_neg_edge = (trig_r[1:0] == 2'b10);  
        
    endmodule
```

**综合结果：**

![rtl3](/images/learning-fpga-pulse-edge-detection/rtl3.png)

**仿真结果：**

![sim3](/images/learning-fpga-pulse-edge-detection/sim3.png)

<br>

## 脉冲边沿检测应用
* * *

理想的键盘输入特性：

![keyboard1](images/learning-fpga-pulse-edge-detection/keyboard1.png)

然而实际的键盘受制造工艺等影响，其输入特性不可能如上图完美 。当按键按下时，在触点即将接触到完全接触这段时间里，键盘的通断状态很可能已经改变了多次 。即在这段时间里，键盘输入了多次逻辑 0 和 1，也就是输入处于失控状态 。如果这些输入被系统响应，则系统暂时也将处于失控状态，这是我们要尽量避免的 。在触点即将分离到完全分离这段时间也是一样的 。

实际的键盘输入特性：

![keyboard2](images/learning-fpga-pulse-edge-detection/keyboard2.jpg)

**软件消抖** 要占用系统资源，在系统资源充足的情况下使用软件消抖更加简单 。软件消抖的实质在于降低键盘输入端口的采样频率，将高频抖动略去 。实际应用中通常采用延时跳过高频抖动区间，然后再检测输入做出相应处理。一般程序代码如下：

```c
    if (value == 0)         //一旦检测到键值
    {
        Delay();            //延时20ms，有效滤除按键的抖动
        if(value == 0)      //再次确定键值是否有效
        {
            do something    //执行相应处理
        }
    }
```

这段软消抖程序从机理上看不会有什么问题，通常在软件程序不太 "繁忙" 的情况下也能够很好的消抖并做相应处理 。但是如果在延时期间产生了中断，则此中断可能无法得到响应 。

对于硬件资源丰富的 FPGA 系统，可以使用硬件来减轻软件工作量，通常称之为 **"硬件加速"** 。在按键信号输入到软件系统前用逻辑对其进行一下简单的处理即可实现所谓的"硬件消抖"，代码如下：

```verilog
    //对输入信号inpio硬件滤波，每20ms采样一次当前值
    reg[18:0] cnt; //20ms计数器
    
    always @ (posedge clk_25m or negedge rst_n)
        if (!rst_n)
            cnt <= 19'd0;
        else if (cnt < 19'd500000)
            cnt <= cnt+1'b1;
        else 
            cnt <= 19'd0;

    reg[1:0] inpior; //当前inpio信号锁存，每20ms锁存一拍

    always @ (posedge clk_25m or negedge rst_n)
        if (!rst_n)
            inpior <= 2'b11;
        else if (cnt == 19'h7ffff)
            inpior <= {inpior[0],inpior};
        else
            inpior <= inpior;

    wire inpio_swin = inpior[0] | inpior[1]; //前后20ms两次锁存值都为0时才为0
```

该程序中设置了一个 20 ms 计数器，通过间隔 20 ms 对输入信号 inpio 采样两次，两次相同则认为键盘输入稳定，得到用硬件逻辑处理后的 inpio_swin 信号则是消抖处理过的信号 。程序不再需要 delay() 来滤波了，也不会出现使用纯软件处理出现的 "中断失去响应" 的情况了，这就是 "硬件加速" 的效果 。

我们可以看到，传统单片机等系统大多是串行处理，即顺序执行，只能并行处理一些中断程序 。对于这样的系统，只能采用单纯软件或硬件电路消抖，但都不那么完美 。而对于 FPGA 等并行处理的系统，其优势就很明显，只要片内逻辑资源够用，通过硬件加速软件消抖的处理，完全可以做到按键消抖并行化，不影响系统的实时性 。
    
<br>

## 参考

[脉冲边沿检测（Verilog）](http://bbs.ednchina.com/BLOG_ARTICLE_213430.HTM)

[脉冲边沿检测原理verilog版本](http://blog.csdn.net/lg2lh/article/details/8104551)

[脉冲边缘检测法](http://blog.csdn.net/LVY33/article/details/6225925)

[按键消抖](http://blog.sina.com.cn/s/blog_790c0ca10100srid.html)
