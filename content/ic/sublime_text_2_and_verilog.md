Title: Sublime Text 2 和 Verilog HDL
Date: 2014-07-04 23:31
Category: IC
Tags: Sublime Text, Vivado
Slug: sublime_text_2_and_verilog
Author: Qian Gu
Summary: 介绍神器 Sublime Text 在 HDL 方面的简单应用

## Sublime Text
* * *

代码编辑器之于程序员，就如同剑之于战士。程序员关于代码编辑器的争论从来就没有停止过，每个程序员都有自己熟悉的编辑器，他们热爱自己的 “武器”，甚至可以形成 “宗教”，比如 Vim 和 Emac 的战争。

如今，这个无休止的争论中要加入一个新成员了，她就是 [Sublime Text][sublime] 。其实她也不是 “新” 成员了，早在 2011 年她就诞生了，不过经过不断的改进，终于人们不得不正视这个新人，不仅仅因为漂亮的外在美，还有强大的内在美 :-P

个人感觉，ST 的出现恰到好处，她兼具了 Vim 的强大功能和普通编辑器的易用性。虽然 Vim 轻巧、强大，但是 Vim 的门槛比较高，要想用好 Vim 是需要长期练习的，而 ST 可以说是老少皆宜，你是小白，不会用 Vim？没关系，她可以像普通的编辑器一样，即使你 0 基础也可以使用；你是老手，习惯 Vim？也没关系，她可以 **开启 Vim 模式**，还是原来的配方，还是熟悉的味道～

虽然她不是开源项目，有收费，但是我们有免费无限制无限期的试用权，而且她绿色小巧，不用安装，解压即可使用，跨平台，支持各种编程语言的代码补全和语法高亮。如果对现有的插件不满意，我们甚至可以自己定制插件。

<br>

简单说一下我在使用过程中的一些问题，更加详细的使用官方和非官方的网站上都有详细的说明，还有别人总结的技巧请自行 Google。

