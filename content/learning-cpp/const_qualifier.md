Title: C++ const 限定符
Date: 2014-04-09 11:13
Category: C/C++
Tags: C,C++
Slug: cosnt_qualifier 
Author: Chien Gu
Summary: 总结 const 限定符的用法。

## 为什么要使用 const 限定符
* * *

### 一个需要使用 const 的简单例子

[*C++ Primer*][cpp-primer] 中的例子

```C++
    for (int index = 0; index != 512; ++index) {
        // ...
    }
```

这段代码语法上是没有问题的，但是事实上是有两个小问题的，而且两个小问题都和数字 `512` 有关 。

**第一个问题是 程序的可读性**

比较 `index` 与 `512` 有什么意思呢？也就是说 512 这个值作用何在？在程序中这种数字被称为 `魔数（magic number）`，它的意义在上下文中没有体现出来，好像这个数是凭空魔术般变出来的 。

**第二个问题是 程序的可维护性**

如歌这个程序非常庞大，512 这个数字出现了 100 次，进一步假设这 100 次中，有 80 次是表示某个缓冲区的大小，剩余 20 次用于其他目的 。现在，我们需要把缓冲区的大小增大到 1024，要实现这个目标，必须检查每个 512 出现的位置，必须确定哪些是表示缓冲区大小，哪些不是 。

解决这两个问题的方法是定义一个变量，并且初始化为 512

```C++
    int buf_size = 512;
    for (int index =0; index != buf_size; ++index) {
        //...
    }
```

通过定义一个好记的变量，就可以增强程序的可读性，而且需要改变这个值时，只需要咋初始化的地方做修改 。这种方法不仅明显减小了工作量，而且大大减小了出错的可能性 。

*看起来问题好像已经解决了，但是，事实上，我们可以进一步*

在上面的代码中，`buf_size` 是可以被修改的，它有可能会被有意或者无意修改 。为了避免这种情况，就需要使用 const 限定符了 。

```C++
    const buf_size = 512;
```

定义 `buf_size ` 为 **常量（constant）**，并且初始化为 512 .**变量（variable）** `buf_size` 仍然是一个左值，但是这个左值现在是不能被修改的。（因为 const 把变量转化为常量，所以在定义的时候必须初始化！）

[cpp-primer]: http://book.douban.com/subject/1767741/

<br>

## 如何使用 const 限定符
* * *

C++ Primer 中有这么一句话

> It (const) transforms an object into a constant.

但是在这句话之后有说

> The variable bufSize is still an lvalue

这是矛盾的，因为常量是不能当左值的 。个人感觉严谨的说法应该是 "cosnt 是变量具有了常量的属性“

### 文件的局部变量

const 限定符修同时也改变了变量的作用范围 。普通非 const 变量的默认是具有 *外部连接（external linkaage）*的，在全局作用域内定义非 const 变量时，它在整个程序中都可以被访问 。比如

```C++
    // file1.cpp
    int counter;
   
    //file2.cpp
    extern int counter;
    ++counter;
```

但是，对于 全局作用域内的 const 类型的对象，其默认是 *内部连接（internal linkage）*，仅在定义该对象的文件内可见，不能被其他文件访问 。要想在整个程序里面访问，就必须在定义的时候显式地声明为 `extern` 类型 。比如

```C++
    //file1.cpp
    extern int buf_size = fcn ();
    
    //fiel2.cpp
    extern const int buf_size;
    for (int index = 0; index != buf_size; ++index)
        //...
```

### 使用 const 的方法

+ 定义在头文件中 inlcude

    如果 const 变量是用常量表达式初始化的，那么就可以把它的定义放在头文件中，即使多次包含这个头文件也不会产生 ”重定义“  的问题 。
    
    ```C++
        // file1.h
        const int bufsize = 512;
        
        // file2.cpp
        include "file1.h"
        int size = bufsize
    ```

+ 定义时声明为 extern

    如果 const 变量不是用常量表达式初始化的，那么就不能把它当在头文件中 。只能在源文件中定义并初始化 。因为 const 变量是文件局部变量，所以要在其他文件中使用该变量，必须在定义时加上 `extern` 声明 。
    
    比如
    ```C++
        // file1.cpp
        extern const int bufsize = 512;
    ```
    + 在头文件中声明为 extern 类型，以使其他文件共享。
    
        ```C+
            // file1.h
            extern const int bufsize;
            
            // fil2.cpp
            #include "file1.h"
            int size = bufsize;
        ```

    + 不需要在头文件中声明，在其他文件中使用前声明

        ```C++
            // file2.cpp
            extern const int bufsize;
            int size = bufsize;
        ```

