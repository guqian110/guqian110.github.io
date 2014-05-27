Title: Arduino 入门
Date: 2014-05-27 12:34
Category: Arduino
Tags: Arduino, Opensource Hardware
Slug: arduino_getting_started
Author: Chien Gu
Summary: 学习 Arduino，#1 Getting Started

## What is Arduino
* * *

![logo](/images/arduino-getting-started/logo.png)
版权所有：Arduino.cc

[Arduino 官网][official] 首页的介绍：

> ARDUINO IS AN OPEN-SOURCE ELECTRONICS PROTOTYPING PLATFORM BASED ON FLEXIBLE, EASY-TO-USE HARDWARE AND SOFTWARE. IT'S INTENDED FOR ARTISTS, DESIGNERS, HOBBYISTS AND ANYONE INTERESTED IN CREATING INTERACTIVE OBJECTS OR ENVIRONMENTS.

[官方网站最权威的答案：][introduction]

> Arduino is a tool for making computers that can sense and control more of the physical world than your desktop computer. **It's an open-source physical computing platform based on a simple microcontroller board, and a development environment for writing software for the board.**

> Arduino can be used to develop interactive objects, taking inputs from a variety of switches or sensors, and controlling a variety of lights, motors, and other physical outputs. Arduino projects can be stand-alone, or they can communicate with software running on your computer (e.g. Flash, Processing, MaxMSP.) The boards can be assembled by hand or purchased preassembled; the open-source IDE can be downloaded for free.

**Development Language：** [Arduino programming language][language]

**IDE：** [Arduino IDE][ide]

**补充：** [Wikipedia 上的介绍][arduino on wiki]

**简单的说：**

Arduino 是一个开放源代码的单片机，它使用了 Atmel AVR 单片机，采用了基于开放源代码的软硬件平台，构建于开放源代码 simple I/O 接口板。开发语言为 Arduino programming language（基于 Wiring 语言），开发环境基于 Processing 。

[official]: http://arduino.cc/
[introduction]: http://arduino.cc/en/Guide/Introduction
[language]: http://arduino.cc/en/Reference/HomePage
[ide]: http://arduino.cc/en/Main/Software
[arduino on wiki]: http://en.wikipedia.org/wiki/Arduino

<br>

## Story of Arduino
* * *

wikipedia 上的[小故事][story]：

> Arduino的核心开发团队成员包括：Massimo Banzi，David Cuartielles，Tom Igoe，Gianluca Martino，David Mellis 和 Nicholas Zambetti。

> 据说 Massimo Banzi 之前是意大利 Ivrea 一家高科技设计学校的老师。他的学生们经常抱怨找不到便宜好用的微控制器。2005年冬天， Massimo Banzi 跟 David Cuartielles 讨论了这个问题。David Cuartielles 是一个西班牙籍芯片工程师，当时在这所学校做访问学者。两人决定设计自己的电路板，并引入了 Banzi 的学生 David Mellis 为电路板设计编程语言。两天以后，David Mellis 就写出了程式码。又过了三天，电路板就完工了。这块电路板被命名为 Arduino。几乎任何人，即使不懂电脑编程，也能用 Arduino 做出很酷的东西，比如对传感器作出回应，闪烁灯光，还能控制马达。随后 Banzi，Cuartielles，和 Mellis 把设计图放到了网上。保持设计的开放源码理念，因为版权法可以监管开源软件，却很难用在硬件上，他们决定采用共享创意许可。共享创意是为保护开放版权行为而出现的类似 GPL 的一种许可（license）。在共享创意许可下，任何人都被允许生产电路板的复制品，还能重新设计，甚至销售原设计的复制品。你不需要付版税，甚至不用取得 Arduino 团队的许可。然而，如果你重新发布了引用设计，你必须说明原始 Arduino 团队的贡献。如果你调整或改动了电路板，你的最新设计必须使用相同或类似的共享创意许可，以保证新版本的 Arduino 电路板也会一样的自由和开放。唯一被保留的只有 Arduino 这个名字。它被注册成了商标。如果有人想用这个名字卖电路板，那他们可能必须付一点商标费用给 Arduino 的核心开发团队成员。

[story]: http://zh.wikipedia.org/wiki/Arduino

<br>

## Why is Arduino
* * *

[官网介绍][introduction]：

> There are many other microcontrollers and microcontroller platforms available for physical computing. Parallax Basic Stamp, Netmedia's BX-24, Phidgets, MIT's Handyboard, and many others offer similar functionality. All of these tools take the messy details of microcontroller programming and wrap it up in an easy-to-use package. **Arduino also simplifies the process of working with microcontrollers, but it offers some advantage for teachers, students, and interested amateurs over other systems:**
>
> + Inexpensive
> + Cross-platform (Windows, Linux, Macintosh OSX)
> + Simple, clear programming environment
> + Open source and extensible software
> + Open source and extensible hardware

<br>

## How-to Develope
* * *

### IDE installation

