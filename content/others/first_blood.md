Title: First Blood
Date: 2014-03-17 14:29
Category: Misc
Tags: Build Blog
Slug: first_blood
Author: Chien Gu
Summary: 利用 Markdown + Pelican + Github 搭建属于自己的博客


## 为什么要搭建自己的博客
* * *

首先，来看看各类门户博客的优缺点。

国内大多数人的朋友圈都聚集在 QQ、微博、人人等社交平台上。但是这些社区并不适合写博客，面对满屏幕毫无营养的转载文章和五颜六色的广告，谁还有兴趣把自己的生活感悟写下来？其实，我们需要的仅仅是一方可以写字的净土。至于各大技术博客平台，它们明显不适合用来记录生活中的点滴琐事。CSDN 的博客系统一直是人们的吐槽对象，况且，CSDN 已经沦为学生求作业的地方，很多大神都转移阵地，去搭建自己的博客了。

既然这些平台都不能满足我们的需求，为什么我们不搭建一个属于自己的博客呢？

我们写博客是为了记录自己的学习、生活和成长，寻找志同道合的知己。个人博客也是一种身份，代表了博主的兴趣爱好和品味。我们自己是博客的主人，可以自己定制主题和内容，而无需经受别人的审核和莫名删除的烦恼。

<br/>

##为什么选择 Markdown + Pelican + GitHub
 * * *
 
不同于面向 *发布* 的 `Html` 语言，`Markdown` 是一种面向 *书写* 的语言，其目的就是让文档更容易写和读，让人们不再为 `Html` 繁琐的标签烦恼。
 
搭建个人博客最方便也最简易的方式就是采用 `WordPress` 平台。但是，简易也意味着无脑、不能随行所欲地定制。我们只是需要一个写字的地方，显然 `WordPress` 太臃肿，用来生成静态博客的 `Pelican` 才是我们的最佳选择。

`Github` 是一个共享虚拟主机服务，用于存放使用 `Git` 版本控制的软件代码和内容项目。——by [Wikipedia][Wiki]

所以我们只要采用 `Markdown` 写下我们的博客内容，用 `Pelican` 生成静态网页，然后将其托管到`GitHub` 上，就大功告成了！

折腾了几天，终于在 [Google][G] 和以下几篇博客的帮助下，初步搭建好了个人的小窝。

<br>

[一步一步打造Geek风格的技术博客][blog1]

[使用Pelican和GitHub Pages搭建个人博客 —— 基础篇][blog2]

[用 Pelican 和 GitHub Pages 搭建免费的个人博客][blog3]

[博客诞生记:基于GitHub+Pelican创建博客的整个过程][blog4]

[Wiki]: http://zh.wikipedia.org/wiki/GitHub
[G]: https://www.google.com.hk
[blog1]: http://www.lizherui.com/pages/2013/08/17/build_blog.html
[blog2]: http://www.xycoding.com/articles/2013/11/21/blog-create/
[blog3]: http://www.dongxf.com/3_Build_Personal_Blog_With_Pelican_And_GitHub_Pages.html
[blog4]: http://frantic1048.com/bo-ke-dan-sheng-ji-ji-yu-githubpelicanchuang-jian-bo-ke-de-zheng-ge-guo-cheng.html

<br>

##如何搭建
* * *

本博客就是在参考以上 4篇博客的教程 + [Google][G] ，在 `Ubuntu 13.10` 下完成的，十分感谢各位博主的分享。在搭建过程中遇到了不少问题，但是在万能的 Google 面前，都一切都不是问题，同时我也学习到了不少知识。

详细的搭建过程参考以上4篇博客，不再赘述，下面总结一下自己安装过程中遇到的问题吧。

###学习流程

+ 学习 `Git`

    [Git Refence][Gitref]
    
    [Pro Git][PG]
    
    [GitHub help][GH]
    
+ 安装、学习使用 `Pelican` 搭建博客骨架

    [Pelican Source Code][PS]
    
    [Pelican Doc][PD]
    
+ 学习 `Markdown` 语法，写博客内容

    [Markdown语法][M]
    
    [Markdown 编辑器 Retext][R]

+ Pelican theme</code> 修改

    [Pelican theme setting][Psetting]
    
[Gitref]: http://gitref.org/
[PG]: http://git-scm.com/book
[GH]: https://help.github.com/
[PS]: https://github.com/getpelican/pelican
[PD]: http://docs.getpelican.com/en/latest/
[M]: http://wowubuntu.com/markdown/#hr
[R]: http://sourceforge.net/projects/retext/
[Psetting]: http://docs.getpelican.com/en/latest/settings.html#themes

###问题总结

1. 一种安装方式不成功时，可以试试其他方法。使用命令行安装 `Pelican` 时，由于学校的渣网速，我安装了好几遍都 *time_out*

2. 必须先安装 `Pelican`，后安装 `Markdown`，否则在生成网页时会报错，不能识别 `.md` 文件

3. 运行 `pelican-quickstart` 时，有些选项是可以在 `pelicanconf.py` 中修改的，有些不行 。比如是否启用文章分页，是不能通过后期修改的，如果第一次没有启用，在 pelicanconf.py 中直接修改会报错，只能保存好文章、下载的主题和配置文件，重新用向导生成博客框架 。

4. 由于薄弱的 `Html` 知识， `Pelican theme` 的修改花费了很多时间 (Orz...)

<br>

* * *

总之，既然搭建好了博客，就要坚持认真写下去，记录下生活中的每一点一滴。
