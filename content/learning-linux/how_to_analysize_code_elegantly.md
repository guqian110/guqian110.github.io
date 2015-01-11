Title: 如何优雅的分析代码
Date: 2015-01-11 18:49
Category: Linux
Tags: doxygen, code
Author: Qian Gu
Slug: how_to_analysize_code_elegantly
Summary: 学习 Doxygen + Graphviz 的使用方法

当我们来接手一个别人的工程时，阅读别人的代码是一件很痛苦的事。成千上百的函数，糟糕的代码风格，不知所云的注释，这些都是让人抓狂。那么，问题就来了：**如何优雅地分析别人的代码？**

答案就是：**Doxygen + Graphviz**

整个工作流程很简单，我们在写程序时按照 Doxygen 约定的格式注释代码（不注释也可以），Doxygen 会对代码进行分析，然后列出程序中的变量、类定义、数据结构、函数表用关系等，然后调用 Graphviz 将结果用图形化的形式表现出来。

这个功能在自动生成文档、代码分析时非常强大，下面分别简单介绍一下。

**P.S.**

在 Linux 环境下，Vim 有插件 **DoxygenToolKIt.vim** 可以帮助我们很方便地写出 Doxygen 风格的代码。这里只介绍 Doxygen + Graphviz，DoxygenToolKit.vim 在另外一篇中介绍。

<br>

## Graphviz
* * *

### What is Graphviz?

[Graphviz official website][graphviz]:

> Graphviz is open source graph visualization software. Graph visualization is a way of representing structural information as diagrams of abstract graphs and networks. It has important applications in networking, bioinformatics,  software engineering, database and web design, machine learning, and in visual interfaces for other technical domains. 

### Installation

官方网站上有各个平台（Windows/Unix/Linnux/Mac）的安装文件和源码，在 Ubuntu 13.10 saucy 下，直接使用 apt-get 安装即可：

    sudo apt-get install graphviz

### More

更多详细的介绍见官网的 About、Documentation、Wiki、FAQ。

[graphviz]: http://www.graphviz.org/

<br>

## Doxygen
* * *

### What is Doxygen

[Doxygen Official website][doxygen]:

> Doxygen is the de facto standard tool for generating documentation from annotated C++ sources, but it also supports other popular programming languages such as C, Objective-C, C#, PHP, Java, Python, IDL (Corba, Microsoft, and UNO/OpenOffice flavors), Fortran, VHDL, Tcl, and to some extent D.

### Installation

官网上的 Manual 中有详细的介绍，对于不同平台，采用不同的安装方式（从源码编译安装、二进制文件安装），下面仅记录我在 Ubuntu 下使用源码编码的方式安装过程。

1. 下载源代码

        git clone https://github.com/doxygen/doxygen.git
        cd doxygen
    
2. 安装

        ./configure
        make
        make install

安装成功之后，在 `/usr/bin/` 或者 `/usr/local/bin` 目录下可以查看到二进制 `doxygen` 文件。

**P.S.**

1. 若 configure 出错，检查依赖关系，安装需要系统中有 GNU 工具（flex, bison, libiconv and GNU make, and strip）和 Perl 支持。

2. 因为 Doxygen 要调用 Graphviz，所以先安装 Graphviz，然后编译安装 Doxygen

### Getting Started

[Getting Started][getting started]:

1. 检查 Doxygen 是否支持你项目所使用的语言

    Doxygen 支持  C, C++, C#, Objective-C, IDL, Java, VHDL, PHP, Python, Tcl, Fortran, D
    
2. 创建一个配置文件

    Doxygen 使用一个配置文件来工作，，每个项目都应该有一个自己对应的配置文件。我们可以使用 `doxygen -g` 来让 Doxygen 自动生成一个参考配置文件，然后修改其中个别配置即可.
    
        doxygen -g <config-file>
        
    **常用配置：**
    
    + `PROJECT_NAME = "Test Project"` 配置项目名称
    
    + `PROJECT_NUMBER = 1.0` 配置项目版本号
    
    + `OUTPUT_DIRECTORY = ./doxygen-output` 配置输出结果目录
    
    + `OPTIMIZE_OUTPUT_FOR_C = YES` 设置针对哪种语言进行优化
    
    + `EXTRACT_ALL = YES` 默认是 `NO`，即默认只对有标准注释的文件进行分析。如果我们希望对一个没有按照标准格式注释的项目进行分析，那么就要改为 `YES`，这在接手一个旧项目，分析代码时尤其有效。
    
    + `HAVE_DOT = YES` 设置 Doxygen 调用 dot 工具（graphviz 的一部分）
    
    + `DOT_PATH = /usr/local/graphviz` 指定 graphviz 的路径
        
3. 运行 Doxygen

        doxygen <config-file> 

    如果前一步没有指定配置文件的名字的话，直接运行 `doxygen` 即可。
    
    运行完之后，就可以在指定的输出目录中看到结果，用浏览器可以看到 HTML 版本的结果。
    
4. 按照 Doxygen 格式注释代码

    这一步应该在最前面，即先按照 Doxygen 风格格式注释好代码，然后再进行分析。官网上针对不同的编程语言，有详细的举例说明：[Documenting the code](http://www.stack.nl/~dimitri/doxygen/manual/docblocks.html#specialblock)

[doxygen]: http://www.stack.nl/~dimitri/doxygen/index.html
[getting started]: http://www.stack.nl/~dimitri/doxygen/manual/starting.html

<br>

最后展示一张我的效果图：

![image](/images/how-to-analysize-code-elegantly/result.png)

<br>

## Ref.

[linux doxygen 的安装和使用](http://blog.csdn.net/blood008/article/details/6567169)

[Doxygen][doxygen]

[Graphviz][graphviz]
