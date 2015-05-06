Title: 学习 Vim 之 vim_signature 插件 
Date: 2015-05-06 10:37
Category: Linux
Tags: Vim, vim_signature
Slug: learning_vim_signature_plugin
Author: Qian Gu
Summary: 学习 vim 书签的基本知识和 vim_signature 插件的使用方法

在追踪代码时，经常跳转到很多新文件中，想回到原点时就比较麻烦了，这时候就需要 “书签” 了。

<br>

## Bookmarks
* * *

用 `:help marks` 来查看关于书签的说明：

书签可以分为 3 类：

1. lowercase marks

    书签名只能为 'a - 'z，只在所在文件内有效，不能在文件之间跳转，不同书签名不能包含有相同字符

2. uppercase  marks

    书签名只能为 'A - 'Z，也叫文件书签，可以在文件之间跳转，不同书签名不能包含有相同字符

3. numbered marks

    书签名只能为 '0 - '9，用 `.viminfor` 文件来设置

使用字母 a-zA-Z 建立的书签能被保存下来，再次打开时仍然存在，而用数字 0-9 建立的书签在关闭文件后就被删除了，不能恢复，所以 一般使用 a-zA-Z 更多一点吧。

知道这些最基本的东西就可以顺利使用书签了。

**P.S.**

help 文档中说 numbered marks 不能手动设置，实际上是可以的，不知道是不是我理解错了，不过这个应该不影响平常的使用。

### Usage

常用的几个 Vim 内置的书签命令如下：

1. 设置书签 `m{a-zA-Z}`，如 ma

2. 删除书签 `delm {marks}`，如 delm a

3. 跳转书签

    跳转有两种方式：

    + 使用 backtick 键（数字 1 键左边），跳转到设置书签时光标所在的行和列，如 `a

    + 使用单引号 `'`，跳转到书签所在行的第一个非空字符处（不包含列信息），如 'a

    + `` 回到到上次修改的位置

4. 列出所有书签 `:marks`

<br>

## Vim-signature
* * *

使用 Vim 书签时，最大的不方便之处是：书签是不可见的，也就是说我们输入命令之后，是无法看到书签是否建立成功了，外观上是看不出书签行和普通行的区别的。还好有个很不错的插件 [vim-signature][vim-signature] 可以帮助我们实现可视化的书签。

在 github 项目上有这个插件的简单介绍，另外在 Vim 中也可以看 help 文档查阅详细帮助，这里只记录我用到简单配置。

### Install

使用这个插件需要 vim 支持 sign 特性，使用命令 `:echo has('signs')` 来查看 vim 是否支持这个特性，如果结果是 1，则支持，如果结果是 0，需要重新编译 vim。

使用 Vundle 安装：

    Bundle 'vim-signature'

### Usage

使用 `:help signature` 可以查看帮助文档。
    
    mx           Toggle mark 'x' and display it in the leftmost column
    dmx          Remove mark 'x' where x is a-zA-Z
    
    m,           Place the next available mark
    m.           If no mark on line, place the next available mark. Otherwise, remove (first)     existing mark.
    m-           Delete all marks from the current line
    m<Space>     Delete all marks from the current buffer
    ]`           Jump to next mark
    [`           Jump to prev mark
    ]'           Jump to start of next line containing a mark
    ['           Jump to start of prev line containing a mark
    `]           Jump by alphabetical order to next mark
    `[           Jump by alphabetical order to prev mark
    ']           Jump by alphabetical order to start of next line having a mark
    '[           Jump by alphabetical order to start of prev line having a mark
    m/           Open location list and display marks from current buffer
    
    m[0-9]       Toggle the corresponding marker !@#$%^&*()
    m<S-[0-9]>   Remove all markers of the same type
    ]-           Jump to next line having a marker of the same type
    [-           Jump to prev line having a marker of the same type
    ]=           Jump to next line having a marker of any type
    [=           Jump to prev line having a marker of any type
    m?           Open location list and display markers from current buffer
    m<BS>        Remove all markers

而且 help 中列出了具体配置，我们可以对其修改，自定义快捷键。总结一下我常用的操作：

1. 设置书签 `mx`，比如 ma

2. 删除书签

    + 直接在目标行重新输入 `mx`，旧书签就会被删除，并且设定到光标所在行

    + 将光标移动到旧书签行，重新输入 `mx`

    + 删除所有 lowercase + uppercase marks，`m<Space>`

    + 删除所有 numbered marks，`m<BS>`

3. 跳转书签

    + ]`，跳转到前一个书签

    + [`，跳转到后一个书签

    + ]-，跳转到之前同一类型的 numbered marks 书签行

    + [-，跳转到之后同一类型的 numbered marks 书签行

[vim-signature]: https://github.com/kshenoy/vim-signature

<br>

## Ref

[vim-signature][vim-signature]

[像 IDE 一样使用 Vim](http://www.tuicool.com/articles/f6feae)