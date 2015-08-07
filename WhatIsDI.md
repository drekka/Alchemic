# What is Dependency Injection (DI) and why would I want to use it?

This question comes up quite often when I'm talking about DI frameworks to developers who have never used them. So this document is an attempt to answer it with a bias towards Objective-C programming.

## Understanding the problem

[Object Orientated Programming (OOP)](https://en.wikipedia.org/wiki/Object-oriented_programming) is based on the idea of a collection of objects all working together to create an application. For example, if a *RemoteControl* class needs to change the channel on a TV, it requires a *TV* object to change the channel on. In programming this is what we call a *"dependency"*. The *RemoteControl* class has a dependency on a *TV* object which it can then control.

An class's dependencies are usually located in one of two ways: Either the the code has to ***"reach out"*** to find them, or the dependencies are ***"injected"*** into the object from the code that is controlling it. Using our remote control example, either the *RemoteControl* class has to find a *TV* object for itself, or the *Human* object using the *RemoteControl* object gives it a *TV* object to control.

### Reaching out - Singletons

One technique for finding dependencies that is used a lot in Objective-C projects is the [Singleton pattern](https://en.wikipedia.org/wiki/Singleton_pattern). This pattern solves the problem where the code should only ever have a single instance of a class. For example, a single database connection or communications object. It does this by using a single central variable to store the object which everything then accesses. In Objective-C the singleton is usually created by it's own class and made available through a class method. This allows them to be accessed easily from anywhere.

*TV.h*

```objectivec
@interface TV : NSObject
// Singleton accessor class method.
+(TV *) sharedTV;
@end
```

*RemoteControl.m*

```objectivec
@implementation RemoteControl
-(void) changeChannelTo:(int) newChannel {
    TV *tv = [TV sharedTV]; // Access the singleton
    [tv changeToChannel:newChannel];
}
@end
```

*Calling code*

```objectivec
RemoteControl *rc = [[RemoteControl alloc] init];
[rc changeChannelTo:5];
```

Singletons sounds like a good solution but there are issues with them:
 
 * They are often over used in iOS apps because they are so easy to access from anywhere.
 * It's not unusual to see objects that should not be global in scope, being made global because the developer decided to treat them as a singleton. 
 * They are almost impossible to swap out because the variable storing them in the class is usually completely inacccessible. This makes testing very difficult.
 * If you discover later that you need more than one instance, it can be lot more work to refactor a singleton into a non-singleton pattern. 

My general opinion is - *Use [singletons](https://en.wikipedia.org/wiki/Singleton_pattern) sparingly and only  where you really __need__ them.* 

### Dependency Injection

The [Dependency Injection (DI)](https://en.wikipedia.org/wiki/Dependency_injection) pattern dictates that the dependencies of a class should be injected into it from elsewhere. DI is a core part of [Inversion of Control (IoC)](https://en.wikipedia.org/wiki/Inversion_of_control). There are a number of significant advantages to using DI:

* The code no longer has to how to obtain it's dependencies from.
* The code will work regardless of whether a dependency is a singleton or one of many objects.
* Testing is easier because dependencies can be [mocked out](https://en.wikipedia.org/wiki/Mock_object) to provide controlled test scenarios prior to injecting.
* Refactoring becomes simpler because there are fewer places in the code that need change.

In Objective-C terms, dependencies can be injected via 3 methods: **method arguments**, **initializer arguments** or by setting **properties**.

#### Method arguments

In this form of DI dependencies are passed as arguments to each method.

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

By adding dependencies as arguments, we can pass any *TV* to the remote and it will change it's channels. Using method arguments can also make your interface clearer because the selector clearly shows what the method needs. 

But using arguments to pass dependencies can also be a problem as well. As the code grows and more dependencies are needed, the interfaces start to become quite large with lots of arguments. It can quickly get to the point where both classes and methods are passing objects they don't use themselves, just to get the dependencies to where they are needed.

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

Here, the `familySitsDownWithDad:remote:tv:` method has to pass *TV* and *RemoteControl* object through to the *Human* class. *Couch* doesn't use these objects itself, but it still has to import the types and pass them to methods. This breaks [The Law of Demeter](https://en.wikipedia.org/wiki/Law_of_Demeter) which basically states that classes should only have knowledge of the things they use directly. Whereas here we have classes and methods becoming *"polluted"* with things they don't use. 

So my recommendation is - *Use method arguments when the method works with the object directly.*

#### Via initializers

Another popular technique for injecting dependencies into a class is to pass them to an intializer. With initializer injection, the dependencies have to be available before the class is created. In the initializer, the dependencies are then stored for later use where they can be found by the class's methods.

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
        _tv = tv; // Store for later use
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

Now the *TV* is injected into the *RemoteControl* class when initialising it. The advantage of initializer injection is that It is clear what the class needs up front. It's also more suited to dependencies that are long lived. For example, where a *RemoteControl* will always be using the same *TV*. Finally, initializer injection alleviates the need to pass dependencies via method arguments because the object already has everything it needs up front.

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

Whilst taking less code than initializers, using properties for injection is not a reliable solution because there is the chance that the developer will forget to set them. There is also no clue from a class interface as to what properties are required for that class to function.

*Calling code*

```objectivec
TV *tv = [[TV alloc] init];
RemoteControl *rc = [[RemoteControl alloc] init];
[rc changeChannelTo:5]; // Oops, TV not set !
```

However there are times when property injection can be better. For example, when a dependency periodically changes.  

My recommendation - *The reality of programming is that the best code is usually a combination of all of these things: Singletons, method argument, initializer and property based DI. It's really about knowing what to use where!* 

## DI frameworks
 
All of the above examples still have one core problem - that you have to write code to manage the creation, availability and injection of the relevant object. This can become quite onerous, annoying and require a lot of code. Especially when the distance (in design terms) between where an object is created and where it is used is quite large, or the code to access an object is not simple.

DI frameworks are designed to help with this. They do the common grunt work of creating, managing and injecting objects for you. Essentially a DI framework should allow you to write code without worrying about any of this stuff. All you should have to do is tell it what you need and where you need it.

*TV.m*

```objectivec
@implementation TV
AcRegister() // declare a singleton
@end
```
 
*RemoteControl.m*

```objectivec
@implementation RemoteControl {
    TV *_tv
}
AcRegister() // declare a singleton
AcInject(_tv) // inject a TV object
-(void) changeChannelTo:(int) newChannel {
    [_tv changeToChannel:newChannel];
}
@end
```

*Calling code*

```objectivec
RemoteControl *rc = AcGet(RemoteControl, AcClass(RemoteControl)); 
[rc changeChannelTo:5];
```

This is a simple example using the ***[Alchemic DI framework](README.md)***. Notice how the only thing you need to do it tell Alchemic what you want. When your app starts, It will automatically create an instance of *TV* and an instance of *RemoteControl* as a singletons. It will also automatically inject the *TV* object into the *RemoteControl* object and store the objects so they can be injected anywhere anytime. because Alchemic bootstraps itself when your app starts, you only need the above code to make everything work.

Most DI frameworks private a range of useful functions, but creating, managing and injecting objects is the core functionality they all should provide, and provide it with a minimum of fuss.

My final recommendation - *DI frameworks can really help simplify things, especially with large code bases. But if the framework is not making your code simpler and easier to understand, shop elsewhere!*