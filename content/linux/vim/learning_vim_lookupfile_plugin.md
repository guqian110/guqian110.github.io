Title: 学习 Vim 之 lookupfile 插件
Category: Linux
Date: 2015-05-03
Tags: Vim, lookupfile
Slug: learning_vim_lookupfile_plugin
Author: Qian Gu
Summary: 学习使用 lookupfile 插件。

系统内置的 `:find` 命令不够好：

1. 项目比较大，文件比较多时，查找速度慢

2. 必须输入文件全名，而且不能使用正则表达式查找

而使用 NERDTree 的话，在一个小窗口内，按照目录浏览查找的效率也很低。

`lookupfile` 这个插件可以实现类似 Sublime Text 中 Ctrl + P 的效果，只需要输入文件的部分名字即可匹配查找到文件。

## Install
* * *

lookupfile 需要 `genutils` 插件的支持，使用 Vundle 安装两个插件：

    Bundle 'genutils'
    Bundle 'lookupfile'

<br>

## Config
* * *

关于 lookupfile 的详细配置，查看 help 文档，下面是几个常用的配置选项：

    let g:LookupFile_MinPatLength = 2
    let g:LookupFile_PreserveLastPattern = 0
    let g:LookupFile_PreservePatternHistory = 1
    let g:LookupFile_AlwaysAcceptFirst = 1
    let g:LookupFile_AllowNewFiles = 0

### tags

[vi/vim使用进阶: lookupfile插件][blog1] 中介绍到 lookupfile 可以使用 ctags 生成的 tags 文件来查找，不过其查找效率比较低，所以作者写了一个 shell 脚本来生成专用的 tags 文件：

    #!shell
    #!/bin/sh
    # generate tag file for lookupfile plugin
    echo -e "!_TAG_FILE_SORTED\t2\t/2=foldcase/" > filenametags
    find . -not -regex '.*\.\(png\|gif\)' -type f -printf "%f\t%p\t1\n" | \
        sort -f >> filenametags 

为了方便起见，把这个脚本保存为 `genfiletags` 文件，然后将其移动到专门存放常用 shell 脚本的目录下，将这个目录添加到系统变量 `$PATH` 中，这样在 vim 中直接运行 `:!genfiletags` 就可以生成 tags 文件了。

生成好 tags 文件后，还要配置 vim，告诉它使用这个文件来查找：

    if filereadable("./filenametags")
        let g:LookupFile_TagExpr = '"./filenametags"'
    endif

### case sensitive

lookupfile 插件是大小写敏感的，可以在查找到时候加上 `\c` 就能忽略大小写，不过这样很麻烦，下面是更加简单的方法，在 .vimrc 中添加下面这段代码即可：

    function! LookupFile_IgnoreCaseFunc(pattern)
        let _tags = &tags
        try
            let &tags = eval(g:LookupFile_TagExpr)
            let newpattern = '\c' . a:pattern
            let tags = taglist(newpattern)
        catch
            echohl ErrorMsg | echo "Exception: " . v:exception | echohl NONE
            return ""
        finally
            let &tags = _tags
        endtry

        " Show the matches for what is typed so far.
        let files = map(tags, 'v:val["filename"]')
        return files
    endfunction
    let g:LookupFile_LookupFunc = 'LookupFile_IgnoreCaseFunc' 

### Summary

综上，.vimrc 中的配置内容如下：

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Config lookupfile
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""
    let g:LookupFile_MinPatLength = 2
    let g:LookupFile_PreserveLastPattern = 0
    let g:LookupFile_PreservePatternHistory = 1
    let g:LookupFile_AlwaysAcceptFirst = 1
    let g:LookupFile_AllowNewFiles = 0
    if filereadable ("./filenametags")
        let g:LookupFile_TagExpr = '"./filenametags"'
    endif
    nmap <silent><leader>lk :LUTags<cr>
    nmap <silent><leader>ll :LUBufs<cr>
    nmap <silent><leader>lw :LUWalk<cr>
    " lookup file with ignore case
    function! LookupFile_IgnoreCaseFunc(pattern)
        let _tags = &tags
        try
            let &tags = eval(g:LookupFile_TagExpr)
            let newpattern = '\c' . a:pattern
            let tags = taglist(newpattern)
        catch
            echohl ErrorMsg | echo "Exception: " . v:exception | echohl NONE
            return ""
        finally
            let &tags = _tags
        endtry
                        
        " Show the matches for what is typed so far.
        let files = map(tags, 'v:val["filename"]')
        return files
    endfunction
    let g:LookupFile_LookupFunc = 'LookupFile_IgnoreCaseFunc' 

[blog1]: http://easwy.com/blog/archives/advanced-vim-skills-lookupfile-plugin/

<br>

## Usage
* * *

lookupfile 可以查找文件夹、缓冲区、按照目录查找三种方法：

### `:LookupFile`

按 F5 或者输入命令 `:LookupFile` 来打开上部的 lookupfile 小窗口，输入文件名即可查找，可以使用 vim 的正则表达式查找，使用 Ctrl-N 和 Ctrl-P 来上下选择查找结果。

### `:LUBufs`

虽然有 `BufExplorer` 可以查看 buffers，但是当 buffer 很多时，使用 lookupfile 更加方便一点。

输入命令 `:LUBufs` 查找缓冲区的文件。

### `:LUWalk`

使用 `:LUWalk` 来浏览目录。这个功能和 NERDTree 重复了，个人感觉 NERDTree 浏览目录更加方便一点，毕竟不用输入文件目录名，可以少翘几个字符...

<br>

## Ref

[vi/vim使用进阶: lookupfile插件][blog1]

[lookupfile.vim插件详解【OK】](http://blog.163.com/lgh_2002/blog/static/44017526201061313442254/)