官网上有 Windows, Linux, Mac 的详细安装步骤：

+ [for Windows][windows]
+ [for Linux][linux]

**Linux 安装过程**

方法一：

1. 解决包依赖关系：安装 openjdk-7-jre (openjdk-6-jre, sun's java 6 runtime, the sun-java6-jre package, the oracle JRE 7 应该也可以)

        sudo apt-get install openjdk-7-jre
    
2. 下载合适的 [Arduino IDE][ide]
3. 解压、切换到解压路径，运行目录下的 `arduino` 脚本

        tar -zxvf arduino-1.0.5-linux32.tgz
        cd arduino-1.0.5
        ./arduino

方法二 (for Ubuntu)：

1. 下载 & 安装

        sudo apt-get install arduino arduino-core

2. 运行

        $ arduino

[windows]: http://arduino.cc/en/Guide/Windows
[linux]: http://playground.arduino.cc/Learning/Linux


### Dev

**IDE**

Arduino IDE 是用 Java 写的跨平台的程序，它源自 [Processing programming language][processing] 和 [Wiring][wiring] 项目的 IDE 。它是为艺术家和其他不熟悉软件开发的新手而设计的。它包含一个有语法高亮、括号匹配、自动缩进功能的代码编辑器，还可以通过一个按键完成编译程序(compile)和烧录至电路板(upload)的功能。


**Programming**

一个 Arduino 程序/代码 称为 "*Sketch*"。Arduino 程序是用 C/C++ 写成的，Arduino IDE 含有一个名叫 "Wiring" 的代码库(源自于 Wiring 项目)，这样子可以大幅度简化常用 I/O 操作，用户只需要定义两个函数就可以写出一个可以运行的程序：

+ *setup()* : 程序开始运行时启动，只运行一次，初始化配置
+ *loop()* : 一直循环被调用，直到断电

Arduino 的示例程序 "Blink"：(等同于 C 的 hello world，对于硬件最简单就是控制一个 LED 的亮灭)

    /*
    Blink
    Turns on an LED on for one second, then off for one second, repeatedly.
 
    This example code is in the public domain.
    */
 
    // Pin 13 has an LED connected on most Arduino boards.
    // give it a name:
    int led = 13;

    // the setup routine runs once when you press reset:
    void setup() {                
      // initialize the digital pin as an output.
      pinMode(led, OUTPUT);     
    }

    // the loop routine runs over and over again forever:
    void loop() {
      digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
      delay(1000);               // wait for a second
      digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
      delay(1000);               // wait for a second
    }

上面的这段代码对于一个标准 C++ 编译器来说是无效的，事实上当我们按下 IDE 界面上的 "Upload to I/O board" 按钮时，IDE 会拷贝一份代码，在开头加上 `include` 指示，在结尾加上一个很简单的 `main()` 函数，这样它就是一个有效的 C++ 程序了。

Arduino 使用 [GNU toolchain][gun toolchain] 和 AVR Libc 来编译程序的，使用 AVRdude 把程序下载到板子上。因为 Arduino 平台采用的是 Atmel 的微控制器，所以 Atmel 的开发环境 AVR Studio 或者更新的 Atmel Studio 应该也可以作为 Arduino 的开发环境。

**学习资源**

1. Arduino 的联合创始人 Massimo Banzi 的 Tutorial Series Vedio
    
    [优酷视频地址][youku]，一共 11 课，涵盖最基本的面包板搭电路、I/O 接口控制、传感器控制、网络应用等方面，如果有编程基础，很快就可以上手制作自己的设备了～

2. [Arduino 中文社区][arduino cn]

    [论坛教程汇总帖][tutorial]，因为 Arduino 诞生的一个很大的目的就是为设计师、艺术家、业余爱好者提供更加方便的开发环境，所以，Arduino 的教程对于有编程基础的同学来说是很容易的 ：-P

3. [Arduino Language Reference en][reference en]

    官网上关于 Arduino 编程语言的介绍
    
4. [Arduino Language Reference zh][reference zh]

    Arduino 中文社区翻译的 编程语言介绍

5. [Arduino Core Functions, Libraries][function libraries]
    
    官网上关于 IDE 中 `File/Examples/` 下示例程序的说明

[processing]: http://en.wikipedia.org/wiki/Processing_(programming_language)
[wiring]: http://en.wikipedia.org/wiki/Wiring_(development_platform)
[gun toolchain]: http://en.wikipedia.org/wiki/GNU_toolchain
[youku]: http://www.youku.com/playlist_show/id_19440139.html
[arduino cn]: http://www.arduino.cn/
[tutorial]: http://www.arduino.cn/thread-1066-1-1.html
[reference en]: http://arduino.cc/en/Reference/HomePage
[reference zh]: http://www.arduino.cn/reference/
[function libraries]: http://arduino.cc/en/Tutorial/HomePage

<br>

## 参考

[Arduino official website][official]

[Arduino on wiki][arduino on wiki]

[Arduino 中文社区][arduino cn]
