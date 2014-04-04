Title: Learning Vim Survival
Date: 2014-03-25 21:23
Category: Linux
Tags: Linux,Vim
Slug: learning_vim_survival
Author: Chien Gu
Summary: 这个系列的博客是我学习 Vim 过程中的记录和总结，希望可以帮助到和我一样的菜鸟～ 第一篇：入门/存活 Survival

这个系列的博客是我学习 Vim 过程中的记录和总结，希望可以帮助到和我一样的菜鸟～

第一篇：入门/存活 Survival

* * *
<br>
<nr>
## Vim 是什么
* * *

简单的说，[Vim][Vim] 就是广大的编辑器中的一员，但是对程序猿来说，她并不是一款简单的编辑器。她强大的编辑能力、苗条的身材（软件体积小、启动速度快）和 Linux 系统的血缘关系（几乎是 Linux 系统的标配），使其在全世界有成千上万的粉丝，以至于掌握 Vim 成为每个码农必备技能。

Wikipedia 上 Vim 的介绍：

> Vim (an acronym for Vi IMproved) is a text editor written by Bram Moolenaar and first released publicly in 1991. Based on the vi editor common to Unix-like systems, Vim is designed for use both from a command line interface and as a standalone application in a graphical user interface. Vim is free and open source software and is released under a license that includes some charityware clauses, encouraging users who enjoy the software to consider donating to children in Uganda. The license is compatible with the GNU General Public License.

[Vim]: http://www.vim.org/

###历史

**摘抄（翻译）自 [Wikipedia][viwiki]**

关于 vi/Vim 的发展，还是从头说起：


**[ed][ed]** 是 UNIX 界最古老最基本的编辑器，它由 [Ken Thompson][K] (UNIX 之父)于 1971 年在 [PDP-11][PDP-11]/20 上用汇编写成 。ed 的许多特性来自于 [Thompson][K] 在加州伯克利大学上学时受到的[qed][qed] 编辑器的影响 。Thompson 对 qed 非常熟悉，他在 [CTSS][CTSS] 和 [Multics][Multics] 操作系统上重新实现了一边 qed ，并且在他的版本中，第一次实现了正则表达式（ [regular expressions][re]）。虽然正则表达式也是 ed 的一部分，但是一般认为在 qed 中正则表达式的实现更多一些 。

ed 是为电传机（[teletype][teletype]）而不是终端显示器（[display terminals][dt]）设计的行编辑器，它是一个行编辑器。在它的起源地 —— AT&T 实验室，人们似乎很满意把 ed 设置为默认的编辑器，即使它的功能很基本而且很不友好。 [George Coulouris][George_Coulouris] 回忆说：

> [...] for many years, they had no suitable terminals. They carried on with TTYs and other printing terminals for a long time, and when they did buy screens for everyone, they got Tektronix 4014s. These were large storage tube displays. You can't run a screen editor on a storage-tube display as the picture can't be updated. Thus it had to fall to someone else to pioneer screen editing for Unix, and that was us initially, and we continued to do so for many years.

Coulouris 认为 ed 的隐藏的命令只适合于 “神人”（immortals），所以在 [Queen Mary College][QMC] 当讲师的期间，他在 Thompson 的代码的基础上加强了 ed，并且命名为 em （the "editor for mortals"）。

**em** 是为终端显示器设计（display terminals）的，一次只显示一行的可视化编辑器，它是 UNIX 中第一个大量使用 "raw terminal input mode" 的程序，这种模式下，由应用程序而不是终端的驱动处理键盘的输入。1976 年夏天，Coulouris 参观 [UC Berkeley][UCB] 时，他带着一卷录有 em 的 DEC 磁带，他给很多人演示了 em ，有的人认为 em 只是有潜力，但是有的人却对此留下了深刻影响，其中就包括 [Bill Joy][BJ] 。

受到 em 的鼓舞，加上他们自己使用 ed 时的技巧，Bill Joy 和 Chuck Haley 这两个刚从 UC Berkeley 的毕业的研究生使用 em 的代码，设计了一个叫 en 的编辑器，然后把 en 扩展为 **[ex][ex]** v0.1 。

