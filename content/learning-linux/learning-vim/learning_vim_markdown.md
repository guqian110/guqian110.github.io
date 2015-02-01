Title: 在 Vim 中写 Markdown 文件
Date: 2015-02-01 13:46
Category: Linux
Tags: vim, markdown
Slug: learning_vim_markdown
Author: Qian Gu
Summary: 在 Vim 中使用 Markdown 语法写文本。

`Vim` 和 `Markdown` 就不多罗嗦了，记录一下最近在 Vim 中摸索使用 Markdown 的经历。

## Syntax Hightlight
* * *

Vim 可以通过插件来提供对 Markdown 语法的支持，网上找到很多这类插件：

官网上的插件：[Markdown][markdown]

我找到的是下面这个：

[plasticboy/vim-markdown][pv]

### Install

使用 Vundle 管理插件，只需要在 `.vimrc` 文件中添加：

    Bundle 'godlygeek/tabular'
    Bundle 'plasticboy/vim-markdown'

然后打开 Vim，输入命令：

    :BundleInstall

即可。

### File extension

Markdown 文件的后缀名可以是 `.markdown`，`mkd`，`mkdn`，`md` 等，但是 plasticboy 的插件只识别 `mkd` 和 `markdown` 两种：

[Enabling markdown highlighting in Vim][so1]

因为我们已经按照 .md 格式写了很多文本了，这时候更好选择当然是修改设置，让 vim 可以识别这种类型的文件，而不是修改文件后缀名。所以我们需要在 vimrc 中设置一下：

    au BufRead,BufNewFile *.md set filetype=markdown

这样，.md 文件就可以被识别了。

经过上面两步，此时再打开 markdown 文件就可以看到语法高亮了，plasticboy/vim-markdown 还支持一些高级的主题：比如支持 LaTeX 数学公式的高亮，ToC 等，从 github 上可以看到相关设置的介绍说明。

[markdown]: http://www.vim.org/scripts/script.php?script_id=2882
[pv]: https://github.com/plasticboy/vim-markdown
[so1]: http://stackoverflow.com/questions/10964681/enabling-markdown-highlighting-in-vim
<br>

## Preview
* * *

一些专门的 Markdown 软件、网页编辑器都是提供实时预览，Vim 虽然不提供预览窗口，但是配合浏览器，我们也可以实现实时预览的功能，当然还是依靠万能的插件。

我使用的是：

[suan/vim-instant-markdown][sv]

### Install

1. 首先要保证已经安装了 node.js

        npm -v

2. 如果没有，安装 npm

        sudo apt-get install npm

3. 安装 `instant-markdown-d`

        sudo npm -g install instant-markdown-d

4. 确保系统安装了 `xdg-utils`，否则 apt-get 安装

5. 使用 Vundle 管理插件

    在 .vimrc 中添加

        Bundle 'suan/vim-instant-markdown'

    打开 vim，输入命令

        :BundleInstall

### Config & Use

如果机器比较老，插件占用的资源过多的话，可以设置

    let g:instant_markdown_slow = 1

来降低资源利用。

默认情况下，当我们打开 markdown 文件时，插件会自动打开一个预览的浏览器标签页，如果不想，可以关闭自动打开功能：

    let g:instant_markdown_autostart = 0

在需要时手动输入命令 `:InstantMarkdownPreview` 来预览。

**存在的问题：**

1. Vim 窗口重叠在浏览器窗口之上时，会遮住部分内容；当两个窗口并排时，浏览器窗口无法完全显示全部内容，这在小尺寸屏幕上尤其明显。

2. 打开的预览网页无法实时跟随内容滚动。

最后放一张截图：

![screenshot](/images/learning-vim-markdown/screenshot.png)

[sv]: https://github.com/suan/vim-instant-markdown

## Ref

[plasticboy/vim-markdown][pv]

[Enabling markdown highlighting in Vim][so1]

[suan/vim-instant-markdown][sv]

