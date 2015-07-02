# Alchemic
By Derek Clarkson

***Currently Alchemic is in development.***

Alchemic is a [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) framework for iOS.  It's based loosely on the [Spring](http://projects.spring.io/spring-framework/) Java framework in that I've borrowed some ideas from it as well as serveral iOS frameworks I've experimented with. 

The main criteria driving the Alchemic design was to keep it simple to use and as unobtrusive in the codebase as possible. 

# Installation

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Alchemic is [Carthage](https://github.com/Carthage/Carthage) friendly. Simply add this to your **Cartfile**

    github "drekka/alchemic" > 1.0

If your not using Carthage, I would like to suggest that you take a look if you developing for iOS 8+. IMHO it's a far superior dependency manager to Cocoapods, less intrusive and simpler to work with.

# Starting Alchemic

Alchemic will automatically start itself when the app loads. During this process it will start a background thread, and automatically scan all classes in your app for dependency injection commands. On other words, you don't need to write any code.

# Using Alchemic

To use Alchemic you will need to do an import at the top of any source code where you will be adding Alchemic statements. Mostly, this will be ***\*.m*** files as Alchemic doesn't do much with headers.

```objectivec
#import <Alchemic/Alchemic.h>
```

## The context

Alchemic has a central *'Context'* which manages all of the objects and classes that Alchemic knows about. It's basically a souped up `NSDictionary`. You generally don't need to do anything directly with the context as Alchemic's macros will take care of the dirty work for you. However should you need to access it directly it can be accessed via this:

```objectivec
[Alchemic mainContext] ...;
```
The default is to store objects in the context using the objects **class name** as a key. Everything in Alchemic's context is keyed by it's class and optionally one or more alternative names you define. 

# Declaring objects

## Singletons 

No matter what you are writing, you invaribly need objects which are instantiated at the beginning of your app, are used by a variety of other objects, and only have a single instance. These are [Singletons](https://en.wikipedia.org/wiki/Singleton_pattern). There are a number of opinions about singletons and how they should be declared and used in code. Alchemic's approach is to keep an instance of a singleton class in it's context and inject it where ever requested. It doesn't do anything to stop you creating other instances of that singleton outside of Alchemic.

To declare a class as a singleton to be managed by Alchemic, use this macro to your **.m** file:


```objectivec
@implementation MyClass
ACRegister()
// Rest of class ...
@end
```

Alchemic will auto-instantiate the singleton object on startup. `ACRegister(...)` can also take any number of arguments which further qualify the registration. For example:

```objectivec
ACRegister(ACAsName(@"JSON date formatter"), ACIsPrimary)
```

## Factories

Sometimes you want to declare a class to Alchemic, but have Alchemic create a new instance everytimes you inject it into something else. This is what we call a ***Factory*** and we can tell Alchemic to consider the class registration as a factory like this:

```objectivec
ACRegister(ACIsFactory)
```

Now every time you inject an instance of the class, a new one will be created and injected.

## Object names

Objects are stored in Alchemic's context under a name. All registrations are added to the context under their class name. But sometimes we want to add a custom object name so when injecting dependencies later, we find specify the exact instance we want. 

This is useful when the injection process locates more than one candiate for injection. Using a custom name, we can specify the exact one we want. For example, we might register several `NSDateFormatter` objects with Alchemic and give them names like *'JSON date formatter'*, *'DB date formatter'*, etc. Then later, when we need a `NSDateFormatter`, we can inject the correct one by specifying it's name as part of the injection.

Here's how we assign a custom name during registration:

```objectivec
ACRegister(ACAsName(@"JSON date formatter"))
```

Note that Alchemic will still register the object under the class name, it just adds a second reference based on the custom name pointing to the same object.

## Primary objects

When we have several candidate objects for an injection but we don't have or want to use custom names, we still need to be able to select just one. Alchemic can define one object as the default object for these situations. It has the concept of ***Primary*** objects which it borrowed from the *Spring framework*. 

The basic idea is that when registering multiple objects which can satisfy a dependency, you flag one of them as the *'Primary'* object. Later when injecting, Alchemic will use this object as the final selection, regardless of how many other candidates are available. Here's how to declare a Primary:

```objectivec
ACRegister(ACIsPrimary)
```

Note that whilst this can solve situations where multiple candidates for a dependency are presents, if it finds Multiple Primary objects for a dependency it will still raise an error.

### Primary objects and testing

Primary objects are most useful in testing. You can create classes in your test suites and register them as Primary. When Alchemic loads, these test objects will then become the defaults to be injected instead of the production objects, all without having to change a single line of code.

# Injecting dependencies

The main point of a DI framework is to locate an objects dependencies and inject them without the developer having to pass them around, or write code to locate them in other ways.

Alchemic specifies dependencies in a class in a very similar fashion to how it defines a class to be created. Here's a basic registration:

```objectivec
@interface MyClass
@property(nonatomic, assign, readonly) MyOtherClass *otherClass;
@end

@implementation
ACInject(ACIntoVariable(otherClass))
// Rest of class ...
@end
```

The `ACinject(...)` macro does all the work of telling Alchemic that there is a dependency that needs to be injected into instances of the class. And what is to be injected. The `ACIntoVariable(...)` argument is required as it makes no sense to do an injection without knowing what to inject into. If there are no other qualifiers on the injection, then Alchemic will lookup the variable, work out what class and protocols it implements, and use that information to locates potential candidates within the context.

Alchemic is also quite smart in what you can inject. It can inject public properties like the above example, but also private properties and variables. You can also use the internal name of properties if you want. So all of the following will work as well:

```objectivec
@interface MyClass
@property(nonatomic, assign, readonly) MyOtherClass *otherClass;
@end

@implementation {
    YetAnotherClass *_yetAnotherClass;
}

ACInject(ACIntoVariable(otherClass))
ACInject(ACIntoVariable(_otherClass))
ACInject(ACIntoVariable(_yetAnotherClass))
// Rest of class ...
@end
```

## Refining injections

As with registrations, there are a variety of other qaulifiers that you can add to an injection to define how Alchemic looks for candidates.

### Classes and Protocols

You can tell Alchemic to ignore the type information of the variable you are injecting and define your own class and/or protocols to use for selecting candidates. Here's an example:

```objectivec
ACInject(ACIntoVariable(otherClass), ACWithClass(MySpecialClass), ACWithProtocol(NSCopying), ACWithProtocol(MyOwnProtocol))
``` 

You can only specify one class, but as many protocols as you want. All are optional.

The main purposes of this is to allow you to control what is injected and mostly its used to declare generalised variables using types such as `UIViewController`, but inject them with more specific types.

### Using names

Earlier on we discussed storing objects under custom names in the context so they can be found later. Here's an example of how we use a custom name to locate a specific instance of an obejct:

```objectivec
@implementation {
    NSDateFormatter *_jsonDateFormatter;
}

ACInject(ACIntoVariable(otherClass), ACWithName(@"JSON date formatter"))
// Rest of class ...
@end
```

# Factory methods
This is a seperate subject because it's slightly more complex to setup than class based objects and factories. It's an unfortunate thing, but the Objective-C runtime does not track any information about the argument and return types of methods. This goes to the way that the runtime see's methods and sends messages to objects. The runtime can tell us how many arguments there are and whether they are primitive types, structs or objects, but thats pretty much it.

The up shot is that there is no way automatically discover information about a method at runtime beyond the basic type and arguments it uses. So to use factory methods we have to define more information about them so that Alchemic can match them against dependencies and decide whether to call them to create objects for injection. 

Lets take a look at a simple example:

```objectivec
@implementation Factory {
    int x;
}

ACRegister(ACReturnType(NSString), ACFactorySelector(makeAString));
-(NSString *) makeAString {
    x++;
    return [NSString stringWithFormat:@"Factory string %i", x];
}
@end
```

Firstly note that factory methods ***do not*** have to be declared on the header if only used by Alchemic. Alchemic deals purely with the implementation code.

Next note that we are using the same `ACRegister(...)` macro, but this time we are registering a method as a factory rather than a class. You will also see that we actually don't register the class at all. Alchemic is smart enough to register the class and create it as necessary to access it's factory methods.

To tell Alchemic that we are declaring a factory method, we add the `ACFactorySelector(...)`. On seeing this Alchemic now knows to call this method to create the object when it needs one.

Like classes factory methods references are stored in the context. This time under a combined name of the class and method selector. Like class registrations, you can make use of the `ACAsName(...)` macro to give a factory method a more meaningful and useful name for selecting it as a candidate for dependency injection.

Essentially with a factory method there are two required arguments to the `ACRegister(...)` macro. The `ACFActorySelector(...)` argument which defines the selector to be called, and the `ACReturnType(...)` argument which defines the class of the object that will be returned. Both are required, but can appear in any order.

Now lets take a look at a factory method that takes arguments:

```objectivec
ACRegister(
	ACAsName(@"buildAComponentString"), 
	ACReturnType(NSString), 
	ACFactorySelector(makeAStringWithComponent:), 
	ACWithClass(Component),
	(@[ACWithProtocol(MyProtocol), ACWithProtocol(NSCopying)])
	)
-(NSString *) makeAStringWithComponent:(Component *) component myOtherObject:(id) otherObj {
    x++;
    return [NSString stringWithFormat:@"Component Factory string %i", x];
}
```

The difference here is that we must specify the qualifiers that will allow Alchemic to treat the arguments as dependencies to be injected. Alchemic uses this information to look up the context for candidates, select those that are appropriate and pass them as method arguments to the factory method.

The only rule here is that the qualifiers must appear in the same order as the arguments in the selector. Alchemic will match based on index so the first qualifier will be used to locate the first argument and so on.

If you want to use more than one qualifier as per the second argument above, you need to wrap them in `(@[...])`. This defines an array of qualifiers to be used. The extra brackets are so that the macro doesn't miss-interperate the embedded comma.



 

# Startup flow

Ok, I know you want details so here's a little more:

1. Alchemic boostraps itself from `+(void) load` and creates a context. The context is basically a souped up `NSDictionary`.
2. It then scans all the classes it can find in the bundles associated with your app. It looks for a variety of things, but the most important are Alchemic macros which define classes to be created, factories and injection points. As it scans each class, Alchemic builds a model of the classes and their dependencies. 
3. It then injects init callbacks into various classes that need dependency injection and are not automatically created by Alchemic. 
4. Alchemic now resolves all the dependencies in the model so it knows what candiate objects or factories which supply objects will be injected into each dependency. 
5. It now instantiates all known singletons. This is a two stage process:
	1. First it creates the singletons using default constructors.
	2. Once all singletons are loaded, it loops through them injecting their dependencies.

	

