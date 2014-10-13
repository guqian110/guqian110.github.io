Title: 学习 Vim 初步配置 Vim
Date: 2014-04-16 12:44
Category: Linux
Tags: Linux,Vim
Slug: learning_vim_vimrc_preliminary
Author: Chien Gu
Summary: 总结初步配置 Vim，让 Vim 更顺手 。

总结初步配置 Vim，让 Vim 更顺手 。

<br>

## 在哪里配置 Vim
* * *
[学习 Vi 和 Vim 编辑器][learning-vi-and-vim-editor]：

> Vim 依照特定顺序寻找初始化的信号，它执行找到的第一组指令（可以是 环境变量 or 配置文件），然后开始编辑工作 。所以，Vim 在下列清单中遇到的第一个项目，就是清单中被执行的唯一项目 。书寻如下：

> 1. `VIMINIT` 。它是环境变量，如果不为空，Vim 把它的内容当作 ex 命令执行

> 2. 用户 `vimrc` 文件 。

> 3. `exrc` 选项 。如果设置了 Vim 的 exrc 选项，它会寻找三个额外的配置文件 。

`vimrc`（vim runtime configure）文件一般有 3 个：

1. /etc/vim/vimrc

    本配置文件影响所有的用户，一般不应该更改这个配置文件，因为谁也不能保证别人的喜好和自己一样 。

2. /usr/share/vim/vimrc

    输入命令

        #!Shell
         ll /usr/share/vim/vimrc

    就可以看到，本文件是 `/etc/vim/vimrc` 的软链接 。

3. ~/.vimrc

    一般来说，配置 vim 就是在这个文件中配置，如果不存在的话 `touch` 一个新文件并命名 `。vimrc` 。我们在下面说的配置都是在本文件中配置 。

[learning-vi-and-vim-editor]: http://book.douban.com/subject/6126937/

<br>

## 映射 `esc` 键
* * *

因为历史原因，Joy 设计 vi 时采用的键盘和我们现在用的标准键盘布局并不一样，当时他的键盘的 `esc` 键在现在我们的 `Caps Lock` 键的位置，所以才设计使用 `esc` 作为模式转换键 。为了更加方便顺手地使用 vim，当然要把这两个键相互调换一下 。

在 vim 的官网上就有介绍如何实现两个按键的调换

[Map caps lock to escape in XWindows][Map caps lock to escape in XWindows]

具体方法，在 `～/` 目录下新建一个文件，加入一下内容

    #!Shell
    ! Swap caps lock and escape
    remove Lock = Caps_Lock
    keysym Escape = Caps_Lock
    keysym Caps_Lock = Escape
    add Lock = Caps_Lock

保存为 .speedswrapper

然后输入命令

    #!Shell
    xmodmap ~/.speedswrapper

这时，对于整个系统范围，这两个键已经调换了位置 。

[Map caps lock to escape in XWindows]: http://vim.wikia.com/wiki/Map_caps_lock_to_escape_in_XWindows

<br>

## 设置颜色主题 colorscheme
* * *

Vim 自带一些颜色主题，一般存放在 `/usr/share/vim/vim7x` 目录下（我的 Vim 版本为 7.3，所以路径为 `/usr/share/vim/vim73`）.

如果对系统自带的主题不满意，网上有很多不错的主题，个人最喜欢 [molikai][molikai] 主题，把下载下来的配色文件拷贝到 `usr/share/vim/vim73` 路径下，打开 vim 后 输入

    #!Shell
    :colorscheme molikai

就 ok 了～ 不过这个方法在关闭 vim 后就恢复了，要想省去每次都输命令的烦恼，只需要在下一步 .vimrc 文件中加入以下内容就可以了

    #!Shell
    colorscheme molikai

[molikai]: https://github.com/tomasr/molokai

<br>

## 编写 .Vimrc
* * *

vimrc 文件是配置 Vim 编辑特性比较好的地方，差不多任何 Vim 选项都能在次文件中被设置为打开或者关闭，而且它特别适合设置全局变量与定义函数、缩写、按键映射 。

+ 注释以双引号 `“` 开始，可位于一行的任何2位置，所有位于双引号后面的文本，包括双引号都会被视为注释而忽略

