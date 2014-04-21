Title: 学习 Vim 保存项目设置 
Date: 2014-04-20 14:32
Category: Linux
Tags: Linux,Vim
Slug: learning_vim_save_project_configuration
Author: Chien Gu
Summary: 总结将 Vim 配置为 IDE 的过程之一，保存项目设置 。

> + 关于 Vim 和 IDE 的争论，这是程序猿的圣战，不再浪费时间 :-D

> + 在参考了很多人分享的博客和教程之后，终于把 Vim 搭建成为一个自己定制的 IDE（这种说法严格意义上说，是不对的，应该是 “组合一组工具成为一个 IDE ”），总结一下～

> + 本系列的内容很多都是参考别人的博客写的，也包含部分自己摸索的结果 。虽然部分内容和参考文章相同，但是总结一下自己的学习过程还是一件有必要的事 :-P

<br>

很多编辑器都有一个功能是以前打开过的文档会有记忆，再次打开时会直接跳转到上次编辑的地方，比如  [`Sublime Text 2`][sb2]，强大的 Vim 当然也有这个功能，**我们的目标就是让 VIm 和其他 IDE 一样，可以记住上次的编辑状态 。**

Vim 要实现这个功能，涉及到两个地方的配置：`session` & `viminfo` 。

[sb2]: http://www.sublimetext.com/2

<br>

## Session
* * *
### 查看 session 介绍

在 Vim 中输入

    :help session

就可以看到关于 `session` 的介绍：

> A Session keeps the Views for all windows, plus the global settings.  You can save a Session and when you restore it later the window layout looks the same. You can use a Session to quickly switch between different projects, automatically loading the files you were last working on in that project.

在我使用的 Vim 7.3 中， `help` 中的 `usr_21.txt` 的主题是 ` Go away and come back`，其中 `21.4`  节保存的就是关于 session 的说明，在 Vim 中输入

    :help 21.4

就可以看到关于 session 的详细介绍 。

### 配置 session

Session 保存的信息由 `sessionoptions` 确定，详细用法可以查看 help

    :help 'sessionoption'

> + 'sessionoptions' 'ssop' string  (default: **"blank,buffers,curdir,folds,help,options,tabpages,winsize"**)

> + It is a comma separated list of words.  Each word enables saving and restoring something

也就是说 session 保存的会话的属性默认的有 8 个 ：**当前编辑的空窗口、缓冲区、当前目录、折叠信息、帮助信息、选项、标签页、窗口大小信息 。**

在上面的设置中，不要同时包含 `curdir` 和 `sesdir` 两个选项，若两个选项都不包含，则保存 session 时，会保存绝路径 。添加 `sesdir` 可以将当前目录设置为 `session-file`  所在的目录，这个设置有个很有用的地方就是，当我们通过网络访问我们的工程或者有很多个工程版本，这时候只需要每个工程下保存一个 session-file 即可 。

删除/加入 某个选项的方法

    :set sessionoptions-=curdir
    :set sessionoptions+=sesdir

### 保存 session 文件

详细的语法可以在 help 中查看

    :help mksession

使用 `mksession` 命令保存会话

    :set sessionoptopms-=curdir
    :set sessionoptions+=sesdir
    :mksession project.vim
    
如果 session-file 已经存在，则使用

    :mksession! project.vim

### 载入 session 文件

然后退出 Vim，在别的目录下打开，干点别的事，这时候我们想起刚才的工程里面有个小 bug，想恢复过去，这时候就是只需要使用 `source` 命令即可 。

使用 `source` 命令

    source PATHto/project.vim
    
这时候可以看到，已经恢复了之前的状态 。

<br>

*只使用 session 就可以恢复一些上次编辑的信息，但是这还不够，我们还可以配合使用 `viminfo` 来恢复更多的信息 。在 Vim 的 `:help 21.4` 中有介绍两者的关系*

> + **Sessions store many things, but not the position of marks, contents of registers and the command line history.**  You need to use the viminfo feature for these things.
> + In most situations you will want to use sessions separately from viminfo. This can be used to switch to another session, but keep the command line history.  And yank text into registers in one session, and paste it back in another session.
> + You might prefer to keep the info with the session.  You will have to do this yourself then.
> + You could also use a Session file.  **The difference is that the viminfo file does not depend on what you are working on.**  There normally is only one viminfo file.  Session files are used to save the state of a specific editing Session.  You could have several Session files, one for each project you are working on.  Viminfo and Session files together can be used to effectively
enter Vim and directly start working in your desired setup.

<br>

## Viminfo
* * *

### 查看 viminfo 介绍

在 Vim 中输入

    :help viminfo

就可以看到关于 `viminfo` 的介绍：

> If you exit Vim and later start it again, you would normally lose a lot of information.  The viminfo file can be used to remember that information, which enables you to continue where you left off.

在 Vim 7.3 中， `help` 中的 `usr_21.txt` 的主题是 ` Go away and come back`，其中 `21.3`  节保存的就是关于 viminfo 的说明，在 Vim 中输入

    :help 21.3

就可以看到关于 viminfo 的详细介绍 。

viminfo 文件可以保存的内容有：

+ The command line history 命令行历史
+ The search string history 字符串搜寻历史
+ The input-line history 输入行历史
+ Contents of non-empty register 非空寄存器内容
+ Marks for serval files 文件位置标记
+ Last search/substitute pattern 最近模式匹配搜索历史
+ The buffer list 缓冲区列表
+ Global variables 全局变量

### 保存 viminfo 文件

其实 Vim 每次退出时都会在 `～/` 目录下保存一个 `.viminfo` 的文件，但是每次打开关闭一个文件都会覆盖上次的记录，所以我们需要为工程手动保存一个 viminfo 文件，并且保存在工程目录下，防止被覆盖 。

保存命令 `:wviminfo` 的帮助

    :help :wviminfo

使用 `wviminfo` 保存

    :wviminfo project.viminfo

### 载入 viminfo 文件

载入命令 `rviminfo` 帮助

    :help :rviminfo

载入 viminfo 文件

    :rviminfo path/to/project.viminfo

<br>

## 总结

为了节省每次都要手动输入一些设置命令，我们可以把部分相同的设置放在 `.vimrc` 文件中

    set sessionoptions-=curdir
    set sessionoptions+=sesdir

每次退出 Vim 是保存

    :mksession project.vim
    :wviminfo project.viminfo

进入 Vim 想恢复项目设置时

    :source projetc.vim
    :rviminfo projetc.viminfo
    
<br>

## 参考

[vi/vim使用进阶: 使用会话和viminfo](http://easwy.com/blog/archives/advanced-vim-skills-session-file-and-viminfo/)

[vi/vim使用进阶: 保存项目相关配置](http://easwy.com/blog/archives/advanced-vim-skills-save-project-configuration/)