ex 仍然只显示一行而非一屏的内容。后来，Chuck Haley 退出了开发，Bruce Englar 鼓励 Bill Joy 重新设计了 ex，在 1977 年 6 月到 10 月期间，他为 ex 添加了全屏可视化模式 ，ex 的 visual mode 也就是 **vi** 的命名原因 。

[vi Wikipedia][viwiki]:

> vi /ˈviːˈaɪ/ is a screen-oriented text editor originally created for the Unix operating system. The portable subset of the behavior of vi and programs based on it, and the ex editor language supported within these programs, is described by (and thus standardized by) the Single Unix Specification and POSIX.

据 Bill Joy 讲，很多 vi 的可视化灵感来自于另外一个叫做 [Bravo][Bravo] 的编辑器，在一次关于 vi 的起源的访谈中，他说：

> A lot of the ideas for the screen editing mode were stolen from a Bravo manual I surreptitiously looked at and copied. Dot is really the double-escape from Bravo, the redo command. Most of the stuff was stolen. There were some things stolen from ed—we got a manual page for the Toronto version of ed, which I think Rob Pike had something to do with. We took some of the regular expression extensions out of that.

至于为什么 vi 要设计成这么不友好，其实是有历史原因的：

Joy 使用的是 Lear Siegler ADM3A 终端，如下图所示

![Terminal_ADM3A](/images/learning-vim-survival/Terminal_ADM3A.png)

在这个终端上，`ESC` 键的位置是现在 [IBM PC keyboard][IBM_PC_keyboard] 键盘的 `Tab` 键的位置，所以，选择 `ESC` 作为模式切换键是很方便的设计 。同时，`h`、`j`、`k` 和 `l` 键也起方向键的作用，所以，vi 也采用相同的设计 。Joy 解释说，因为他开发软件时使用的 Modem 的速率只有 300 波特，显示器上的刷新速度还没有他的思考速度快，所以他设计了单字符这样的简洁风格的命令。

1978 年 3 月，Joy 负责的 BSD Unix 发布了，系统自带了 ex 1.1，这为他的编辑器在 UC Berkeley 积攒了大量人气。从那时起，Unix 系统自带的编辑器只有 ed 和 ex 。在 1984 年的一次采访中，Joy 把 vi 的成功归功于免费，当时的其他编辑器，比如 Emacs 要花费数百美金 。

观察显示基本上，所有的 ex 用户都是在 visual mode 下工作，所以在 ex 2.0（作为 1979 年 5 月的 BSD Unix 的一部分）中，Joy 把 vi 作为 ex 的硬链接，这样用户一打开 ex，就默认进入 visual mode ，所以说，vi 并不是 ex 的进化，vi 就是 ex 。

虽然在今天看来，vi 是一个很小的，轻量级的程序，但是 Joy 把 ex 2.0(vi) 描述为一个非常大的程序，因为它几乎占据了 [PDP-11/70][PDP-11/70] 的所有内存。在 1979 年第3版 BSD 中，PDP-11 已经无法存储v3.1 的 vi 。

Joy 一直领导着 vi 的开发，一直到 1979 年 6 月的 vi 2.7，到 1980 年 8 月的 v3.5 版本中，还作出偶尔的贡献。在谈及 vi 的起源和他为何退出开发时，他说，

> I wish we hadn't used all the keys on the keyboard. I think one of the interesting things is that vi is really a mode-based editor. I think as mode-based editors go, it's pretty good. One of the good things about EMACS, though, is its programmability and the modelessness. Those are two ideas which never occurred to me. I also wasn't very good at optimizing code when I wrote vi. I think the redisplay module of the editor is almost intractable. It does a really good job for what it does, but when you're writing programs as you're learning... That's why I stopped working on it.
> 
> What actually happened was that I was in the process of adding multiwindows to vi when we installed our VAX, which would have been in December of '78. We didn't have any backups and the tape drive broke. I continued to work even without being able to do backups. And then the source code got scrunched and I didn't have a complete listing. I had almost rewritten all of the display code for windows, and that was when I gave up. After that, I went back to the previous version and just documented the code, finished the manual and closed it off. If that scrunch had not happened, vi would have multiple windows, and I might have put in some programmability—but I don't know.
>
> The fundamental problem with vi is that it doesn't have a mouse and therefore you've got all these commands. In some sense, its backwards from the kind of thing you'd get from a mouse-oriented thing. I think multiple levels of undo would be wonderful, too. But fundamentally, vi is still ed inside. You can't really fool it.
It's like one of those pinatas—things that have candy inside but has layer after layer of paper mache on top. It doesn't really have a unified concept. I think if I were going to go back—I wouldn't go back, but start over again.

