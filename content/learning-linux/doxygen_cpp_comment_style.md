Title: 基于 Doxygen 的 C++ 注释风格
Date: 2015-01-13
Tags: Linux, C++, comment style
Sluge: doxygen_cpp_comment_style
Author: Qian Gu
Summary: 总结基于 Doxygen 的 C++ 注释规则

本文内容参考自网上博客内容

[C++标准注释原则 - 基于doxygen的C++注释][blog1]

[Doxygen C++注释规范及生成帮助文档配置步骤][blog2]

[Doxygen详细介绍（三）（Doxygen注释风格）][blog3]

重新整理排版了一下。写本文的主要目的是备忘，当作快速参考来查。

<br>

## Doxygen
* * *

若想用 Doxygen 生成漂亮的文档，我们必须在以下几个地方添加 Doxygen 风格的注释：

1. 文件头（包括 头文件 .h 和 源文件 .cpp）

    主要用于版权声明，描述本文件的功能，以及作者、版本信息等。

2. 类的定义

    主要用于描述类的功能，同时也可以包含使用方法、注意事项的 brief description。

3. 类的成员变量定义

    对该成员变量进行 brief description。

4. 类的成员函数定义

    对该成员函数的功能进行 brief description。

5. 函数实现

    对函数的功能、参数、返回值、需要注意的问题、相关说明等进行 detailed description。

<br>

## C++ Comment Style
* * *

Doxygen 支持多种注释风格，比如 JavaDoc-like 风格，Qt 风格等。在写 C++ 代码时，我们应该遵守 C++ 的行注释风格，所谓行注释风格，是指一般 C++ 程序员避免使用 C 风格的注释符号 `/* */`，而是使用 3 个连续的 `/` 作为注释的开头。除了这个区别之外，其他部分和 JavaDoc 风格类似：

+ 一个对象的 brief description 用单行的 `/// ` 开始，并且写在代码前面。一般 brief 写在头文件中，对象的声明之前。

+ 一个对象的 detailed description 用多于两行的 `/// ` 开始，并且写在代码前面。如果注释长度不足两行，第二行的开头仍要写出。一般 detailed 写在源文件中，对象的定义之前。

+ 如果一段代码既是声明也是定义，则 brief 和 detailed 写在一起。使用 `\brief` 命令，并且使用空行将两者分开。一般 brief 写在头文件中，对象的声明之前。

        /// \brief A brief description.
        ///
        /// A detailed description, it
        /// should be 2 line at least.

下面是代码模板：

### License

使用 DoxygenToolKit 自动生成的 Lisence 即可。

## File header
* * *

    /// \file file_name.h
    /// \brief Head file for class Ctest.
    /// 
    /// A detailed file description.
    ///
    /// \author author_name
    /// \version version_number
    /// \date xxxx-xx-xx

### Namespace

namespace 的注释方式：

    /// \brief A brief namespace description.
    ///
    /// A detailed namespace description, it
    /// should be 2 lines at least.
    namespace test
    {

    }

### Class

class 的定义和声明都在头文件中，所以使用下面这种 brief 和 detailed 结合的方式：

    /// \brief A brief class description.
    ///
    /// A detailed calss description, it
    /// should be 2 lines at least.
    class test
    {

    }

#### member function

对于成员函数，

+ 若是在头文件的声明处，使用 brief

+ 若是在源文件的定义处，使用 detailed

+ 若是在头文件处，声明和定义重合，使用 brief + detailed

#### member variable

对于成员变量，在行末使用 `///< `。

### Function

**brief:**

单行的 `/// ` 注释：

    /// A brief function description.

**detailed:**

至少两行 `/// ` 的注释：

    /// This is the detailed description, it
    /// should be 2 lines at least.

在 detailed description 中还可以添加一些 `structural command`，常用的有 `\param`、`\return`、`\see`、`\note`、`\warning` 等：

    /// This is the detailed description, it
    /// should be 2 lines at least.
    ///
    /// \param p1 Brief description for p1
    /// \param p2 Brief description for p2
    /// \return Brief description for return value
    /// \note something to note.
    /// \warning Warning.
    /// \see See-also

**brief + detailed:**

如果函数声明和定义重合，则 brief 和 detailed 合在一起，并且使用 `\brief` 命令，格式如下：

    /// \brief A brief function description.
    /// 
    /// A detailed description, it
    /// should be 2 lines at least.
    ///
    /// \param p1 Description for p1.
    /// \param p2 Description for p2.
    /// \return Description for return value.
    bool test(int n1, char c1);

在 Doxgyen 的 manual 里面有：

> Unlike most other documentation systems, doxygen also allows you to put the documentation of members (including global functions) in front of the definition. This way the documentation can be placed in the source file instead of the header file. This keeps the header file compact, and allows the implementer of the members more direct access to the documentation. As a compromise the brief description could be placed before the declaration and the detailed description before the member definition.

Doxygen 允许注释出现在对象的定义之前，所以我们可以将注释写在源文件中，而不是头文件中。这样做的好处是使头文件更加紧凑、代码的实现者阅读起来也更加直观。所以我们采用的方案是：

+ 在函数声明前写 brief，在函数定义前写 detailed。

+ 对于 inline 函数，使用 brief，尽量保持简洁，不要多于一行。

### Variable

变量一般使用 `///< ` 方式即可：

    int m_a; ///< brief description for variable m_a
    double m_b;  ///< brief description for variable m_b

如果需要进行详细描述，则采用类似函数注释的方法（brief + detailed）：

    /// \brief A brief description.
    ///
    /// A detailed description, it
    /// should be 2 lines at least.
    float m_c;

### Enum & Struct

类似于 Variable 的注释方式：

    /// \brief A brief description.
    /// 
    /// A detailed description, it
    /// should be 2 lines at least.
    enum Tenum {
        em_1; ///< enum value em_1
        em_2; ///< enum value em_2
        em_3; ///< enum value em_3
    }
    emVar; ///< enum variable.

### Others

TODO 命令：

    /// \todo Task1 to do
    /// \todo Task2 to do

BUG 命令：

    /// \bug Bug1 to be fixed
    /// \bug Bug2 to be fixed

<br>

**P.S.**

从网上找到一个Doxygen for C 的示例：

[Doxygen usage example (for C)][doxgen_c]

里面有一些注释方法很有借鉴意义，可以当作模板来用。

**P.P.S**

又找到一份注释规范的文档，写的挺好，值得一看。

[C++注释规范](/file/cpp_comment_standard.doc)

<br>

## Ref

[blog1]: http://blog.csdn.net/czyt1988/article/details/8901191

[blog2]: http://blog.sina.com.cn/s/blog_6294abe701012pee.html

[blog3]: http://ticktick.blog.51cto.com/823160/188674

[doxygen_c]: http://fnch.users.sourceforge.net/doxygen_c.html