**P.S.** 在 C 中 const 是默认为外部连接的，在 C++ 中是默认为内部连接的 。

至于为什么要这么规定，[Thinking in C++][Thinking in C++] 中有说明

> Constants were introduced in early versions of C++ while the Standard C specification was
still being finished. It was then seen as a good idea and included in C. But somehow, const in
C came to mean “an ordinary variable that cannot be changed.” *In C, it always occupies
storage and its name is global. The C compiler cannot treat a const as a compile-time
constant.* In C, if you say
>    
>       const bufsize =100;
>       char buf[bufsize];
>
> you will get an error, even though it seems like a rational thing to do. Because bufsize
occupies storage somewhere, the C compiler cannot know the value at compile time.
>
> In C++, a const doesn’t necessarily create storage. In C a const always creates storage.
Whether or not storage is reserved for a const in C++ depends on how it is used. In general, if
a const is used simply to replace a name with a value (just as you would use a #define), then
storage doesn’t have to be created for the const. If no storage is created (this depends on the
complexity of the data type and the sophistication of the compiler), the values may be folded
into the code for greater efficiency after type checking, not before, as with #define. If,
however, you take an address of a const(even unknowingly, by passing it to a function that
takes a reference argument) or you define it as extern, then storage is created for the const.
>
> Since a const in C++ defaults to internal linkage, you can’t just define a const in one file and
reference it as an extern in another file. To give a const external linkage so it can be
referenced from another file, you must explicitly define it as extern, like this:
>
>       extern const int x = 1;
>
> Notice that by giving it an initializer and saying it is extern, you force storage to be created for the const(although the compiler still has the option of doing constant folding here). The
initialization establishes this as a definition, not a declaration. The declaration:
>
>       extern const int x;
>
> in C++ means that the definition exists elsewhere (again, this is not necessarily true in C).
*You can now see why C++ requires a constdefinition to have an initializer: the initializer
distinguishes a declaration from a definition (in C it’s always a definition, so no initializer is
necessary).* With an external constdeclaration, the compiler cannot do constant folding
because it doesn’t know the value.

[Thinking in C++]: http://book.douban.com/subject/1459728/

### const 引用 & const 对象

在引用的定义中声明 const，此 const 约束的是引用，而不是引用的对象 。比如

```C++
    const int &ref = ival
```

其中，`const` 修饰的是 `int &`，规定了引用 `ref` 为 const 类型变量，而 `ival` 的类型则由其他语句定义说明 。

**const 引用： 引用变量为 const 类型，引用对象的类型可以是 const、nonconst、r-value**

**nonconst 引用： 引用变量为 nonconst 类型，引用对象只能是同类型的 nonconst 类型**

因为引用只是对象的另外一个名字，它们指向的是统一块内存空间，所以通过修改引用的值就能达到修改对象的值的目的 。

当对象是 const 类型时，隐含的含义是该对象不能被修改，所以只能定义 const 类型的引用指向它；nonconst 类型的引用隐含的意思是可以通过引用修改对象值，这对于 const 类型的对象来说是不允许的 。

当对象是 nonconst 类型时，隐含的含义是该对象可以通过引用来修改，此时，const 引用和 nonconst 引用都可以指向该对象 。当使用 nonconst 引用时，可以通过引用修改对象的值；当使用 const 引用时，虽然对象的值是可以改变的，但是不能通过该引用修改，因为引用的类型是 const，定义以后，不能再修改 。 

<br>

##何时应该使用 const
* * *

Scott Meyers 大神的经典著作 [Effective C++][Effective C++] 里面提到的关于 const 的使用 。

### Effective C++ 条款 02：尽量以 const、enum、inline 替换 #define（Prefer consts,enums,and inline to #define）

使用const 代替 #define，事实上 `const` 的最初动机就是取代预处理器 `#define` 来进行值替代 。因为 #define 不被视为语言的一部分，这就是它的问题所在 。

```C++
    #define ASPECT_RATIO 1.653;
```

记号名 ASPECT_RATIO 也许从未被编译器看见，也许在编译器开始处理代码前就被与处理器移走了，于是记号没有进入记号表，当出现编译错误时，也许会提示是 1.653 而不是 ASPECT_RATIO，这回带来很多困惑 。

解决之道就是以一个常量代替上述的宏

```C++
    const double AspectRatio = 1.653;
```

### Effective C++ 条款 03：尽可能使用 const（Use const whenever possile）

[Effective C++]: http://book.douban.com/subject/1842426/

<br>

## 参考

[C++ Primer][cpp-primer]

[Thinking in C++][Thinking in C++]

[Effective C++][Effective C++]