在 1979 年， [Mark Horton][Mark Horton] 接管了 vi 的开发，他添加了对方向键和功能键的支持，用  terminfo 代替了 termcap，提高了 vi 的性能 。

到 1981 年的 8 月，v3.7 版的 vi 以前，UC Berkeley 是 vi 开发的中心，但是随着 1982 年初 Joy 的离开去创办 [Sun Microsystems][sun]，AT&T 的  [UNIX System V][V] (1983 年 1 月)采用 vi，vi 代码库的变化开始变得缓慢混乱，而且变得相互不兼容。在 UC Berkeley，虽然有修改代码，但是版本号一直没有超过 3.7 。商业的 Unix 制造商，比如 Sun, [HP][HP], [DEC][DEC], 和 [IBM][IBM]，他们的系统 [Solaris][Solaris], [HP-UX][HP-UX], [Tru64 UNIX][Tru64 UNIX], 和 [AIX][AIX]，今天仍然在使用从 3.7 release 中衍生出来的代码，但是加入了新的特性，比如可以调整的按键映射、加密等 。

虽然商业的制造商可以使用 Joy 的代码库（直至今天），但是有许多人却不能使用。因为 Joy 是在 Thompson 的 ed 的基础上开发的，所以 ex 和 vi 是派生出来的产品，不能发布给没有 AT&T 的许可证的人使用。想在类 Unix 系统上找到一个编辑器的话必须在别的地方寻找。1985年，一个 Emacs 的版本（[MicroEmacs][MicroEmacs]）在很多平台上可以使用，但是直到 1987 年 6 月才出现一个 vi 的克隆版本 —— Steive 。在 1990 年 1 月初，Steve Kirkendall 为发布了一个新的 vi 克隆版本 [Elvis][Elvis]，它比 Stive 更加完整更加忠实于 vi 。它很快就吸引了社区用户的热情，[Andrew Tanenbaum][Andrew Tanenbaum] 马上在社区讨论在 [Minix][Minix] 中使用哪一个当中 vi 的克隆，结果 Elvis 胜利了，直到今天仍然在 Minix 中当作 vi 的克隆体使用 。

在 1989 年，[Lynne Jolitz][Lynne_Jolitz] 和 [William Jolitz][William_Jolitz] 开始着手把 BSD Unix 移植到 386 系列的处理器上，为了发布一个免费版本，他们必须绕过 AT&T 含有的代码，其中就包括 Joy 的 vi 。为了填补 vi 的空白，他们在 1992 年的 386BSD 发布版中采用了 Elvis 作为 vi 的替代品，386BSD 后来的分支 [FreeBSD][FreeBSD] 和 [NetBSD][NetBSD] 也延续了这一决定。但是在 UC Berkely，Keith Bostic 使用 Kirkendall 的 Elvis（v1.8）代码，编写了 [nvi][nvi]，并于 1994 年春发布。当 FreeBSD 和 NetBSD 在  4.4-Lite2 代码库的基础上重新同步以后，他们也采用了 nvi，并且一直延续到今天。

虽然有很多 vi 的克隆体，而且它们都有很多加强的特性，但是在 2000 年前左右，Gunnar Ritter 使用了 2.11BSD 中的 Joy 的代码，并把 vi 移植到了类 Unix 系统中，比如 Linux 和 FreeBSD 。从技术上讲，他没有许可证而发布 vi 的做法是非法的，但是，到了 2002 年 1 月，AT&T 的许可证被取消了，vi 可以作为开源项目在其他发布版中使用。Ritter 继续在 Joy 的代码的基础上加强 vi 的特性，就像那些商业版一样。他的成果 [Traditional Vi][Traditional_Vi] 在很多系统上运行。

虽然 Joy 的 vi 现在又可以在 BSD Unix 上使用，但是 很多 BSD 的粉丝都转移到 更加强大、但仍然保留着 vi 的某些特性的 nvi 的阵地。从某种意义上说，这是一个奇怪的反常现象，在 Joy 的 vi 的发源地 BSD 中不再使用 vi，但是缺少它的 AT&T 的发行版却仍然保留了它并使用至今。

