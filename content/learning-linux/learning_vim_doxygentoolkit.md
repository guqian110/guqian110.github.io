Title: 学习 Vim 插件 DoxygenToolKit.vim
Date: 2015-01-12 15:21
Category: Linux
Tags: Linux, Vim, DoxygenToolKit
Slug: learning_vim_doxygentoolkit
Author: Qian Gu
Summary: 学习 Vim 插件 DoxygenToolKit

前面一篇博客已经介绍过 Doxygen 了，Doxygen 的确是一个非常给力的工具，但是为了生存文档，我们必须在注释上花费很大的时间和精力。

那么问题又来了：**如何才能既享受 Doxygen 的强大功能，同时又避免大量的重复性的注释内容？**

解决思路： 让编辑器来替我们写那些格式和内容固定的部分，我们只负责写真正的有效内容。

所以，答案就是：**Vim + DoxygenToolKit.vim 插件**

<br>

## DoxygenToolKit
* * *

DoxygenToolKit 是 Vim 的一款插件，用它可以很方便地添加 Doxygen 风格的注释，可以节省大量时间和精力，提高写代码的效率。

[DoxygenToolKit Official Website][official] 官网上介绍，目前定义了 5 个功能：

> + Generates a doxygen license comment.  The tag text is configurable. 

> + Generates a doxygen author skeleton.  The tag text is configurable. 

> + Generates a doxygen comment skeleton for a C, C++ or Python function or class, including @brief, @param (for each named argument), and @return. The tag  text as well as a comment block header and footer are configurable. (Consequently, you can have \brief, etc. if you wish, with little effort.) 

> + Ignore code fragment placed in a block defined by #ifdef ... #endif (C/C++).  The  block name must be given to the function. All of the corresponding blocks 
in all the file will be treated and placed in a new block DOX_SKIP_BLOCK (or any other name that you have configured).  Then you have to update PREDEFINED value in your doxygen configuration file with correct block name. You also have to set ENABLE_PREPROCESSING to YES. 

> + Generate a doxygen group (begining and ending). The tag text is configurable. 

### Installation

如果我们使用 Vundle 管理插件，安装步骤就非常简单了：

1. 在 Vundle 中加入：

        Bundle 'DoxygenToolkit.vim'
        
2. 打开 Vim，输入命令：

        :BundleInstall
        
Vundle 会自动完成安装 :-D

### Configuration for c++

我们有两种方法可以修改设置，方法一是直接在 DoxygenToolKit.vim 脚本文件中修改相关变量；方法二是在 ~/.vimrc 里面修改。显然方法二更加好一点，因为如果用方法一直接改原脚本，可能还得保存备份才能恢复默认值。

因为平时写的 C++ 程序比较多，所以针对[基于 Doxygen 的 C++ 注释风格][blog1]，我们需要进行以下几步：

1. 在 .vimrc 中我特别配置了以下命令：

        let g:DoxygenToolKit_briefTag_pre = "\brief "
        let g:DoxygenToolKit_paramTag_pre = "\param "
        let g:DoxygenToolKit_returnTag = "\return "
        let g:DoxygenToolKit_briefTag_funcName = "yes "
        let g:DoxygenToolKit_authorName = "Qian Gu guqian110@gmail.com"
        let g:DoxygenToolKit_commentType = "C++ "
        let g:doxygen_enhanced_color = 1

2. 即使前一步中设置了 C++ 风格，但是生成的 Lisence 仍然是 `//`，而不是我们想要的 `///`，所以我们还需要修改原脚本（line 362~363）为：

        let g:DoxygenToolKit_startCommentBlock = "/// "
        let g:DoxygenToolKit_interCommentBlock = "/// "

3. 最后一步，结构命令的开头提示符默认设置是使用 `@`，而 C++ 风格是使用`\`，为了避免大范围改动原脚本，只能手动替换了

        :%s/@/\


### Usage

官网上也给出了使用方法：

+ License

    将光标放在需要生成 License 的地方，然后输入命令 `:DoxLic`
    
+ Author

    将光标放在合适的地方，然后输入命令 `:DoxAuthor`

+ Function / Class

    将光标放在 function 或者 class 的名字所在的一行，然后输入命令 `:Dox`

+ Ignore code fragment (C/C++ Only)

    如果想忽略调试部分的代码，那么只需要执行命令 `:DoxUndoc(DEBUG)` 即可

+ Group

    输入命令 `DoxBlock` 来插入一个注释块

为了方便使用，我们可以自定义一些 map，省去输入命令的繁琐。

### Example

同样是官网上的例子：

假设有个函数如下

    #!C++
    int 
    foo(char mychar, 
        int myint, 
        double* myarray, 
        int mask = DEFAULT) 
    { //... 
    } 

那么执行 `:Dox` 命令之后会生成以下内容

    #!C++
    /** 
    * @brief 
    * 
    * @param mychar 
    * @param myint 
    * @param myarray 
    * @param mask 
    * 
    * @return 
    */ 

[official]: http://www.vim.org/scripts/script.php?script_id=987

<br>

## Ref

[DoxygenToolKit.vim][official]
[blog1]: 
