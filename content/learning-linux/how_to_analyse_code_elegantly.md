Title: 如何优雅的分析代码
Date: 2015-01-11 18:49
Category: Linux
Tags: doxygen, code
Author: Qian Gu
Slug: how_to_analyse_code_elegantly
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

简而言之，Doxygen 是一个程序的文件产生工具，可将程序中的特定批注转换成为说明文件。只要我们在写注释的时候按照它制定的规则写，那么它就可以为我们生成漂亮的文档。

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

### Documenting the code

这部分虽然在最后，事实上应该是第一步，也就是说我们先按照规定添加 Doxygen 风格的注释，然后再配置、调用 Doxygen 来生成文档。[Doxygen 官网][doxygen]上有详细的注释[格式说明][documenting]，下面是我搬运来学习，自己翻译的。

我们在 C/C++ 风格注释块中加入一些特殊符号，这样 Doxygen 就知道需要把这段注释分析生成在文档中，这样的注释在官网中叫做 `Special comment blocks`。下面详细介绍类 C/C++ 语言（C/C++/C#/Objective-C/PHP/Java）的注释，其他语言（Python, VHDL, Fortran, Tcl）见官网。

对于代码中的任何实体（`entity`），都有两种注释，它们一起工作，完成注释功能，但至少得有一个：

+ `a brief description`：单行的简短注释

+ `a detailed description`：多行的详细注释

对于 方法 `methods` 和 函数 `functions`，还有额外的第三种注释：

+ `in body description`

对于详细注释（detailed description），可以用以下的几种风格来进行：

1. **JavaDoc Style**

    即在 C 风格注释块开始使用两个星号 `*`：
    
        /**
        * ... text ...
        */
        
2. **Qt Style**

    即在 C 风格注释块开始处添加一个叹号 `!`：
    
        /*!
        * ... text ...
        */
        
3. **A Third Alternative**

    使用连续两个以上的 C++ 注释行组成注释块，并且每行要多写一个 `/` 或者 `!`：

        ///
        /// ... text ...
        ///

    or
    
        //!
        //! ... text ...
        //!
        
4. 第四种格式，有的人喜欢让自己的注释更加醒目一些：

        /////////////////////////////////////////////////
        /// ... text ...
        /////////////////////////////////////////////////

对于简单注释（brief description），也有以下的几种方案：

1. 可以选用以上其中一种风格，然后加入 `\brief` 命令来标明 brief 的开始。这种方式以段落的结尾作为结束。所以在 brief 后要写 detailed 的话，需要空一行。

        /* \brief Brief description.
        *         Brief description continued.
        *
        *  Detailed description starts here.
        */
        
2. 如果选择 JavaDoc 的风格，并且在配置文件中设置 `JAVADOC_AUTOBRIEF = YES` 的话，Doxygen 会自动将第一句话作为 brief description，这个句子以 `. + 空格/空行` 结束。

        /** Brief description which ends at this dot. Details follow
        *   here.
        */

    这种方式对多行的 C++ 特殊注释风格也有效：
    
        /// Brief description which ends at this dot. Details follow
        /// here.
        
3. 第三种方法是使用不多于一行的特殊 C++ 风格注释，下面是两个例子：

        /// Brief description.
        /** Detailed description. */
        
    或者：（这种情况下，必须用空行把 brief 和 detailed 分开，同时 `JAVADOC_AUTOBRIEF = NO`）
    
        //! Brief description.
        
        //! Detailed description 
        //! starts here.
        
Doxygen 和其他的文档系统的一个不同之处就是它允许把注释写在实体的定义（包括全局函数）之前。这样，就可以把注释直接写在源文件里面而不是头文件中，从而使头文件更加紧凑，而且功能的实现人员也更容易阅读注释。**所以，一个折衷方案就是在声明前写 brief description，在定义前写 detailed description。**

#### Putting documentation after members

在注释结构体、类、枚举类型等时，有时习惯将注释写在代码的后面，而不是前面。因为 Doxygen 默认注释是解释后面的代码，所以这时候就需要在注释中添加一个额外的 `<` 来标明是注释前面的内容。

**example：**

Qt 风格的注释：

    int var; /*!< Detailed description after the member */
    
或者：

    int var; /**< Detailed description after the member */
    
或者：

    int var; //!< Detailed description after the member
             //!< 
    
一般来说，我们通常在后面添加的注释都是 brief description 而不是 detailed description，所以更常见的格式如下：

    int var; //!< Brief description after the member

或者：

    int var; ///< Brief description after the member

**Warning:**

