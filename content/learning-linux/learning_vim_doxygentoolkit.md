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

### Configuration

DoxygenToolKit 的配置由脚本文件的 `g:DoxygenToolkit_*` 变量决定，我们可以在 `.vimrc` 文件中修改这些参数，根据自己的情况修改自定义。

作者给出了自己的一些设置，我修改过之后：

    let g:DoxygenToolKit_briefTag_pre = "@Brief "
    let g:DoxygenToolKit_paramTag_pre = "@Param "
    let g:DoxygenToolKit_returnTag = "@Returns "
    let g:DoxygenToolKit_briefTag_funcName = "yes "
    let g:DoxygenToolKit_authorName = "Qian Gu guqian110@gmail.com"
    let g:DoxygenToolKit_commentType = "C++ "
    let g:doxygen_enhanced_color = 1

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
