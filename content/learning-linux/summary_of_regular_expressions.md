Title: Regular Expression 小结
Category: Linux
Date: 2015-04-27
Tags: regular expression
Slug: summary_of_regular_expression
Author: Qian Gu
Summary:  regular expression 学习笔记

看完了 [Introducing Regular Expressions][book1]，记录一下学习笔记。这本书是非常简单的入门书，一天时间就能看完。作者还推荐了基本进阶书：

[Mastering Regular Expressions][book2]

[Regular Expressions Cookbook][book3]

[Regular Expression Pocket Reference][book4]

[book1]: http://book.douban.com/subject/6959486/
[book2]: http://book.douban.com/subject/1872091/
[book3]: http://book.douban.com/subject/3443904/
[book4]: http://book.douban.com/subject/2363803/

*看完这本书，基本上已经满足项目中简单的 RE 需求，以后需要深入的话，再补这几本书。*

<br>

## What Is a RE?
* * *

引用 Ken Thompson 的话：

> A regular expression is a pattern which specifies a set of strings of characters; it is said
to match certain strings.

<br>

## Basic
* * *
+ metacharacters

    元字符，在表达式中有特殊的含义，也是保留字。一共有 14 个：

        .   // 匹配任意字符
        \   // 对字符转义
        |   // 选择操作（或）
        ^   // 行起始
        $   // 行结束
        ?   // 匹配 0 或 1 次
        *   // 匹配 0 或 多次
        +   // 匹配 1 或 多次
        []  // 字符组符号
        {}  // 量词或代码块符号
        ()  // 分组符号

+ character shorthand

    也叫做 character escape，中文翻译成：“字符组简写” / “转义字符”，常用简写：

        \d      // 数字字符，= [0-9]
        \D      // 非数字字符， = [^0-9]
        \w      // 单词字符
        \W      // 非单词字符
        \s      // 空格
        \n      // 换行
        \r      // 回车
        \b      // 单词边界
        \a      // 报警符
        \cx     // 控制字符

## Simple Match Patterns
* * *

几个常见的模式匹配：

+ string literals

    使用普通字符。

+ digits

        \d      // 简写形式
        [0-9]   // 0~9 任意一个数字
        [1278]  // 限定备选集合为 1，2，7，8

+ non-digits

    *大写的简写形式* 或者 *取反* 即可：

        \D
        [^0-9]
        [^\d]

+ word characters

        \w              // 简写形式
        [a-zA-Z0-9]     // a~z、A~Z、0~9 任意一个字符

+ non-word characters

    *大写的简写形式* 或者 *取反* 即可：
    
        \W
        [^a-zA-Z0-9]
        [^\w]

+ whitespace

        \s
        [ \t\r\n]

+ any characters

        .

<br>

## Boundaries
* * *

+ 行首、行尾

        ^       // 行首
        $       // 行尾

+ 单词边界

        \b      // 单词边界
        \<      // 单词开头
        \>      // 单词结尾

+ 非单词边界

        \B

<br>

## Alternation, Groups, and Backreferences
* * *

+ Alternation

    比如要匹配 THE 或者 The 或者 the，使用如下的语法

        (THE|The|the)

+ Subpatterns

    THE、The、the 是 3 个子模式：

        (THE|The|the)

    括号对于子模式不是必须的：

        \b[tT]h[ceinry]*\b

    可以匹配 the、The、their 等单词，严格意义上中括号内的叫做 字符组 `character classes`，不过因为两者有近似的功能，所以也可以将其做一类。

+ Capturing Groups and Backreferences

    对于括号()内的模式进行捕获，将其存储在临时内存中，然后可以通过后向引用重用已捕获的内容。

    重引用时 `\1`、`$1` 表示对第一个分组的引用；`\2`、`$2` 表示对第二个分组的引用；依次类推。

+ Non-Capturing Groups

    对于之后不会进行引用的分组，可以使用非捕获分组，因为不会对其分配内存所以可以提高性能。

        (?:THE|The|the)

<br>

## Character Classes
* * *

+ Character Classes

    也叫做 方括号表达式，字符组可以帮助我们匹配特定字符或者特定的字符序列：

    匹配特定字符

        [aeiou]         // 匹配元音字符

    匹配特定字符序列：

        \b[1][24680]\b      // 匹配 10～19 之间的偶数


+ Negated Character Classes

    匹配与字符组不匹配的字符，方法就是在开头加上 脱字符 `^`：

        [^aeiou]    // 不想匹配元音字符

+ Union and Difference

    字符组可以像集合一样操作（如求并集、求差集），实际上字符组还有一个名字就叫做 字符集 `character set`。

    并集：

        [0-3][6-9]      // 匹配 0~3 或者 6~9 之间的数字

    差集：

        [a-z&&[^m-r]]   // 匹配 a~z 之间，但是排除 m~r 之间的字符

+ POSIX Character Classes

    `POSIX` (Portable Operating System Interface ) 是 IEEE 维护的一系列标准，格式如下：

        [[: xxxx:]]
        [[:^ xxxx:]]        // 取反匹配

    其中 xxxx 取值为 digit、word 等，举例：

        [[:alnum:]]         // 匹配字母和数字
        [[:alpha:]]         // 匹配大写或小写字母
        [[:ascii:]]         // 匹配 ASCII 范围内的字符

    一般不常用 POSIX 格式。