这种添加 `<` 的方法只能用在 成员（`member`）和 参数（`parameter`）中，不能用在描述文件、类、联合体、名字空间和枚举本身。此外, 在后面提到的结构化命令（如`\class`）在这种注释段中是无效的。

#### Examples

官网上提供了一个例子，分别用 Qt 和 JavaDoc 的风格注释一段相同的 C++ 代码：

**Qt style:**

    #!C++
    //!  A test class. 
    /*!
      A more elaborate class description.
    */
    class Test
    {
      public:
        //! An enum.
        /*! More detailed enum description. */
        enum TEnum { 
                     TVal1, /*!< Enum value TVal1. */  
                     TVal2, /*!< Enum value TVal2. */  
                     TVal3  /*!< Enum value TVal3. */  
                   } 
             //! Enum pointer.
             /*! Details. */
             *enumPtr, 
             //! Enum variable.
             /*! Details. */
             enumVar;  
        
        //! A constructor.
        /*!
          A more elaborate description of the constructor.
        */
        Test();
        //! A destructor.
        /*!
          A more elaborate description of the destructor.
        */
       ~Test();
        
        //! A normal member taking two arguments and returning an integer value.
        /*!
          \param a an integer argument.
          \param s a constant character pointer.
          \return The test results
          \sa Test(), ~Test(), testMeToo() and publicVar()
        */
        int testMe(int a,const char *s);
           
        //! A pure virtual member.
        /*!
          \sa testMe()
          \param c1 the first argument.
          \param c2 the second argument.
        */
        virtual void testMeToo(char c1,char c2) = 0;
       
        //! A public variable.
        /*!
          Details.
        */
        int publicVar;
           
        //! A function variable.
        /*!
          Details.
        */
        int (*handler)(int a,int b);
    };
    
生成的 HTML 网页：http://www.stack.nl/~dimitri/doxygen/manual/examples/qtstyle/html/class_test.html

**JavaDoc style:**

    #!C++
    /**
     *  A test class. A more elaborate class description.
     */
    class Test
    {
      public:
        /** 
         * An enum.
         * More detailed enum description.
         */
        enum TEnum { 
              TVal1, /**< enum value TVal1. */  
              TVal2, /**< enum value TVal2. */  
              TVal3  /**< enum value TVal3. */  
             } 
           *enumPtr, /**< enum pointer. Details. */
           enumVar;  /**< enum variable. Details. */
           
          /**
           * A constructor.
           * A more elaborate description of the constructor.
           */
          Test();
          /**
           * A destructor.
           * A more elaborate description of the destructor.
           */
         ~Test();
        
          /**
           * a normal member taking two arguments and returning an integer value.
           * @param a an integer argument.
           * @param s a constant character pointer.
           * @see Test()
           * @see ~Test()
           * @see testMeToo()
           * @see publicVar()
           * @return The test results
           */
           int testMe(int a,const char *s);
           
          /**
           * A pure virtual member.
           * @see testMe()
           * @param c1 the first argument.
           * @param c2 the second argument.
           */
           virtual void testMeToo(char c1,char c2) = 0;
       
          /** 
           * a public variable.
           * Details.
           */
           int publicVar;
           
          /**
           * a function variable.
           * Details.
           */
           int (*handler)(int a,int b);
    };

生成的 HTML 网页：http://www.stack.nl/~dimitri/doxygen/manual/examples/jdstyle/html/class_test.html

#### Documentation at other places

我们之前的例子中注释都是在文件、命名空间、类的声明或者定义之前，或者在它们的成员的前/后。虽然一般来说这是很正常的，但是有时候我们需要把代码写在在文档的其他地方。对于文件的注释更是如此，因为对于文件来说，根本就不存在在它之前的地方（"in front of a file"）。

Doxygen 允许你把注释写在任何地方（例外情况是在函数体内 or 在 C 风格注释块内）。你需要付出的代价就是要在注释块内部多写一些结构化命令（`structural command`）来标明。所以，**一般来说，我们应该尽量避免使用结构化命令，除非是有其他的特殊要求这样做。**

