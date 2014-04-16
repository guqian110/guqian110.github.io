Title: 学习 Vim 使用 Vundle 管理插件
Date: 2014-04-16 17:06
Category: Linux
Tags: Linux,Vim
Slug: learning_vim_vundle
Author: Chien Gu
Summary: 学习 Vim，使用 Vundle 管理插件 。

学习 Vim，使用 Vundle 管理插件 。

<br>

## Vim 插件
* * *

Vim 的强大之处在于它的可扩展性，你可以把它当作一个简单的文本编辑器，也可以安装各种功能强大的插件，把它武装成一个 IDE 。

我们可以从以下几个地方找到 Vim 插件，一般比较常用的插件从官网上都可以找到，还有一些插件是大神们自己写的，托管在 GitHub 上 。

[Vim 官网][Vim-official]

[GitHub][GitHub]

[Vim-official]: http://www.vim.org/scripts/script_search_results.php
[GitHub]: https://github.com/

<br>

## 什么是 Vundle
* * *

Vim 的插件虽然强大，但是因为 Vim 根本就没有插件管理这个概念，所有插件的文件都散布在~/.vim下的几个文件夹中，配置 vim 的过程, 就是在网上不停的搜插件，拷贝到 `~/.vim` 下，发现更新，要重新下载重新拷贝，想要删除某个不需要插件，更是要小心翼翼的不要删错。配置出顺手的 Vim, 需要极大的耐心和运气，而且如果换一台电脑，就要重复一次这样的痛苦经历 。

自然地，因为管理插件的需求，最早出现了一些管理插件的脚本，但是写脚本需要一定的 shell 知识，直接 copy 别人的自己并不一定适用 。后来，出现了一些插件，比如 pathogen，muzuiget，vim-flavor，Vundle 等 。

目前比较流行的方式是采用 Vundle 来管理插件（别的我也没有试过...）

[Vundle on GitHub][vundle-github]

[Vundle on vim.org][vundle-vim-rog]

Vundle 的介绍：

> Vundle is short for Vim bundle and is a Vim plugin manager.

Vundle 可以在交互的方式下做到：

+ 在 `.vimrc` 中管理和配置插件

+ 安装插件

+ 更新插件

+ 按名字搜索插件

+ 删除插件

[vundle-github]: https://github.com/gmarik/Vundle.vim
[vundle-vim-rog]: http://www.vim.org/scripts/script.php?script_id=3458

<br>

## 如何使用 Vundle 管理插件
* * *

### 安装 Vundle

Vundle 的安装需要 [Git][Git] 。

从 GitHub 上 clone 下来就可以了

    git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

### 配置 Vundle

将下列内容加入到 `.vimrc` 文件中

    set nocompatible              " be iMproved, required
    filetype off                  " required

    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/vundle/
    call vundle#rc()
    " alternatively, pass a path where Vundle should install plugins
    "let path = '~/some/path/here'
    "call vundle#rc(path)

    " let Vundle manage Vundle, required
    Plugin 'gmarik/vundle'
    " The following are examples of different formats supported.
    
    " Keep Plugin commands between here and filetype plugin indent on.
    " scripts on GitHub repos
    Plugin 'tpope/vim-fugitive'
    Plugin 'Lokaltog/vim-easymotion'
    Plugin 'tpope/vim-rails.git'
    " The sparkup vim script is in a subdirectory of this repo called vim.
    " Pass the path to set the runtimepath properly.
    Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
    " scripts from http://vim-scripts.org/vim/scripts.html
    Plugin 'L9'
    Plugin 'FuzzyFinder'
    " scripts not on GitHub
    Plugin 'git://git.wincent.com/command-t.git'
    " git repos on your local machine (i.e. when working on your own plugin)
    Plugin 'file:///home/gmarik/path/to/plugin'
    " ...

    filetype plugin indent on     " required
    " To ignore plugin indent changes, instead use:
    "filetype plugin on
    "
    " Brief help
    " :PluginList          - list configured plugins
    " :PluginInstall(!)    - install (update) plugins
    " :PluginSearch(!) foo - search (or refresh cache first) for foo
    " :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
    "
    " see :h vundle for more details or wiki for FAQ
    " NOTE: comments after Plugin commands are not allowed.
    " Put your stuff after this line
    
从上面的配置文件中可以看到，Vundle 把插件分为了 3 类：

1. scripts on GitHub repos

    GitHub 上的脚本，需要按照 `usrname/repos` 的格式写出插件的名称

2. scripts from http://vim-scripts.org/vim/scripts.html 

    Vim scripts 上的脚本，不用作者名，直接写插件名

3. scripts not on GitHub

    不是 GitHub 上的脚本，需要写出插件的详细路径
    
### 运行 Vundle

修改好 `.vimrc` 文件后，打开 Vim，使用以下命令管理插件

+ 列表

        :Bundles    // 列出所有插件（包括未安装的）
        :BundleLIst // 列出已安装的插件
+ 安装

        :BundleInstall

+ 搜索

        :BundleSearch   // 后面不接插件名时，同 Bundles，列出了 4000 个插件

+ 更新

        :BundleInstall 

+ 删除

    在 `.vimrc` 文件中删除/注释掉相应的插件名，然后输入命令
    
        :BundleClean

<br>

** P.S. 我安装的插件**

列出一些我安装的插件，这些插件都是大家比较常用的，可以从相关的网站或者帮助文档中找到使用说明或者 `README`，计划在后续中写一写使用心得～

    Bundle 'taglist.vim'
    Bundle 'The-NERD-tree'
    Bundle 'SuperTab'
    Bundle 'snipMate'
    Bundle 'L9'
    Bundle 'FuzzyFinder'
    Bundle 'bufexplorer.zip'
    Bundle 'winmanager'
    Bundle 'a.vim'
    Bundle 'c.vim'
    Bundle 'Markdown'
    Bundle 'Conque-Shell'
    Bundle 'vimwiki'
    Bundle 'genutils'
    Bundle 'lookupfile'
    Bundle 'DoxygenToolkit.vim'
    "Bundle 'ManPageView'
    Bundle 'calendar.vim'
    Bundle 'AutoClose'
    "scripts on GitHub repos
    Bundle 'suan/vim-instant-markdown'
    Bundle 'godlygeek/tabular'


[Git]: http://git-scm.com/

<br>

## 参考

[vim中的杀手级插件: vundle](http://zuyunfei.com/2013/04/12/killer-plugin-of-vim-vundle/)

[Vundle 管理 Vim 插件](http://www.zfanw.com/blog/vundle-vim-plugin-management.html)