<br>

## Matching Unicode and Other Characters
* * *

+ Matching a Unicode Character

        /uxxxx      // syntax
        /u00e9      // = character é 
        /u6c60      // = character 池

+ Matching Characters with Octal Numbers

        `\xxx`      // xxx 是 3 位 8 进制数字

    比如 é 也可以用 `\351` 来匹配。

+ Matching Control Characters

        \cx         // x 是想匹配的控制字符
        \c@         // 空字符 0.NUll
        \cG         // 报警字符 BEL
        \cH         // 退格符 Backspcace

<br>

## Quantifiers
* * *

### Greedy, Lazy, and Possessive

量词的属性有 贪婪，懒惰，占有。

+ Greedy

    所谓 “贪婪” 就是说 在匹配前会选定尽可能多的内容，也就是整个输入。然后开始匹配时，会首先匹配整个字符串，如果失败，则回退一个字符，重新匹配（这个过程叫做回溯 backtracking），直到找到匹配的内容或者没有字符可以尝试为止。

    量词的默认属性是贪婪的。

    形象的描述是：它先 “吃” 进所有的字符，然后每次 “吐” 出一点，慢慢咀嚼消化...

    > It takes a mouthful, then spits back a little at a time, chewing on what it just ate.

+ Lazy

    量词的另外一种策略。从待匹配的内容起始位置开始尝试匹配，每次检查字符串的一个字符，寻找匹配内容，最后会尝试匹配整个字符串。

    形象的描述是：它每次只吃一点。

    > It chews one nibble at a time

+ Possessive

    占有量词会抓取整个目标，然后尝试寻找匹配。不过它只尝试一次，不会回溯。

    形象的描述是：它不 “咀嚼” 而是直接 “吞咽”，然后才想知道 “吃” 的是什么。

    > It doesn’t chew; it just swallows, then wonders what it just ate. 

### Basic Quantifiers

+ `?`    匹配 0 或 1 次
+ `+`    匹配 1 或 多次
+ `*`    匹配 0 或 多次

这些量词默认是贪心的，也就是说第一次尝试时会尽可能多地匹配字符。

`.*` 叫做 `Kleene star`，以纪念 RE 的发明人Stephen Kleene。

### Range Syntax

+ `{n}`   精确匹配 n 次
+ `{n,}`  匹配 n 次 或 多次
+ `{m,n}` 匹配 m 至 n 次
+ `{0,1}` 与 `?` 相同（0 或 1 次）
+ `{1,0}` 与 `+` 相同（1 或 多次）
+ `{0,}`  与 `*` 相同（0 或 多次）

### Lazy Quantifiers

懒惰的意思就是匹配尽可能少的字符，它就是个懒虫！它总会找到匹配下限。比如 5*?，它不会匹配任何内容，因为 * 的下限是 0 次；再比如 5+?，它只会匹配 1 个5，因为 + 的下限是 1 次；再比如 5{2,5}?，它只会匹配 2 个 5，因为下限是 2。

+ ?? 
+ +?
+ *?
+ {n}?
+ {n,}?
+ {m,n}?

上面这些加了 ? 的 RE 表示懒惰匹配，也就是 *找下限*。

### Possessive Quantifiers

占有式量词就是贪婪式量词的弱化版，只在第一次进行匹配，如果失败就停止，而不是继续回溯下去。它会将自己的输入

+ ?+
+ ++
+ *+
+ {n}+
+ {n,}+
+ {m,n}+

这些量词后面加了 + 的 RE 表示占有匹配，也就是只检查第一次尝试。

<br>

## Lookarounds
* * *

环视 是一种非捕获分组，它的作用是检查模式的前/后的内容来匹配，也成为 零宽度断言 `zero-width
assertions`。

+ Positive Lookaheads

    正前瞻。 pattern 之后必须紧随着 lookaround 的才会被匹配。

    比如想找到所有之后紧随着一个 marinere 的 ancyent ：

        ancyent (?=marinere)

+ Negative Lookaheads

    反前瞻。对正前瞻的取反，也就是 pattern 之后必须没有 lookarounds 的才会被匹配。

    比如想找到所有后面没有 marinere 的 ancyent：

        ancyent (?!marinere)

+ Positive Lookbehinds

    正后顾。后顾和前瞻的方向相反，检查 pattern 之前的内容，之前有 lookarounds 的 pattern 才会被匹配到。

    比如想找到所有之前有 ancyent 的 marinere：

        (?<=ancyent) marinere

+ Negative Lookbehinds

    反后顾。对正后顾的取反，也就是 pattern 之前必须没有 lookarounds，才会被匹配。

    比如想找到所有之前不存在 ancyent 的 marinere：

        (?<!ancyent) marinere

关于正、反；前瞻、后顾可以用下面的规律记：

**前瞻/后顾：**以 lookarounds 为原点，

+ pattern 在 lookarounds 之前就是 前瞻

+ pattern 在 lookarounds 之后就是 后顾

**正/反：**

+ 如果条件是 lookarounds   存在，就是 正

+ 如果条件是 lookarounds 不存在，就是 负

<br>

了解了这些基础知识，基本上就可以读懂、书写 RE 了，还需要的就是平时多加思考练习，然后看更加高阶的书了。

<br>

## Ref

[Introducing Regular Expressions][book1]