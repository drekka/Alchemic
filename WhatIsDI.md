# What is Dependency Injection (DI) and why would I want to use it?

This question comes up quite often when I'm talking about DI frameworks to developers who have never used them. So this document is an attempt to answer it with a bias towards Objective-C programming.

## Understanding the problem

[Object Orientated Programming (OOP)](https://en.wikipedia.org/wiki/Object-oriented_programming) is based on the idea of a collection of objects all working together to create an application. For example, if my *RemoteControl* class needs to change the channel on a TV, it needs a *TV* object to change the channel on. This is what is called a *"dependency"*. So *RemoteControl* has a dependency on a *TV* object.

Dependencies are usually located in one of two ways: either the code has to *"reach out"* to find it's dependencies, or they are *"injected"* into the code where they are needed.

### Reaching out - Singletons

One solution that is (over!) used in Objective-C projects is the [Singleton pattern](https://en.wikipedia.org/wiki/Singleton_pattern). The singleton pattern is for when your app only needs a single instance of a class. This instance is created by it's own class and accessible as a class method. This means that it can be accessed anywhere in the app.

*TV.h*

```objectivec
@interface TV : NSObject
+(TV *) sharedTV;
@end
```

*RemoteControl.m*

```objectivec
@implementation RemoteControl
-(void) changeChannelTo:(int) newChannel {
    TV *tv = [TV sharedTV];
    [tv changeToChannel:newChannel];
}
@end
```

The main design issue with singletons (IMHO) is that in order to get a reference to them, your code has to find or create them itself. Plus the typical code used to created them renders them almost immpossible to swap out when you need to test the code that uses them. Singletons also tend to be overused by developers because they are an *easy* solution to dealing with dependencies, requiring little code to access from anywhere.

My general opinion is - *Use [singletons](https://en.wikipedia.org/wiki/Singleton_pattern) sparingly where you really need them.* 

### Dependency Injection

The [Dependency Injection (DI)](https://en.wikipedia.org/wiki/Dependency_injection) design pattern is where the dependencies of a class are passed (or injected into it) from external sources. Dependencies can be passed to an object via method arguments, initializer arguments or by setting properties.


#### Via method arguments

In this form of DI dependencies are passed as method arguments to the methods that need to use them.

*RemoteControl.m*

```objectivec
@implementation RemoteControl
-(void) changeChannelTo:(int) newChannel onTV:(TV *) tv {
    [tv changeToChannel:newChannel];
}
@end
```

By adding dependencies as arguments to methods, we can pass any *TV* to the remote and it will change channels on it. It can also make your interface clearer because the selector clearly shows what the method needs. Another bonus is that when testing it's now easy to pass dummy *TV* objects for testing.

But using arguments to pass dependencies can also be a problem as well. As the code grows and more dependencies are needed, the interfaces start to become quite busy passing dependencies everywhere. We also end up having to pass objects around that are not directly used by the classes we pass them to.

*Couch.m*

```objectivec
@implementation Couch
-(void) familySitsDownWithDad:(Human *) dad
                       remote:(RemoteControl *) remote
                           tv:(TV *) tv {
    [dad changeToChannel:5 onTV:tv remote:remote];
}
@end
```

As you can see from this example, the *Couch* class now has to know about the *TV* and *RemoteControl* classes so it can pass them through. So the *Couch* class has to import the types and method has two arguments it shouldn't really have. This breaks what is known as The [Law of Demeter](https://en.wikipedia.org/wiki/Law_of_Demeter), causing classes and methods to become *"polluted"* with other classes they don't actually use. 

So my recommendation here is - *Use method arguments when the method works with the object directly.*

#### Via initializers

Another technique for injecting dependencies into a class is to pass them as arguments on an intializer. This is simlar to passing them to methods, the difference is the timing. With injection via initializers, the dependencies must be stored so they can be used laster by the methods. So our *TV* is injected into the *RemoteControl* class when contructing the *RemoteControl*. The TV reference is then stored internally until needed.

*RemoteControl.h*

```objectivec
@interface : NSObject
-(instancetype) initWithTV:(TV *) tv;
@end
```

*RemoteControl.m*

```objectivec
@implementation RemoteControl {
    TV *_tv
}
-(instancetype) initWithTV:(TV *) tv {
    self = [super alloc];
    if (self) {
        _tv = tv;
    }
    return self;
}
-(void) changeChannelTo:(int) newChannel {
    [_tv changeToChannel:newChannel];
}
@end
```

The real gain from initializer injection is when dealing with dependencies that are long lived. In our example, where the *RemoteControl* will always be using the same *TV*. Depending on where and when you code creates objects, it also removes the need for passing objects through classes that don't use them as

But DI like this has problems as well. Mainly that you have to manage the creation and injection of the relevant objects yourself. This can rapidly become quite onerous and annoying and end up costing you a lot of code to create, store and inject objects when needed. Especially when the distance (in code terms) between where an object is created and where it is used is quite large.

DI is also a core part of [Inversion of Control (IoC)](https://en.wikipedia.org/wiki/Inversion_of_control), which you may also have heard of.

My recommendation - *Reality is that the best code is usually a combination of Singletons, method arguments and DI. It's about knowing what to use where!* 
 
## DI frameworks

So what is a DI framework and why would you use one? 

The idea behind a DI framework is to manage objects and injections for you. The same as Manual DI (#3 above), but without you having to manually create, manage and inject the objects. A DI framework should allow you to write code without worrying about any of this stuff. All you should have to do is tell it what you need.

*TV.m*

```objectivec
@implementation TV
AcRegister()
@end
```
 
*RemoteControl.m*

```objectivec
@implementation RemoteControl {
    TV *_tv
}
AcRegister()
AcInject(tv)
-(void) changeChannelTo:(int) newChannel {
    [_tv changeToChannel:newChannel];
}
@end
```

This is a simple example using ***[Alchemic](README.md)***. There are a number of ways to handle injections, but the above is the simplest. The `AcRegister()` and `AcInject(tv)` macros are recognized by the Alchemic framework which does all the dirty work of managing the objects. In this example, Alchemic will create an instance of *TV* and *RemoteControl* as a singletons and automatically inject the *TV* object into the *RemoteControl* object.

So without having to manually manage everything, you can simply tell the framework what you need, and where you need it. Most DI frameworks will perform a range of other useful functionality as well, but creating and injecting objects is the core functionality they all should provide.

My final recommendation - *DI frameworks can really help simplify things, especially with large code bases. But if the framework is not making your code simpler and easier to understand, don't use it!*