在 1984 年 Emacs 发布以前，vi 几乎是所有 Hacker 使用的 Unix 标准编辑器，从 2006 年开始，作为 [”单一Unix标准“（Single UNIX Specification）][SUS]的一部分，vi 和 vi 的变形体一定可以在今天的系统中找到。

[Bram Moolenaar][Bram_Moolenaar] 于 1988 年买了一台 [Amiga][Amiga] 计算机，Amiga 上没有他常用的 vi，于是他在开源的 Stevie 的基础上，于 1991 年发布了 Vim v1.14 。

起初 **[Vim][Vim]** 是 *”Vi IMitation“* 的缩写，但是后来 1993 年 12 发布的 Vim 2.0 版本中改名为 *"Vi IMproved"* 。

vim 现在是 [GNU General Public （GPL）][GPL]下的自由软件，几乎在所有的 Linux 系统和 苹果 OS X 系统中都可以找到她的身影。

[viwiki]: http://en.wikipedia.org/wiki/Vi
[ed]: http://en.wikipedia.org/wiki/Ed_(text_editor)
[k]: http://en.wikipedia.org/wiki/Ken_Thompson_(computer_programmer)
[PDP-11]: http://en.wikipedia.org/wiki/PDP-11
[qed]: http://en.wikipedia.org/wiki/QED_(text_editor)
[CTSS]: http://en.wikipedia.org/wiki/Compatible_Time-Sharing_System
[Multics]: http://en.wikipedia.org/wiki/Multics
[re]: http://en.wikipedia.org/wiki/Regular_expression
[teletype]: http://en.wikipedia.org/wiki/Teletype
[dt]: http://en.wikipedia.org/wiki/Display_terminal
[George_Coulouris]: http://en.wikipedia.org/wiki/George_Coulouris_(computer_scientist)
[QMC]: http://en.wikipedia.org/wiki/Queen_Mary,_University_of_London
[UCB]: http://en.wikipedia.org/wiki/University_of_California,_Berkeley
[BJ]: http://en.wikipedia.org/wiki/Bill_Joy
[ex]: http://en.wikipedia.org/wiki/Ex_(editor)
[Bravo]: http://en.wikipedia.org/wiki/Bravo_(software)
[IBM_PC_keyboard]: http://en.wikipedia.org/wiki/IBM_PC_keyboard
[PDP-11/70]: http://en.wikipedia.org/wiki/PDP-11#Models
[Mark Horton]: http://en.wikipedia.org/wiki/Mary_Ann_Horton
[sun]: http://en.wikipedia.org/wiki/Sun_Microsystems
[V]: http://en.wikipedia.org/wiki/UNIX_System_V
[HP]: http://en.wikipedia.org/wiki/HP
[DEC]: http://en.wikipedia.org/wiki/Digital_Equipment_Corporation
[IBM]: http://en.wikipedia.org/wiki/IBM
[Solaris]: http://en.wikipedia.org/wiki/Solaris_(operating_system)
[HP-UX]: http://en.wikipedia.org/wiki/HP-UX
[Tru64 UNIX]: http://en.wikipedia.org/wiki/Tru64_UNIX
[AIX]: http://en.wikipedia.org/wiki/AIX
[MicroEmacs]: http://en.wikipedia.org/wiki/MicroEMACS
[Elvis]:http://en.wikipedia.org/wiki/Elvis_(text_editor)
[Andrew Tanenbaum]: http://en.wikipedia.org/wiki/Andrew_S._Tanenbaum
[Minix]: http://en.wikipedia.org/wiki/Minix
[Lynne_Jolitz]: http://en.wikipedia.org/wiki/Lynne_Jolitz
[William_Jolitz]: http://en.wikipedia.org/wiki/William_Jolitz
[FreeBSD]: http://en.wikipedia.org/wiki/FreeBSD
[NetBSD]: http://en.wikipedia.org/wiki/NetBSD
[nvi]: http://en.wikipedia.org/wiki/Nvi
[Traditional_Vi]: http://ex-vi.cvs.sourceforge.net/
[SUS]: http://en.wikipedia.org/wiki/Single_UNIX_Specification
[Bram_Moolenaar]: http://en.wikipedia.org/wiki/Bram_Moolenaar
[Vim]: http://en.wikipedia.org/wiki/Vim_(text_editor)
[GPL]: http://en.wikipedia.org/wiki/GNU_General_Public_License

