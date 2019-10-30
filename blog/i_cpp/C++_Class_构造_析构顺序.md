t.cc:
```
    #include <iostream>

    class B {
    public:
        B() { std::cout << __PRETTY_FUNCTION__ << std::endl; }
        ~B() { std::cout << __PRETTY_FUNCTION__ << std::endl; }
    };

    class C {
    public:
        C() { std::cout << __PRETTY_FUNCTION__ << std::endl; }
        ~C() { std::cout << __PRETTY_FUNCTION__ << std::endl; }
    };

    class A {
    public:
        A(const std::string& name) : _name(name) { std::cout << _name << " " << __PRETTY_FUNCTION__ << std::endl; }
        ~A() { std::cout << _name << " " << __PRETTY_FUNCTION__ << std::endl; }
        A& operator=(const A& oth) {
            _name = oth._name;
            std::cout << _name << " " << __PRETTY_FUNCTION__ << std::endl;
            return *this;
        }

        A(const A& oth) {
            _name = oth._name;
            std::cout << _name << " " << __PRETTY_FUNCTION__ << std::endl;
        }

    private:
        B b;
        C c;
        std::string _name;
    };

    int main() {
        A a("first");

        A b = A("second");

        A d(a);
        std::cout << "done" << std::endl;
    }
```

```
    g++ t.cc -o test
    ./test
```

output
``` 
    B::B()
    C::C()
    first A::A(const std::string &)
    B::B()
    C::C()
    second A::A(const std::string &)
    B::B()
    C::C()
    first A::A(const A &)
    done
    first A::~A()
    C::~C()
    B::~B()
    second A::~A()
    C::~C()
    B::~B()
    first A::~A()
    C::~C()
    B::~B()
```