结构化命令以一个 `\` 或者 `@`（JavaDoc 风格）开始，后面接一个命令名字 + 一个（多个）参数。举例如下：

    /*! \class Test
        \brief A test class.
        
        A more detailed class description.
    */
    
这个例子中的 `\class` 指示这个注释块中包含一个 Test 类的文档。其他常用的命名如下：

+ `\structure`

+ `\union`
    
+ `emun`

+ `fn`

+ `var`

+ `def`

+ `\typedef`

+ `\file`

+ `\namespace`

+ `\package`

+ `\interface`

完整的命令和说明在这里：[special commands][sm]

对 C++ 类成员进行注释的时候，必须先注释这个类，对于命名空间来说也是如此。对 C 的全局函数、 typedef、enum、 preprocessor definition 进行注释，必须先注释包含它们的文件（通常是头文件）。

**Attention:**

在重复一下容易出错的地方：**在注释全局对象时，必须先注释它们所在的文件。**也就是说，必须包含以下两者之一：

    /* \file */
    
或者

    /* @file */

下面是官网上的一个 C 头文件的例子：

    #!C
    /*! \file structcmd.h
    \brief A Documented file.
    
        Details.
    */
    /*! \def MAX(a,b)
        \brief A macro that returns the maximum of \a a and \a b.
       
        Details.
    */
    /*! \var typedef unsigned int UINT32
        \brief A type definition for a .
        
        Details.
    */
    /*! \var int errno
        \brief Contains the last error code.
        \warning Not thread safe!
    */
    /*! \fn int open(const char *pathname,int flags)
        \brief Opens a file descriptor.
        \param pathname The name of the descriptor.
        \param flags Opening flags.
    */
    /*! \fn int close(int fd)
        \brief Closes the file descriptor \a fd.
        \param fd The descriptor to close.
    */
    /*! \fn size_t write(int fd,const char *buf, size_t count)
        \brief Writes \a count bytes from \a buf to the filedescriptor \a fd.
        \param fd The descriptor to write to.
        \param buf The data buffer to write.
        \param count The number of bytes to write.
    */
    /*! \fn int read(int fd,char *buf,size_t count)
        \brief Read bytes from a file descriptor.
        \param fd The descriptor to read from.
        \param buf The buffer to read into.
        \param count The number of bytes to read.
    */
    #define MAX(a,b) (((a)>(b))?(a):(b))
    typedef unsigned int UINT32;
    int errno;
    int open(const char *,int);
    int close(int);
    size_t write(int,const char *, size_t);
    int read(int,char *,size_t);

上面这个例子中的每个注释块都包含了一条结构化命令，所以这些注释可以放在文件的其他位置或者放在其他文件中，不会影响到最终生成的文档。这种方法的坏处在于我们实际上写了两遍原型，当做修改时我们必须同时修改代码和注释。因此，我们在使用前应该仔细考虑是否真的需要结构化命令，并且尽可能避免使用它。一个常见的现象就是在函数前的注释块中包含了 `\fn` 命令，显然这是冗余的，除了导致错误，这个命令毫无作用。

如果我们对以 .dox, .txt, .doc 结尾的文件注释，那么 Doxygen 会自动忽略这些文件。

如果我们有一个 Doxygen 无法解析的文件，但是仍然像注释它，那么就使用 `\verbinclude` 这个命令：

    /*! \file myscript.sh
    *   Look at this nice srcipt.
    *  \verbinlcude mycript.sh
    */
    
还要确定在配置文件中 `INPUT` 变量显式地说明这个脚本文件，或者 `FILE_PATTERNS` 变量必须包含`.sh` 文件扩展名并且可以通过 `EXAMPLE_PATH` 变量寻找到这个文件。

#### Anatomy of a comment block

前面介绍了如何对代码进行注释，并且讨论了两种不同的注释：brief 和 detailed，还讨论了如何使用结构化命令。

下面我们分析注释块本身。

Doxygen 支持很多种格式的注释，最简单的就是文本文件，适用于比较短的注释。对于比较长的注释，我们需要清单、表格等更加结构化的元素，对于这种情况，Doxygen 支持 Markdown 语法，可以直接读取 Markdown 文件，详细内容看这里：[Markdown Support][ms]。

(Markdown 源自邮件的文本格式，语法非常简洁，并且功能很强大，这篇文章本书就是用 Markdown 语法写的，语法细节见官网，这里不再赘述。)

P.S.

找到一篇博客，详细介绍了基于 Doxygen 的 C++ 注释风格：[C++标准注释原则 - 基于doxygen的C++注释][blog1]

[documenting]: http://www.stack.nl/~dimitri/doxygen/manual/docblocks.html
[sm]: http://www.stack.nl/~dimitri/doxygen/manual/commands.html
[ms]: http://www.stack.nl/~dimitri/doxygen/manual/markdown.html
[blog1]: http://blog.csdn.net/czyt1988/article/details/8901191

<br>

最后展示一张我的效果图：

![image](/images/how-to-analysize-code-elegantly/result.png)

<br>

## Ref.

[linux doxygen 的安装和使用](http://blog.csdn.net/blood008/article/details/6567169)

[Doxygen][doxygen]

[Graphviz][graphviz]

[doxygen 使用简介（C,C++为代码作注释）](http://www.cnblogs.com/wishma/archive/2008/07/24/1250339.html)
