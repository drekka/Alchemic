# What is Dependency Injection (DI) and why would I want to use it?

This question comes up quite often when I'm talking about DI frameworks to developers who have never used them. So this document is an attempt to answer it with a bias towards Objective-C programming. First we will look at why we would use DI and finally we will look at how a DI framework can assist.

## Understanding the problem

[Object Orientated Programming (OOP)](https://en.wikipedia.org/wiki/Object-oriented_programming) is based on the idea of a collection of objects all working together to create an application. For example, if my *RemoteControl* class needs to change the channel on a TV, it needs a *TV* object to change the channel on. In programming this is what we call a *"dependency"*. *RemoteControl* has a dependency on a *TV* object because it needs to give it instructions.

An object's dependencies are usually located in one of two ways: either the the object's code has to *"reach out"* to get what it needs, or the dependencies are *"injected"* into the object so that they are already present when the code needs them.

Lets take a look at some typical scenarios of two options and the pros and cons of each.

### Reaching out - Singletons

One solution to finding dependencies that is (over!) used (IMHO) in Objective-C projects is the [Singleton pattern](https://en.wikipedia.org/wiki/Singleton_pattern). The singleton pattern is for when your code should only ever have a single instance of a class. For example, a database connection or comms object. In Objective-C a singleton is usually created by it's own class and is accessible through a class method. 

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

*Calling code*

```objectivec
RemoteControl *rc = [[RemoteControl alloc] init];
[rc changeChannelTo:5];
```


Singletons tend to get overused in Objective-C code because they can be accessed anywhere in the app merely by accessing the class. So it's a fast and easy to code. But there are issues with them. Firstly they are almost impossible to swap out when testing because the way they are stored in the class is usually completely inacccessible. So when testing the code that reaches out to them, it's almost impossible to mock out the singleton instance. Another problem that can arise is that if at a later stage you discover that you need more than one instance, a large chunk of your code has to be refactored because it can no longer access the instance through class methods. 

My general opinion is - *Use [singletons](https://en.wikipedia.org/wiki/Singleton_pattern) sparingly and where you really need them.* 

### Dependency Injection

The [Dependency Injection (DI)](https://en.wikipedia.org/wiki/Dependency_injection) design pattern is where the dependencies of a class are passed (or injected into it) from the external code. there are a number of advantages to using DI:

* The code no longer has to know where to get dependencies from.
* The code will work regardless of whether a dependency is a singleton or one of many objects.
* Testing is easy because dependencies can be [mocked out](https://en.wikipedia.org/wiki/Mock_object).
* Refactoring how objects are created or accessed becomes simpler because there are less locations in the code that need change.

*DI is a core part of [Inversion of Control (IoC)](https://en.wikipedia.org/wiki/Inversion_of_control), which you may also have heard of.*

Dependencies can be injected into an object via method arguments, initializer arguments or by setting properties.

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

*Calling code*

```objectivec
TV *tv = [[TV alloc] init];
RemoteControl *rc = [[RemoteControl alloc] init];
[rc changeChannelTo:5 onTV:tv];
```

By adding dependencies as arguments to methods, we can pass any *TV* to the remote and it will change channels on it. It can also make your interface clearer because the selector clearly shows what the method needs. Another bonus is that when testing, passing dependencies via method arguments makes it easy to pass dummy *TV* objects.

But using arguments to pass dependencies can also be a problem as well. As the code grows and more dependencies are needed, the interfaces start to become quite large. Full of dependencies being passed around. It can also end up having to pass objects around that are not directly used by the classes doing the passing.

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

In this example, the *Couch* class now has to know about the *TV* and *RemoteControl* classes so it can pass them through. But it doesn't use them itself, yet still has to import the types and the method have two arguments it shouldn't really have. This breaks what is known as The [Law of Demeter](https://en.wikipedia.org/wiki/Law_of_Demeter) and causes classes and methods to become *"polluted"* with things they don't actually use. 

So my recommendation here is - *Use method arguments when the method works with the object directly.*

#### Via initializers

Another technique for injecting dependencies into a class is to pass them as arguments on an intializer. This is similar to passing them to methods, the difference is the timing. With injection via initializers, the dependencies are set before methods are called and must be stored for later use. 

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

*Calling code*

```objectivec
TV *tv = [[TV alloc] init];
RemoteControl *rc = [[RemoteControl alloc] initWithTV:tv];
[rc changeChannelTo:5];
```


Now the *TV* is injected into the *RemoteControl* class when initializing and stored internally until needed. The real gain from initializer injection is when dealing with dependencies that are long lived. In our example, where a *RemoteControl* will always be using the same *TV*. It aleviates the need to pass dependencies via method arguments as objects already have everything they need.

#### Via Properties

*RemoteControl.h*

```objectivec
@interface : NSObject
@property (nonatomic, strong) TV *tv;
@end
```

*RemoteControl.m*

```objectivec
@implementation RemoteControl 
-(void) changeChannelTo:(int) newChannel {
    [self.tv changeToChannel:newChannel];
}
@end
```

*Calling code*

```objectivec
TV *tv = [[TV alloc] init];
RemoteControl *rc = [[RemoteControl alloc] init];
rc.tv = tv;
[rc changeChannelTo:5];
```

Whilst taking less code than initializers, using properties for injection is not as reliable as using initializers because there is the chance that the developer will forget to set them. Looking at the interfaces of objects there is also no real indicator as to which properties are essential for the classes operation. But other than that there is no real difference between using properties and using initializers.

My recommendation - *Reality is that the best code is usually a combination of Singletons and the various forms of DI. It's about knowing what to use where!* 

## DI frameworks
 
DI done using the above examples has problems as well. Mainly that you have to manage the creation and injection of the relevant objects yourself, and you have to make sure that they are available wherever in your code you need them. This can become quite onerous, annoying and end up costing you a lot of code to create, store and inject objects when needed. Especially when the distance (in code terms) between where an object is created and where it is used is quite large.

So what is a DI framework and why would you use one? 

The idea behind a DI framework is to do the common grunt work of managing objects and injections for you. A DI framework should allow you to write code without worrying about any of this stuff. All you should have to do is tell it what you need and where you need it.

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
AcInject(_tv)
-(void) changeChannelTo:(int) newChannel {
    [_tv changeToChannel:newChannel];
}
@end
```

*Calling code*

```objectivec
RemoteControl *rc = AcGet(AcClass(RemoteControl));
[rc changeChannelTo:5];
```


This is a simple example using ***[Alchemic](README.md)***. The `AcRegister()` and `AcInject(tv)` macros are the Alchemic framework's technique for managing the objects. In this example, Alchemic will create an instance of *TV* and *RemoteControl* as a singletons and automatically inject the *TV* object into the *RemoteControl* object.

So without having to manually manage everything, you can simply tell the framework what you need, and where you need it. Most DI frameworks will perform a range of other useful functionality as well, but creating and injecting objects is the core functionality they all should provide.

My final recommendation - *DI frameworks can really help simplify things, especially with large code bases. But if the framework is not making your code simpler and easier to understand, don't use it!*