# What is [Dependency Injection (DI)](https://en.wikipedia.org/wiki/Dependency_injection) and why would I want to use it?

This question comes up quite often when I'm talking about DI frameworks to developers who have never used them. So this document is an attempt to answer it with a bias towards Objective-C programming.

## Understanding the problem

[Object Orientated Programming (OOP)](https://en.wikipedia.org/wiki/Object-oriented_programming) is based on the idea of a collection of objects all working together to create an application. They do this by sending messages to each other. For example, if my *RemoteControl* class needs to change the channel on a TV, it sends a message to a *TV* object. 

The problem that we have to deal with as developers is where do we get the *TV* object from in order to send it a message? There are  3 main methods typically used to solve this:

#### 1. Singletons

One solution that is (over!) used in Objective-C projects is the [Singleton pattern](https://en.wikipedia.org/wiki/Singleton_pattern). In essence each class hold a reference to an instance of itself which can be accessed by sending a message to the class. This means that there can be one occurance of that given class.

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

Singletons can be quite useful when only one instance of a class should ever exist. 

The main design issue with singletons (IMHO) is that they *"reach"* out from inside your code to get what they need. This makes it difficult to control or override what is happening. Typically they tend to be problematic when unit testing apps and can be an issue if you suddenly find out you need more than once instance, or want to swap it for a different one. They also tend to be overused by developers because they are an *easy* answer to use, requiring little code to access from anywhere.

My general opinion is - *Use where you really need them. Not because they are easy.* 

#### 2. Passing as arguments

In this technique, objects are passed as method arguments to the methods that need them.

*RemoteControl.m*

```objectivec
@implementation RemoteControl
-(void) changeChannelTo:(int) newChannel onTV:(TV *) tv {
    [tv changeToChannel:newChannel];
}
@end
```

This is more flexible because we can pass any *TV* to the remote and it will change channels on it. The other good point is that by adding arguments to methods, you are also indicating that they will be different each time the method is called. So in some respects this can make your interfaces clearer.

But passing everything as arguments can also be a problem. In this example it's not bad. But our interfaces would become very messy if we wrote the entire app this way, especially for methods that accessed numerous objects. Plus we would end up passing objects through that are not directly used by the current class.

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

As you can see from this example, the *Couch* class now has to know about the *TV* and *RemoteControl* classes, even though it doesn't use them itself. This breaks what is known as The [Law of Demeter](https://en.wikipedia.org/wiki/Law_of_Demeter) and causes classes and methods to become *"polluted"* with other classes they don't actually use. 

So my recommendation here is - *Use when you need to work with an object directly and that object is likely to be different each time.*

### 3. Manual [Direct Injection (DI)](https://en.wikipedia.org/wiki/Dependency_injection)

DI is a design pattern where the dependencies of a class are *"injected"* into it when needed. Typically DI occurs when objects are constructed. So our *TV* is injected into the *RemoteControl* class, either when contructing the *RemoteControl* or setting a property shortly after. The reference is then stored internally until needed.

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

This [pattern](https://en.wikipedia.org/wiki/Dependency_injection) is usedful when you are dealing with more perminant object relationships. It also reduces the number of arguments you need to pass to methods as the target objects will already have most of the references they need. DI is also very useful when testing as it allows you to control what is set on any given class.

But manual DI like this has problems as well. Mainly that you have to manage the creation and injection of the relevant objects yourself. This can rapidly become quite onerous and annoying and end up costing you a lot of code to create, store and inject objects when needed. Especially when the distance (in code terms) between where an object is created and where it is used is quite large.

DI is also a core part of [Inversion of Control (IoC)](https://en.wikipedia.org/wiki/Inversion_of_control), which you may also have heard of.

My recommendation - *Reality is that the best code is usually a combination of all 3 techniques. It's about knowing what to use where!* 
 
## DI frameworks

So what is a DI framework and why would you use one? 

The reality is that any good DI framework is designed to help you do exactly the same things  as Manual DI (#3 above), but without all the hassel of having to create, manage and inject objects yourself. It should allow you to write code without worrying about any of this stuff.
 
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

This is a simple example using ***[Alchemic](README.md)***. There are a number of ways to handle injections, but the above is the simplest. The `AcRegister()` and `AcInject(tv)` macros are recognized by the Alchemic framework which does all the dirty work of managing the objects. In this example, Alchemic will create an instance of *RemoteControl* as a singleton and automatically inject an instance of *TV* into it.

So without having to manually manage everything, you can simply tell the framework what you need, and where you need it. Most DI frameworks will perform a range of other useful functionality as well, but creating and injecting objects is the core functionality they all should provide.

My final recommendation - *DI frameworks can really help simplify things, especially with large code bases. But if the framework is not making your code simpler and easier to understand, don't use it!*