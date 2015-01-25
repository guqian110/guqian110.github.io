Title: 学习 Vim 之 Ctags/Cscope/Taglist
Slug: learning_vim_ctags_cscope_taglist
Date: 2015-01-25 21:32
Category: Linux
Tags: vim, ctags, cscope, taglist
Author: Qian Gu
Summary: 总结使用 Ctags/Cscope/Taglist 的使用方法。

## Background
* * *

tags 文件是一种非常有用的文件，本文的内容都是基于 `tag` 的，所以首先得了解什么是 tag？

Vim Manual 里面的简单介绍就足够我们进行下面的内容了。查看 Manual：

    :help tagsrch

使用 tags 文件的步骤：

1. 首先使用 tag 工具（ctags、cscope等）生成 tags 文件

2. 其次，将 tags 文件路径导入到 Vim 中，让 Vim 知道从哪个 tags 文件中查找。

3. 最后，使用 Vim 的命令查找 tag。

<br>

## Ctags
* * *

### Intro

[Ctags 官网][ctags]

[wiki](http://en.wikipedia.org/wiki/Ctags)

> **Ctags** is a programming tool that generates an index (or tag) file of names found in source and header files of various programming languages. Depending on the language, functions, variables, class members, macros and so on may be indexed. These tags allow definitions to be quickly and easily located by a text editor or other utility. Alternatively, there is also an output mode that generates a cross reference file, listing information about various names found in a set of language files in human-readable form.

manpage: 

    man ctags

vim Manual：

    :help 29.1
    :help ctags

简而言之，Ctags 是一个可以自动提取源文件和头文件中函数、变量、类成员、宏定义等元素的工具，然后它会建立一个 tags 文件，其他编辑器（比如我们使用的 Vim）可以读取这个 tags 文件，从而快速定位代码的位置。

使用 `ctags --list-language` 可以查看 ctags 支持的语言，使用 `ctags --list-maps` 可以查看哪些后缀名对应对应的语言。

### Install

ctags 是 Unix 系统自带的一个工具，但是功能比较少，所以一般使用 Exuberant Ctags。在 Linux 上，Exuberant Ctags 是默认的 Ctags 程序。如果系统中没有安装的话，我们可以从官网上下载源码编译安装，或者直接 apt-get 安装。

    sudo apt-get install exuberant-ctags

### Config

我们要使用 tags，第一步就是生成 tags 文件。生成 tags 文件时，ex-ctags 提供了很多参数供我们控制生成结果，详细内容可以查看其 manpage，这里有 easwy 大神翻译的中文版：

[Exuberant Ctags中文手册][blog1]

我们可以将配置写在 .vimrc 中：

     set tags =tags;
     map <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

这样，我们只需要按 Ctrl-F12 即可自动生成 C++ 项目的 tags 文件。

### Usage

Vim 提供了接口可以调用 tags 文件，它使用一个栈来记录我们在文件中跳转的位置。ctags 其 manual page 中有说明如何在 Vi 中使用 ctags：

1. `vi -t tags` 打开 vi，并且将光标停留在 `tag` 定义的地方

2. `:ta tag` 寻找 `tag`

3. `Ctrl-]` 寻找光标处 tag 的定义

4. `Ctrl-T` 返回到 tag 的前一个位置

5. `tnext` 如果某个 tag（比如函数）有多次定义，会匹配到多个结果，本命令跳到下一个结果。

6. `tprevious` 同上，跳转到前一个匹配结果

7. `tfirst` 跳转到第一个匹配结果

8. `tlast` 跳转到最后一个匹配结果

9. `:ts tag` 同上，列出所有匹配到 tag 的结果

10. `:tags` 显示 tagstack 中的内容，即我们的跳转记录

[ctags]:ctags.sourceforge.net/
[blog1]:http://easwy.com/blog/archives/exuberant-ctags-chinese-manual/

<br>

## Cscope
* * *

### Intro

[Cscope 官网][cscope]

[cscope wiki][cscope wiki]:

> cscope is a console mode or text-based graphical interface that allows computer programmers or software developers to search C source code (there is limited support for other languages). It is often used on very large projects to find source code, functions, declarations, definitions and regular expressions given a text string. cscope is free and available under a BSD License. The original developer of cscope is Joe Steffen.

man page:

    man cscope

Vim help:

    :help if_cscop

The following text is taken from a version of the cscope man page:

>  Cscope is an interactive screen-oriented tool that helps you:
>
>  + Learn how a C program works without endless flipping through a thick listing.
>
>  + Locate the section of code to change to fix a bug without having to learn the entire program.
>
>  + Examine the effect of a proposed change such as adding a value to an enum variable.
>
>  + Verify that a change has been made in all source files such as adding an argument to an existing function.
>
>  + Rename a global variable in all source files.
>
>  + Change a constant to a preprocessor symbol in selected lines of files.
>
>  It is designed to answer questions like:
>
>  + Where is this symbol used?
> 
>  + Where is it defined?
> 
>  + Where did this variable get its value?
>
>  + What is this global symbol's definition?
> 
>  + Where is this function in the source files?
> 
>  + What functions call this function?
> 
>  + What functions are called by this function?
> 
>  + Where does the message "out of space" come from?
> 
>  + Where is this source file in the directory structure?
>
>  + What files include this header file?
>
>  Cscope answers these questions from a symbol database that it builds the
>  first time it is used on the source files.  On a subsequent call, cscope
>  rebuilds the database only if a source file has changed or the list of
>  source files is different.  When the database is rebuilt the data for the
>  unchanged files is copied from the old database, which makes rebuilding
>  much faster than the initial build.

简而言之，就是 ctags 的加强版，ctags 只能让我们跳转到某个 tag 的定义之处，但是无法让我们知道这个 tag 还在哪里出现过，或者被哪个函数调用过，这时候就需要 cscope 来大显身手了～

**P.S.**

cscope 对 C/C++ 支持比较好，当然我们也可以自己定制来支持其他语言，比如 Java，Python 等。

### Install

    sudo apt-get install cscope

### Usage

联合使用 Cscope + Vim 的流程：

1. 使用 cscope 生成数据库文件

        cscope -Rbkq

    其中参数的含义：

    + -R 递归，对子目录也建立数据库

    + -b 只生成数据库，不进入 scope 界面

    + -k 生成数据库时，不搜索 `/usr/include` 目录

    + -q 生成 `cscope.in.out` 和 `cscope.po.out` 文件，加快查找速度

    更详细的参数见 man page。

2. 将数据库导入 Vim 中

    cd 到源文件目录下，执行上一步操作，然后打开 vim 输入下面的命令：

        ：cs add ./cscope

3. 在 Vim 中查找

    通用格式为 `:cs find -option label`。

    option 可以有很多种模式，在 Vim 中使用 `:help cscope-find` 来查看 option：

		0 or s: Find this C symbol
		1 or g: Find this definition
		2 or d: Find functions called by this function
		3 or c: Find functions calling this function
		4 or t: Find this text string
		6 or e: Find this egrep pattern
		7 or f: Find this file
		8 or i: Find files #including this file

### Config

Vim 的 cscope 接口提供了一些参数，可以让我们更加灵活地使用 cscope，可以用 `help if_cscop` 来查看完整的说明，这里有一份前辈翻译的中文版

[Cscope的使用（领略Vim + Cscope的强大魅力）][blog2]

下面我找了几个常用的选项：

1. cscopequickfix

    vim 提供了 `cscopequickfix` 选项，让查找结果在 quickfix 的窗口显示。

2. 同时使用 cscope ctags 

    设置 `cst` 选项，可以同时查找 cscope 和 ctags，查找顺序有 `csto` 选项来决定。

3. `:ctags` 等同于 `:cs find g`

为了省事，我们可以将一些参数设置写在 .vimrc 文件中，Vim help 中有推荐设置，下面是我修改过的配置：

	if has("cscope")
		set csprg=/usr/bin/cscope
	    set cscopequickfix=s-,c-,d-,i-,t-,e-
		"set cst "keep the regular tag behavior
		"set csto=0 "keep the regular tag behavior
		set nocsverb
		" add any database in current directory
		if filereadable("cscope.out")
		    cs add cscope.out
		" else add database pointed to by environment
		elseif $CSCOPE_DB != ""
		    cs add $CSCOPE_DB
		endif
		set csverb
	endif

	nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
	nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
	nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>

	" Using 'CTRL-spacebar' then a search type makes the vim window
	" split horizontally, with search result displayed in
	" the new window.

	nmap <C-Space>s :scs find s <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space>g :scs find g <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space>c :scs find c <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space>t :scs find t <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space>e :scs find e <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
	nmap <C-Space>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nmap <C-Space>d :scs find d <C-R>=expand("<cword>")<CR><CR>

	" Hitting CTRL-space *twice* before the search type does a vertical
	" split instead of a horizontal one

	nmap <C-Space><C-Space>s
		\:vert scs find s <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space><C-Space>g
		\:vert scs find g <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space><C-Space>c
		\:vert scs find c <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space><C-Space>t
		\:vert scs find t <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space><C-Space>e
		\:vert scs find e <C-R>=expand("<cword>")<CR><CR>
	nmap <C-Space><C-Space>i
		\:vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nmap <C-Space><C-Space>d
		\:vert scs find d <C-R>=expand("<cword>")<CR><CR>

[cscope]: http://cscope.sourceforge.net/
[cscope wiki]: http://en.wikipedia.org/wiki/Cscope
[blog2]: http://blog.csdn.net/dengxiayehu/article/details/6330200

<br>

## Taglist
* * *

### Intro

[Taglist 官网][taglist]

使用过 VS 的人都知道，在左侧有一个窗口专门显示当前代码文件中的宏、函数、变量定义，并且随着文件切换自动更新。我们这里介绍的 Taglist 完成的就是类似的功能，让我们可以高效地浏览代码。不过要使用 Taglist，首先要安装前面介绍的 Ctags。

> The "Tag List" plugin is a source code browser plugin for Vim and provides an overview of the structure of source code files and allows 
you to efficiently browse through source code files for different programming languages. 

### Install

与前面的 ctags、cscope 不同的是，taglist 是一款 Vim 插件。如果使用 Vundle 来管理、安装插件，在 .vimrc 中添加

    Bundle 'taglist.vim'

然后打开 vi，然后输入命令 `:BundleInstall` 即可。

### Config

使用 `:help taglist` 查看帮助。

使用 `:TlistToggle` 切换是否显示 Taglist 窗口。

我们可以直接在 .vimrc 中添加以下设置：

    let Tlist_Show_One_File=1
    let Tlist_Exit_OnlyWindow=1
    let Tlist_SHow_Menu=1
    let Tlist_File_Fold_Auto_Close=1

### Usage

在 taglist 窗口，我们可以使用下面的一些快捷键：

+ `=` 折叠所有 tag

+ `-` 折叠单个 tag

+ `+` 打开一个折叠

+ `x` taglist 窗口放大/缩小，方便查看 tag

+ `u` 更新 taglist

+ `sapce` 显示光标处 tag 的原型定义

**P.S.**

配合另外一个窗口管理插件 winmanager，我们可以将我们的 Vim 打造成一个伪 IDE :D

[taglist]: http://www.vim.org/scripts/script.php?script_id=273

<br>

## Ref

[ctags的使用及相关参数介绍](http://blog.csdn.net/alexdboy/article/details/3871707)

[Exuberant Ctags中文手册][blog1]

[vi/vim使用进阶: 使用标签(tag)文件](http://easwy.com/blog/archives/advanced-vim-skills-use-ctags-tag-file/)

[cscope 官网][cscope]

[cscope wiki][cscope wiki]

[Cscope的使用（领略Vim + Cscope的强大魅力）][blog2]

[Taglist 官网][taglist]

[vi/vim使用进阶: 使用taglist插件](http://easwy.com/blog/archives/advanced-vim-skills-taglist-plugin/)
