Title: Yocto 从零单排 1 —— 入门
Date: 2014-05-12 12:46
Category: Linux
Tags: Linux, Yocto
Slug: learning_yocto_from_zero_1_getting_started
Author: Chien Gu
Summary: yocto 从零单排第一期，了解什么是 yocto

最近做嵌入式，开始学习 Yocto 项目相关的知识。网上关于 Yocto 的介绍、博客不少，但是大多数都是英文的。中文博客也有，不过都是一些大牛写的笔记，对于新手来说，并不是很容易懂,于是，就有了我的 “Yocto 从零单排” ^_^

**Yocto 从零单排第 1 期 —— 入门，了解什么是 Yocto**

学习一个新事物，当然是官网的东西最权威最简洁明了，不易出错（避免二次理解），以下内容来自 [Yocto 官网][Yocto Project] 和对其的翻译，本文只是我的学习笔记，详细内容见官网：

**[Yocto Project 官网][Yocto Project]**

[Yocto Project]: (https://www.yoctoproject.org/)

<br>

## What & Why Yocto
* * *

### What is Yocto

官网上的介绍：

> **The Yocto Project is an open source collaboration project that provides templates, tools and methods to help you create custom Linux-based systems for embedded products regardless of the hardware architecture. **

也就是说 *“Yocto 是一个开源协作项目，它通过提供模板、工具和方法来帮助开发者为嵌入式产品订制基于 LInux 的系统，而不用关注硬件结构。”* 这样，它就可以极大地简化开发过程，因为你不用再从头裁剪一个完整的Linux发布版本，后者通常包括许多你并不需要的软件。

它由许多硬件制造商、开源操作系统提供商和电子器件公司一起合作于 2010 年建立，目的是为了使混乱的嵌入式 Linux 开发更简单有序。

*P.S.* Yocto 项目有时也被称为 "Umbrella" 项目

*P.P.S.* yocto 的名字是委员会决定的，这个词本来是国际单位中的最小的单位，表示 10^-24，也就是千万亿分之一，在此寓意 “基本的粒子” —— 贯穿嵌入式 Linux 开发过程的工具。

### Why using Yocto

它是一个完整的嵌入式 Linux 开发环境，包含工具(tools)、元数据(metadata)和文档(documentation)——你需要的一切。这些免费工具(包含仿真环境emulation environments、调试器debuggers、应用程序开发工具Application Toolkit Generator)很容易上手，功能强大，并且它们可以让系统开发以最优化的方式不断前进，而不用担心在系统原形阶段的投资损失。

<br>

## Yocto Project Charter 
* * *

Yocto 作为一个开源项目，其本质就是欢迎大大小小的参与者。

Yocto 的目标：

+ 为进一步的开发、定制 LInux 平台，基于 Linux 系统的开发提供一个写作平台
+ 鼓励 Linux 平台开发的标准化和组建的重利用
+ 专注于创造一个构建系统的基础设施和技术，能够满足所有用户的需求，并增加了缺失的功能——来自于 OpenEmbedded 架构
+ 文档化可以用到的工具和方法，使开发人员更容易使用它们
+ 尽可能地保证这些开发工具和系统架构无关
+ ...

<br>

## Governance &  Administration
* * *

Yocto 是一个开源项目，它由维护者和 [Yocto Project Advisory Board][Yocto Project Advisory Board] 领导。

### Technical Leadership

Yocto 项目的 [technical leadership][technical-leadership] 和 Linux Kernel 的类似，是一个分级的、任人唯贤的，由一个 “仁慈的独裁者”(benevolent dictator) 领导的组织。组织的上层负责决策，同时也是下层子系统的领导者，下层维护者负责处理细节问题，比如bug 和补丁。

Yocto 项目架构师：Richard Purdie

子系统/ BSP 层维护者：...


### The Yocto Project Community

Yocto 是由社区的专家和志愿者共同协助设计、开发的，他们统称为贡献者(contributors)，贡献者包括任何可能对 Yocto 有贡献的人，比如代码开发人员、文档编写者、兴趣小组、管理小组、维护者和技术领导小组等。

下图简明说明了 Yocto 项目社区的各个成员之间的相互影响的关系：

![yocto-community](https://www.yoctoproject.org/sites/yoctoproject.org/files/page/os63yoctodev.org-diagramv11.png)

[Yocto Project Advisory Board]: (https://www.yoctoproject.org/about/governance/advisory-board)
[technical-leadership]: (https://www.yoctoproject.org/about/governance/technical-leadership)

<br>

## Linux Foundation
* * *

[Linux Foundation][Linux Foundation] 是一个致力于促进 Linux 发展的非盈利组织，关于它的主要事实：

+ 赞助 Linux 的创造者 Linus Torvalds 的工作
+ 持有 Linux 商标
+ 经营着 Linux.com，每个月拥有活跃的 2000,000 的 Linux 开发人员和用户 
+ 主持着多个推进或标准化 Linux 的工作小组
+ 举行世界上顶尖的 Linux 会议，包括 LinuxCon

### The Linux Foundation and the Yocto Project

Linux Foundation 是业界最大的非盈利组织，作为 Linux 的维护者和 Linux 创造者 Linus Torvalds 的雇主，没有比它更适合 Yocto 项目生存的了。Linux Foundation 主持 Yocto 项目作为一个开源项目，它提供了一个厂商中立的协作环境。

[Linux Foundation]: (http://www.linuxfoundation.org/)

<br>

## Yocto Project 简介
* * *

Yocto 项目中有很多独立的子项目，这些子项目在嵌入式 Linux 开发中扮演着重要的角色，Yocto 项目则整合它们使它们可以相互协同工作。

### Openembedded Core

**Metadata Set**

元数据集(Metadata Set) 按 "层" 进行排列，这样一来每一层都可以为下面的层提供单独的功能。基层是 OpenEmbedded-Core 或 oe-core，提供了所有构建项目所必需的常见配方(recipes)、类和相关功能。

Openembedded Core 包含了 核心方法(recipes)的基础层、类(classes) 和 相关文档，它们是各种嵌入式 Linux 系统(包含 Yocto 在内)的共同基础。Openembedded Core 由 Yocto Project 和 OpenEmbedded 项目共同维护，将 Yocto 和 Openembedded 分开的层是 meta-yocto 层，该层提供了 Pocky 发行版配置和一组核心的参考BSP。

Openembedded 项目本身是一个ie独立的开源项目，具有可与 Yocto 项目交换的配方(recipes)，但两者具有不同的治理和范围。

### Swabber

Swabber 可以提供一种检测主机系统的机制，一旦检测到问题，你就可以分析这是否真的是个问题。

### Application Development Toolkit (ADT)

Application Development Toolkit (ADT) 能够让系统开发人员为他们使用 Yocto Project 工具创建的发行版提供软件开发工具包 (SDK)，为应用程序开发人员提供了一种针对系统开发人员提供的软件栈进行开发的方法。ADT 包含一个交叉编译工具链、调试和分析工具，以及 QEMU 仿真和支持脚本。ADT 还为那些喜欢使用集成开发环境 (IDE) 的人提供了一个 Eclipse 插件。

### AutoBuilder

AutoBuilder 是一款能够不断自动构建 Yocto 的工具，它启用自动化的 Quality Assurance(QA) 活动。

### BitBake

BitBake 是一个构建引擎。它读取配方(recipes)并按照配方来获取、构建程序包，并将结果导入可启动的系统映像中。BitBake 是 Yocto 项目的核心组件。

### Build Appliance

Build Applicance 是一台运行 Hob 的虚拟机，它可以让你在非 Linux 环境下构建启动一个基于 Yocto 的嵌入式系统镜像。并不建议在日常开发中使用 Build Applicance，应该将其用在测试和体验 Yocto 项目上。

### Cross-Prelink

Cross-Prelink 为交叉编译开发环境提供预链接，这样可以在应用程序启动时提高其性能表现。

### Eclipse IDE Plug-in

Eclipse IDE Plug-in 把 Yocto ADT 和工具链集成到 Eclipse IDE 中。

### EGLIBC

Embedded GLIBC (EGLIBC) 是 GNU C Library (GLIBC) 的一个变体，旨在能够在嵌入式系统上运行。EGLIBC 的目标包括减少内存占用、让组件可配置、更好地支持交叉编译和交叉测试。EGLIBC 是 Yocto Project 的一部分，但在它自己的治理结构内加以维护。

### Hob

Hob 是 BitBake 的图形前端，它的主要目的是使常用命令更加方便使用。

### Matchbox

Matchbox 是 一个基于 X Window 系统的开源环境，主要用于非桌面系统、屏幕大小、输入方式或系统资源有限的嵌入式设备中，比如手持设备、机顶盒、电话亭等。

### Poky

Poky 是 Yocto Project 的一个参考构建系统。它包含 BitBake、OpenEmbedded-Core、一个板卡支持包 (BSP) 以及整合到构建过程中的其他任何程序包或层。Poky 这一名称也指使用参考构建系统得到的默认 Linux 发行版，它可能极其小 (core-image-minimal)，也可能是带有 GUI 的整个 Linux 系统 (core-image-sato)。

你可以将 Poky 构建系统看作是整个项目的一个参考系统，即运行中进程的一个工作示例。在下载 Yocto Project 时，实际上也下载了可用于构建默认系统的这些工具、实用程序、库、工具链和元数据的实例。这一参考系统以及它创建的参考发行版都被命名为 Poky。你还可以将此作为一个起点来创建您自己的发行版，当然，你可以对此发行版随意命名。

构建一个系统必须有工具链(toolchain)：一个编译器(compiler)、汇编器(assembler)、链接器(linker)以及为给定架构创建二进制可执行文件所需的其他二进制实用程序(other binary utilities)。Poky 使用了 GNU Compiler Collection (GCC)，不过你也可以指定其他工具链。Poky 使用了一种名为交叉编译(cross-compilation) 的技术：在一个架构上使用工具链为另一个架构构建二进制可执行文件（例如，在基于 x86 的系统上构建 ARM
发行版）。开发人员常常在嵌入式系统开发中使用交叉编译来利用主机系统的高性能。

### Pseudo

构建一个系统时，有时候有必要把自己模拟为系统管理员进行一些操作，比如定义某个文件的归属权和权限配置等。Pseudo 是一个可以模拟 root 的程序，使普通用户也可以具有 root 权限。

### Toaster

Toaster 是一个 API，它基于 web 界面来使用 BitBake，你可以通过浏览器来查阅 Toaster 收集到的你的系统的相关信息。

<br>

## 参考

<br>

[Yocto Project 官网][Yocto Project]

[Build custom embedded Linux distributions with the Yocto Projec](http://www.ibm.com/developerworks/linux/library/l-yocto-linux/index.html?ca=dat)
