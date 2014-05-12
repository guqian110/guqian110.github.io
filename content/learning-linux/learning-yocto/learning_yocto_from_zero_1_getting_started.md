Title: Yocto 从零单排 1 —— 入门
Date: 2014-05-12 12:46
Category: Linux
Tags: Linux, Yocto
Slug: learning_yocto_from_zero_1_getting_started
Author: Chien Gu
Summary: yocto 从零单排第一期，了解什么是 yocto

最近做嵌入式，开始学习 Yocto 项目相关的知识。网上关于 Yocto 的介绍、博客不少，但是大多数都是英文的。中文博客也有，不过都是一些大牛写的笔记，对于新手来说，并不是很容易懂,于是，就有了我的 “Yocto 从零单排” ^_^

**学习一个新事物，当然是官网的东西最权威最简洁明了，不易出错（避免二次理解），以下内容来自 [Yocto 官网][Yocto Project] 和对其的翻译，本文只是我的学习笔记，详细内容见官网：**

**[Yocto Project 官网][Yocto Project]**

[Yocto Project]: (https://www.yoctoproject.org/)

<br>

## What & Why Yocto
* * *

### What is Yocto

官网上的介绍：

> **The Yocto Project is an open source collaboration project that provides templates, tools and methods to help you create custom Linux-based systems for embedded products regardless of the hardware architecture. **

也就是说 *“Yocto 是一个开源协作项目，它通过提供模板、工具和方法来帮助开发者为嵌入式产品订制基于 LInux 的系统，而不用关注硬件结构。”* 这样，它就可以极大地简化开发过程，因为你不用再从头裁剪一个完整的Linux发布版本，后者通常包括许多你并不需要的软件。

它由许多硬件制造商、开源操作系统提供商和电子器件公司一起合作于 2010 年建立，目的是为了给混乱的嵌入式 Linux 开发更简单有序。

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

## 参考

[Yocto Project 官网][Yocto Project]
