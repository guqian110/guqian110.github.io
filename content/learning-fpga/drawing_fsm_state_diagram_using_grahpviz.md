Title: 利用 Graphviz 画 FSM 状态图
Date: 2015-01-20 17:55
Category: FPGA 
Tags: FPGA, fsm, graphviz
Slug: drawing_fsm_state_diagram_using_graphviz
Author: Qian Gu
Summary: 学习使用 Graphviz 画 FSM 的状态转移图

## Graphviz
* * *

Graphviz 是一个由AT&T实验室启动的开源工具包，用于绘制DOT语言脚本描述的图形。

[wiki][wiki]:

> Graphviz (short for Graph Visualization Software) is a package of open-source tools initiated by AT&T Labs Research for drawing graphs specified in DOT language scripts. It also provides libraries for software applications to use the tools. Graphviz is free software licensed under the Eclipse Public License.

根据介绍，我们知道 Graphviz 基于一种叫做 DOT 的图形描述语言，Graphviz 由一组可以处理 DOT 文件的工具组成，最终生成图形。

既然是画图，那么问题就来了：很多软件都可以画图，**为什么偏偏要用 Graphviz 呢？**

+ Graphviz 的优点：

	1. 不用鼠标绘制，也不用手动调整坐标。使用 Visio 或者其他的画图工具的人都体验过手动对齐的不便，而且很多时候手动调整根本就对不齐，强迫症患者心中永远的痛 T_T

	2. 修改更新方便。手绘的图修改起来很麻烦，而使用 DOT 语言的话，只需要修改脚本就 Ok 了。

+ Graphviz 的缺点：要想用好，需要投入时间和精力去学习使用方法。

Graphviz 可以帮助我们画数据结构图、模块图、流程图等，是程序猿的画图利器。这里我们只用它来画简单的 流程图 / 状态图 ，所以只要有基本的图论知识，不涉及高级主题，所以学习起来是很轻松的。

因为在[前面一篇博客][article1]中我们已经简单介绍了 [Graphviz][graphviz] 这个工具软件的安装方法，所以下面直接进入正题：**如何使用 Graphviz 画 FSM 的状态转移图。**

[article1]: http://guqian110.github.io/pages/2015/01/11/how_to_analyse_code_elegantly.html
[graphviz]: http://www.graphviz.org/
[wiki]: http://en.wikipedia.org/wiki/Graphviz

<br>

## Usage
* * *

下面的内容是我精简出来了的最小学习方法，使用方法的详细攻略请看 Graphviz 官网上的 [Documentation][documentation]。

### DOT

DOT 语法在 [Documentation][documentation] 里面有介绍，它的定义方法和 C/C++ 中的 `struct` 类似。由图论的基本知识，我们知道描述一个图，只要用节点（`node`)、边（`edge`） 这两个要素就能描述清楚，而 DOT 语言也就是利用这两个信息来描述一个图的。下面用几个基本的例子来说明。

1. **无向图**

	由 3 个节点组成的一个无向图。
	脚本（example1.dot）：

		graph example1 {
			node1 -- node2
			node2 -- node3
			node3 -- node4
		}

	结果：

	![example1](/images/drawing-fsm-state-diagram-using-graphviz/example1.png)


2. **有向图**

	还是上面的例子，不过修改为有向图。

	脚本（example2.dot）：

		digraph example2 {
			node1 -> node2
			node2 -> node3
			node3 -> nod31
		}

	结果：

	![example2](/images/drawing-fsm-state-diagram-using-graphviz/example2.png)


3. **添加属性**

	我们还可以控制 node 的属性（节点形状、颜色、边箭头的形状等），来产生不同的结果。

	脚本（example3.dot）：

		digraph example3 {
			node1 -> node2
			node2 -> node3
			node3 -> node1

			node1 [shape = circle, label="state1", fillcolor = "#123456", style = filled]
			node2 [shape = triangle, label="state2", fillcolor = "#345678", style = filled]
			node3 [shape = box, label="state3", fillcolor = "#567890", style = unfilled]
		}

	结果：

	![example3](/images/drawing-fsm-state-diagram-using-graphviz/example3.png)

4. **标注**

	上面的结果和我们的状态转移图相比，还差一点就是转移箭头边上的标注，我们可以在 edge 后面加上 `label` 属性来标注信息。

	脚本（example4.dot）：

		digraph example4 {
			node1 -> node2 [label = "condition1"]
			node2 -> node3 [label = "condition2"]
			node3 -> node1 [label = "condition3"]
		}

	结果：

	![example4](/images/drawing-fsm-state-diagram-using-graphviz/example4.png)

以上的 4 个例子就足够我们画 FSM 的状态转移图了。更加详细的说明参考官方文档和一篇文章：[Graphviz - 用指令來畫關係圖吧！][article2]

### Command

Graphviz 的命令格式为

	cmd [ flags ] [ input files ]

其中，cmd 可以是它包含的几个工具 `dot`、`neato`、`circo`、`fdp`、`osage`、`sfdp`、`twopi`，我们可以查看 man <cmd> 来看它们的区别，也可以直接运行看结果中的区别。

其中，flags 可以设置相关属性，比如 `-Tformat`，如果我们需要产生 PNG 图片，那么这里就应该是 `-Tpng`；再比如 `-o` 设置输出目的地。

所以我们上面 example1 的命令格式为

	dot example1.dot -Tpng -o exampl1.png

example2，example3，exampl4 同理。

[documentation]: http://www.graphviz.org/Documentation.php
[article2]: http://www.openfoundry.org/en/foss-programs/8820-graphviz-

<br>

## Example
* * *

下面是实际程序中的一个例子：

dot 脚本：

    digraph fsm {                                                               
           "a" -> "a" [label= "0/0"]
           "a" -> "b" [label= "1/0"]
           "b" -> "c" [label= "0/0"]
           "b" -> "d" [label= "1/0"]
           "c" -> "a" [label= "0/0"]
           "c" -> "d" [label= "1/0"]
           "d" -> "e" [label= "0/0"]
           "d" -> "f" [label= "1/1"]
           "e" -> "a" [label= "0/0"]
           "e" -> "f" [label= "1/1"]
           "f" -> "f" [label= "1/1"]
           "f" -> "g" [label= "0/0"]
           "g" -> "a" [label= "0/0"]
           "g" -> "f" [label= "1/1"]
    }

使用 dot 生成的结果：


![fsm_dot](/images/drawing-fsm-state-diagram-using-graphviz/fsm_dot.png)

使用 circo 生成的结果：

![fsm_circo](/images/drawing-fsm-state-diagram-using-graphviz/fsm_circo.png)


## Ref

[使用 Graphviz 生成自动化系统图](http://www.ibm.com/developerworks/cn/aix/library/au-aix-graphviz/)

[Graphviz - 用指令來畫關係圖吧！][article2]

[Graphviz使用简介(中文乱码的问题)](http://blog.163.com/prevBlogPerma.do?host=lockriver&srl=487232242010101761749383&mode=prev)

[使用DOT來描述你的狀態機](http://gary-digital.blogspot.com/2006/08/dot.html)