<br>

## 为什么选择 Vim
* * *
程序猿界的 **圣战：**

+ **Windows** vs **Linux**
+ **Vim/Emacs** vs **IDE** (**Vim** vs **Emacs**)
+ **C++** vs **JAVA** vs **Python** vs ...

首先是在 Vim 和 IDE 之间的争论。

### Vim & IDE

”到底是该选择 vim 还是 IDE ？“ 在 Stackoverflow 和 知乎 上有非常多的这样的帖子。

比如这篇：

[What is your most productive shortcut with Vim?][vimshortcut]

再比如这篇：

[为什么不少程序员极度推崇 Vim 和 Emacs，却对 IDE 嗤之以鼻？??][vim-ide]

总之，萝卜芹菜各有所爱，有 Geek 精神、喜欢折腾的人不用你去说服，他自然会去学习 Vim，没有心情、懒得折腾的人，你再怎么说 Vim 好，他也不会去尝试 。（是的，我就是喜欢折腾的人 ^_^）

个人选择 Vim 的原因：

+ Vim 是 Linux 的 ”标配“ 编辑器，在 Linux 下开发，不会 Vim 的程序猿不是好程序猿

+ 还是因为 Linux 的原因。大多数 Linux 下的程序都是不需要界面的，终端才是 Linux 的精华，千万不要成迷于界面。在终端下，除了选择 Vim 你说还能选谁呢？ 因为 Vim 和 Linux 的 ”血缘“ 关系，终端 & Vim 给你纯正的 Linux 哲学体验（再说当你远程ssh登录时，总不能还用 IDE 吧？）

+ Vim 下有着高度的编码一致性体验。学会了 Vim，写不同语言不同代码的体验是一样的，妈妈再也不用担心我要花时间学习不同的 IDE 了~

+ 我写的代码基本只限定在底层开发，主要代码是 C/C++、Shell脚本、Python脚本，不会涉及到 JAVA，更不会涉及前端开发；而且都是我的 ”玩具小程序“，几乎不涉及好几百个源文件的项目，所以我不需要 IDE 的强大的管理能力，写一个 makefile 就 OK 了。

+ 学习过 CPU 知识的人都知道，频繁打断流水线才是最影响效率的东西。在调试代码的时候，显然纯键盘流要比不停的 ”鼠标 -> 键盘 -> 鼠标 -> ...“ 有效率的多，而且省事。[](http://www.zhihu.com/question/22096642/answer/20290505)

+ 崇尚 Geek 文化，喜欢 ”折腾“，Linux 哲学教导我要学习轻量级的 Vim，而不是笨重的 IDE 。

### vim & emacs

**来自 wiki 百科：**

[Editor war][Editor war] 是指两类文本编辑器 Vi（以及衍生版本） 和 Emacs 之间的争论，这已经成为 hacker 文化和自由软件社区文化的一部分 。

因为他们都认为自己的选择是完美的，所以相互蔑视，相互之间争论（点燃战火）。相比其他的 IT 领域战争（如浏览器大战、操作系统之争、编程语言之争、代码缩进风格之战)，编辑器的选择其实通常只是个人问题。

**vim 的优点：**

+ 遵循“简单工具，多样组合”的理念。

+ 小，符合Unix哲学中的“只做一件事，并做好它”，避免了功能蔓延。

+ 比Emacs快（至少历史上是这样的）。

+ 可运行于任何实现了C标准库的系统之上，包括UNIX、Linux、AmigaOS、DOS、Windows、Mac、BeOS和POSIX兼容系统等等。

+ 让“QWERTY”键盘用户将手指保持在默认键位上，使编辑时手指移动更少。

+ 更普及。基本上所有Unix和类Unix系统都默认提供了vi或其变体。

**Emacs 的优点：**

+ 符合“厨房水槽”理念，提供了比 vi 更多的功能。

+ 移植最广泛的非试用计算机程序之一。它能在各种操作系统上运行，包括大多数类 Unix 系统（GNU/Linux、各种 BSD、Solaris、AIX、IRIX、AmigaOS、Mac OS X等）、MS-DOS、Microsoft Windows 和 OpenVMS。Unix 系统，无论自由版本或商业版本，均随系统提供 Emacs 。

