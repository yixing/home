#std::move的应用

```c++
#include <iostream>
#include <functional>
 
class A {
public:  
    A() { std::cout << __PRETTY_FUNCTION__ << std::endl; _v = 0; }  
    A(const A& a) { std::cout << __PRETTY_FUNCTION__ << std::endl; _v = a._v; }
    void operator=(const A& a) { std::cout << __PRETTY_FUNCTION__ << std::endl; _v = a._v; } 
    void operator=(A&& a) { std::cout << __PRETTY_FUNCTION__ << std::endl; _v = a._v; }   
    A(A&& a) { std::cout << __PRETTY_FUNCTION__ << std::endl; _v = a._v; }
 
private:
    int _v;
};
 
A g_a;
```


​         
```c++
void foo1(A a) { 
    std::cout << __PRETTY_FUNCTION__ << std::endl;
    g_a = std::move(a);
}
 
void foo2(const A& a) {
    std::cout << __PRETTY_FUNCTION__ << std::endl;
    g_a = a;
}
 
int main() {      
    foo1(A()); 
    foo2(A());          
    return 0;
}
```

编译测试运行：

```bash
$ g++ t.cc -std=c++11
$ ./a.out
A::A() # g_a的构造函数
A::A() # foo1(A())的构造
void foo1(A)
void A::operator=(A&&) # move拷贝
A::A() # foo2(A())的构造
void foo2(const A&)
void A::operator=(const A&) # 赋值构造函数
```

可以看到
* foo1(A())这种临时变量只会构造一次，编译器优化掉了参数传递的构造开销
* 相对于foo1()的右值移动赋值，foo2()通过传统的operator=(const A&)赋值构造函数的开销更大