[Official docs](https://www.sublimetext.com/docs/2/index.html)

[Unofficial docs](http://sublime-text-unofficial-documentation.readthedocs.org/en/sublime-text-2/)

[Others: Sublime Text 2 - 性感无比的代码编辑器！程序员必备神器！跨平台支持Win/Mac/Linux](http://www.iplaysoft.com/sublimetext.html)

P.S. 我使用的是 Sublime Text 2，虽然已经有 3 了，但是 3 还在 Beta 阶段，大家貌似对 3 不是很满意

[sublime]: http://www.sublimetext.com/

<br>

## Vim Mode
* * *

ST 是自带 Vim 模式的（Vintage Mode），但是这个模式默认是没有开启的，毕竟对于大多数普通人来说， Vim 实在是不太友好...

打开 ST 的 `Preferences/Setting - Defalut`，在最后一行有句

    "ignored_packages": ["Vintage"]
    
只需要将方括号中的 Vintage 去掉就可以了。推荐在 Setting - User 中修改。
    
[官方说明][vintage]

[vintage]: https://www.sublimetext.com/docs/2/vintage.html

<br>

## Package Control
* * *

ST 的一个强大之处就在于可以安装各种插件，要安装插件有两种方法：

1. 手动下载，解压到指定目录

2. 安装 `Package Control` 插件，自动管理安装插件

第一种方法虽然麻烦，但是在没有网络的环境下，我们可以从别人那拷贝过来即可；第二种方法最方便了，不过要求有网络。

### Installation

ST 默认是没有安装 Package Control 的，需要我们手动安装：

1. `Ctrl ~` 调出控制台

2. 在控制台中粘贴以下命令

        import urllib2,os; pf='Package Control.sublime-package'; ipp=sublime.installed_packages_path(); os.makedirs(ipp) if not os.path.exists(ipp) else None; urllib2.install_opener(urllib2.build_opener(urllib2.ProxyHandler())); open(os.path.join(ipp,pf),'wb').write(urllib2.urlopen('http://sublime.wbond.net/'+pf.replace(' ','%20')).read()); print 'Please restart Sublime Text to finish installation'

3. 安装完成之后，重启 ST 即可

### Using

按下 `Ctrl + Shift + P`，在弹出的命令面板，输入 `package`，就会自动弹出相关的命令，可以选择 `Install`、`Remove`、`Disable`、`Enable`、`List`、`Update` 等命令。

[sublime wbond][wbond] 上列出了 Package Control 可以找到的所有的插件，有详细的安装和使用说明。

网上也有很多文章介绍了大量的常用插件，我们可以按照需求自己挑选需要的插件进行安装。

[wbond]: https://sublime.wbond.net/

<br>

## Verilog HDL
* * *

常用的插件，比如括号匹配、智能补全、自动对齐、Tags、注释生成、Terminal、Build、Git 等插件就不再赘述了，说一下网上介绍的比较少，但我自己使用比较多的关于 Verilog 的插件。

可以通过 Package 下载到两个插件，`Verilog` 和`Verilog-Automatic`。第一个插件主要功能是支持 Verilog 的代码高亮和补全，第二个插件可以帮助我们自动生成模块例化、端口添加连接等功能。

其中，第一个插件的 Snippet 并不太让人满意，在原 Snippet 的基础上，我添加了一些我常用到的 Snippets。

### always

因为插件作者只添加了异步高有效复位方式的 `always` 块，而我们同步和异步两种方式都可能会用到，所以，我添加同步复位的 Snippet

ST 2 的 Package 都存放在 `/home/.config/sublime-text-2/Packages` 目录下面，我们需要修改的就是这个目录下的 `Verilog/Snippets` 下的 `.tmSnippet` 文件。修改后的结果如下：

**always_async.tmSnippet**

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/Prop    ertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    	<key>content</key>
    	<string>always @(posedge clk or ${1:posedge} ${2:rst}) begin
    	if ($2) begin
    		// reset
    		$3
    	end
    	else if ($4) begin
    		$0
    	end
    end</string>
    	<key>name</key>
    	<string>always_async</string>
    	<key>scope</key>
    	<string>source.verilog</string>
    	<key>tabTrigger</key>
    	<string>always_async</string>
    	<key>uuid</key>
    	<string>026B3DA6-E1B4-4F09-B7B6-9485ADEF34DC</string>
    </dict>
    </plist>
    
**always_sync.tmSnippet**

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/Prop    ertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    	<key>content</key>
    	<string>always @(posedge clk) begin
    	if (${1:rst}) begin
    		// reset
    		$2
    	end
    	else begin
    		$0
    	end
    end</string>
    	<key>name</key>
    	<string>always_sync</string>
    	<key>scope</key>
    	<string>source.verilog</string>
    	<key>tabTrigger</key>
    	<string>always_sync</string>
    	<key>uuid</key>
    	<string>026B3DA6-E1B4-4F09-B7B6-9485ADEF34DC</string>
    </dict>
    </plist>
    
修改之后的结果如下图所示：

![always](/images/sublime-text-2-and-verilog/always.gif)

### if-else

原来的 if snippet 没有 else 分支，所以，添加了一个有 else 分支的 if 语句。

**if.tmSnippet**

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/Prop    ertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    	<key>content</key>
    	<string>if ($1) begin
    	$0
    end</string>
    	<key>name</key>
    	<string>if</string>
    	<key>scope</key>
    	<string>source.verilog</string>
    	<key>tabTrigger</key>
    	<string>if</string>
    	<key>uuid</key>
    	<string>1ADE2F84-DDB8-4878-8BFC-B7FC2F391C6C</string>
    </dict>
    </plist>
    
**if-else.tmSnippet**

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/Prop    ertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    	<key>content</key>
    	<string>if ($1) begin
    	$2
    end
    else begin
    	$0
    end</string>
    	<key>name</key>
    	<string>if_else</string>
    	<key>scope</key>
    	<string>source.verilog</string>
    	<key>tabTrigger</key>
    	<string>if_else</string>
    	<key>uuid</key>
    	<string>1ADE2F84-DDB8-4878-8BFC-B7FC2F391C6C</string>
    </dict>
    </plist>
    
修改后的结果如下图：

![if-else](/images/sublime-text-2-and-verilog/if-else.gif)

### parameter

原来是没有 parameter 的snippets 的，拷贝一份其他的 snippet，修改其中的一些设置，即可

**parameter.tmSnippet**

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/Prop    ertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    	<key>content</key>
    	<string>parameter	$1 = $2,
    			$3 = $0
    </string>
    	<key>name</key>
    	<string>parameter</string>
    	<key>scope</key>
    	<string>source.verilog</string>
    	<key>tabTrigger</key>
    	<string>parameter</string>
    	<key>uuid</key>
    	<string>1ADE2F84-DDB8-4878-8BFC-B7FC2F391C6C</string>
    </dict>
    </plist>

修改后的结果如下图所示：

![parameter](/images/sublime-text-2-and-verilog/parameter.gif)

### case

原来是没有 case 的 snippet，方法同上，可以修改出我们想要的 case snippet

**case.tmSnippet**

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/Prop    ertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>content</key>
        <string>case ($1)
        $2: begin
            $3
        end
        $4: begin
            $5
        end
        $6: begin
            $7
        end
        $8: begin
            $9
        end
        default: begin
            $10
        end
    endcase</string>
        <key>name</key>
        <string>case</string>
        <key>scope</key>
        <string>source.verilog</string>
        <key>tabTrigger</key>
        <string>case</string>
        <key>uuid</key>
        <string>026B3DA6-E1B4-4F09-B7B6-9485ADEF34DC</string>
    </dict>
    </plist>
    
修改后的效果如下：

![case](/images/sublime-text-2-and-verilog/case.gif)

<br>

## SublimeText in Vivado
* * *

代码编辑器之于程序员就像武器之于战士，其重要性不需赘述，本文记录一下设置 SublimeText 为 Vivado 的代码编辑器的过程。

Ref: [How to setup an external text editor in Xilinx ISE & EDK][setup ref]

是讲 ISE 和 EDK 的设置，同理可以将其推广到 Vivado 中，其实 Vivado 已经将常见的编辑器列出来了，其中就包含 Sublime，但是因为我没有将 Sublime 包含在系统路径中，所以需要选择 custom editor 选项：

    D:/Sublime_Text_3/sublime_text.exe [file name]:[line number]

即可。

[setup ref]: http://steamforge.net/wiki/index.php/How_to_setup_an_external_text_editor_in_Xilinx_ISE_%26_EDK

<br>

上面仅仅说了非常基本的几个设置，和我在写 Verilog 时自己添加的几个 snippet，其他的 ST 的使用技巧官方和非官方的 ref 有非常详细的介绍，另外其他人也有很多文章介绍～