+ 可扩展和可定制（Lisp的变体 - Emacs Lisp）

**幽默**

[Richard Stallman][Richard_Stallman] 组建了 The Church of Emacs，它称 vi 为 “魔鬼的编辑器”（vi-vi-vi 在罗马数字中表示兽名数目）。然而它并不反对 vi；相反，它视私有软件为诅咒。（“使用自由版本的 vi 不是罪恶，而是赎罪。”）它还有专门的新闻组，alt.religion.emacs，发布主题宣扬这个滑稽的宗教。

Stallman 曾称自己是St IGNU−cius，Emacs教会的圣人。

vi支持者也成立了对立的 Cult of vi，较强硬的 Emacs 的用户攻击这是“抄袭他们的创意”。

关于vi的模式，一些 Emacs 用户说 vi 有两个模式 – “不停地哔哔叫” 和 “搞砸一切”。vi 用户则指责 Emacs 的快捷键会引发 "腕管综合症"，或者拿 EMACS 这个缩写词作文章，比如 “Escape Meta Alt Control Shift”（攻击Emacs太依赖修改键）。一些人断定是代表 “Eight Megabytes And Constantly Swapping”（8 MB，还不断进行内存交换，过去这已经是很多内存了），或者 “EMACS Makes Any Computer Slow”（EMACS使一切计算机跑得慢，这是斯托曼惯用的递归缩写），讽刺Emacs对系统资源的高需求。

针对 Emacs 的“功能蔓延”，vi 支持者认为 Emacs 是 “一个伟大的操作系统，只缺个体面的编辑器”。

UNIX 用户中流行一个游戏，考验一个 Emacs 用户对这个编辑器的理解深度，或者是拿 Emacs 的复杂性开玩笑，内容是：预测一下，如果一个用户按住修改键（比如 Control 或 Alt），然后键入自己的名字，会发生什么事。

[vimshortcut]:http://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim
[vim-ide]: http://www.zhihu.com/question/21504638
[Editor war]: http://en.wikipedia.org/wiki/Editor_war
[Richard_Stallman]: http://en.wikipedia.org/wiki/Richard_Stallman

<br>

## 开始学习 Vim
* * *

闲扯了这么多，终于开始学习 vim 了...

结合我的痛苦的学习过程，至今还在痛苦ing，我觉得以下的学习顺序比较适合我这样的新手：

**入门：**

1. 首先，在终端下输入 vimtutor 就能进入一个 vim 自带的教程，大概花半个小时的时间就能做完。完成以后基本上就可以说是可以使用这款 大(chou)名(ming)鼎(zhao)鼎(zhu) 的 ”反人类“  的编辑器～

2. 学习 陈皓 大神在 [coolshell][coolshell] 的博客 [vim 练级攻略][5426]

3. 同样，[coolshell][coolshell] 上介绍的一个关于 Vim 的游戏 —— [vim adventrue][vim_adventrue]

4. 去图书馆借本书 *[Learning the vi and Vim Editors][Learning_the_vi_and_Vim_Editors]*

**进阶：**

1. 阅读 Vim manpage 和 [安装 vim docs 中文版插件][vim_zh]

2. 一本书 *[Pratical Vim][Pratical_Vim]*

3. Vim 作者 Bram Moolenaar 的文档 *[seven habits for effective text editing][7habits]*  和 [演讲视频][video]

4. [vi/vim使用进阶][advanced-vim-skills]

[coolshell]: http://coolshell.cn/
[5426]: http://coolshell.cn/articles/5426.html
[vim_adventrue]: http://vim-adventures.com/
[Learning_the_vi_and_Vim_Editors]: http://book.douban.com/subject/3041178/
[vim_zh]: https://github.com/asins/vimcdoc
[Pratical_Vim]: http://book.douban.com/subject/10599776/
[7habits]: http://www.moolenaar.net/habits.html
[video]: http://v.youku.com/v_show/id_XMTIwNDY5MjY4.html
[advanced-vim-skills]: http://easwy.com/blog/archives/advanced-vim-skills-catalog/

<br>

## 参考

[vi wikipedia][viwiki]

[Vim wikipedia][Vim]