+ 可以用冒号 `:` 表示 ex 命令

### 配置 Vim 特性

vimrc 配置很简单，网上有很多人都分享了自己的配置方案 。我找到一份注释良好的[配置范例][config-file]，这篇博客的作者总结了自己 8 年的使用经验，给出了两份配置文件，基本版 [Basic][Basic] 和 终极版[Ultimate][Ultimate] 。

作为码农，当然要选择终极版了～不过个人喜欢用 Vundle 管理我的 Vim 插件（计划下篇博客记录我的配置过程），不是很喜欢作者选择的所有插件，想自己定制插件组合，那么目前只需要看 基础版就足够了 。

copy 了一份基础版到自己的 github 中，有备无患 :-D

[Copy of basic vimrc configure file]()

我自己的配置文件：

[My .vimrc file]()

    #!Shell
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " General
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    set nocompatible
    " Set how many lines of history VIM has to rememer
    set history=800
    
    " Enable filetype plugins
    filetype plugin on
    filetype indent on
    
    " Set to auto read when a file is changed from the outside
    set autoread
    
    " Set leader key
    let mapleader = ","
    let g:mapleader = ","
    
    " fast saving
    nmap <leader>w :w!<cr>
    
    " fast saving
    nmap <leader>q :q!<cr>
    
    " fast editing
    nmap <leader>aq :qa<cr>
    
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Vim user interface
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Set 20 lines to the cursor
    set so=20
    
    " Turn on the wild menu
    set wildmenu
    
    " Ignore complited files
    set wildignore=*.o,*~,*.pyc
    
    " Always show current postion
    set ruler
    
    " Highlight current line
    set cursorline
    
    " Height of command bar
    set cmdheight=2
    
    " A buffer becomes hidden when it is abandoned
    set hid
    
    " Configure backsapce so it acts as it should act
    set backspace=eol,start,indent
    set whichwrap+=<,>,h,l
    
    " Ignore case when searching
    set ignorecase
    
    " When searching try to be smart about cases
    set smartcase
    
    " Highlight search results
    set hlsearch
    
    " Make search act like in morden browsers
    set incsearch
    
    " Don't redraw while executing marcros
    set lazyredraw
    
    " For regular expressions turn magic on
    set magic
    
    " Show matching brackets when text indicator is over them
    set showmatch
    " How many tenths of a second to blink when matching brackets
    set mat=2
    
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Colors and Fonts
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Enable syntax highlight
    syntax enable
    colorscheme molokai
    set background=dark
    :set t_Co=256
    
    " Set utf8 as standard encoding and en_US as the standard language
    set encoding=utf8
    
    " Use Unix as the standard file type
    set ffs=unix,dos,mac
    
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Files, backups and undo
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Turn backup off, since most stuff is in SVN. git et.c anyway
    set nobackup
    set nowb
    set noswapfile
    
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Text, tab and indent related
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Use sapce instead of tabs
    set expandtab
    
    " Be smart when using tabs
    set smarttab
    
    " 1 tab = 4 spaces
    set shiftwidth=4
    set tabstop=4
    
    " Linebreak on 500 characters
    set lbr
    set tw=500
    
    set ai "Auto indent
    set si "Smart indent
    set wrap "Wrap lines
    
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Moving around, tabs, windows and buffers
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Treat long lines as break lines
    map j gj
    map k gk
    
    " Smart way to move between windows
    map <C-j> <C-w>j
    map <C-k> <C-w>k
    map <C-h> <C-w>h
    map <C-l> <C-w>l
    
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Status line
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Show line number
    set number
    
    " Always show the status line
    set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}
    ""set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l
    
    
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Spell checking
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Pressing ,ss will toggle and untoggle spell checking
    map <leader>ss :setlocal spell!<cr>
    map <leader>sn ]s
    map <leader>sp [s
    map <leader>sa zg
   
[config-file]: https://github.com/amix/vimrc
[Basic]: https://github.com/amix/vimrc/blob/master/vimrcs/basic.vim
[Ultimate]: https://github.com/amix/vimrc

<br>

## 参考

[学习vi 和 Vim 编辑器][learning-vi-and-vim-editor]

[The Ultimate vimrc][config-file]
