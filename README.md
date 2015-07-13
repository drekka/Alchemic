# Alchemic
By Derek Clarkson

![Underconstruction](./images/alchemic-underconstruction.png) ***Currently Alchemic is in development.*** Wherever you see this logo, it means that this section of Alchemic is still being worked on. 

Alchemic is a [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) framework for iOS.  It's based loosely on ideas from the [Spring](http://projects.spring.io/spring-framework/) Java framework as well as several iOS frameworks. 

The main ideas driving the Alchemic design are:

 * Keep it simple to use.
 * Keep it as unobtrusive as possible.
 * It should require less code to use than ['Rolling your own'](http://www.urbandictionary.com/define.php?term=roll+your+own).  

# Installation

## Carthage

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

If your not using Carthage, I would like to suggest that you take a look if you developing for iOS 8+. IMHO it's a far superior dependency manager to Cocoapods, less intrusive and simpler to work with.

Alchemic is [Carthage](https://github.com/Carthage/Carthage) friendly. Add this to your **Cartfile**

    github "drekka/alchemic" > 1.0

Then if you have not already included other dependenies, use this:

`carthage bootstrap`

Or:

`carthage update`

This should download Alchemic from this repository and compile it and it's dependencies into the  **<project-dir>/Carthage/Build/iOS/** directory. You can then include these frameworks into your project the same way you would add any other framework. Here's a list of what will be build:

Framework | Description
--- | ---
Alchemic.framework | This software.
Storyteller.framework | [Story Teller](https://github.com/drekka/StoryTeller) is a alternative logging framework. Add to your project along with Alchemic. 
PEGKit.framework | Used by StoryTeller and already included inside it. *You do not need to add this to your project.*

# Starting Alchemic

Alchemic will automatically start itself when the app loads. During this process it will following this sequence of events:

1. Start itself on a background thread.
2. Scan all classes in your app for dependency injection commands. 
3. Instantiate any classes it recognises as Singletons and wire up their dependencies.

#### Stopping achemic from loading
If for some reason you do not want Alchemic to auto-start (unit testing perhaps), then you can do this by modifying XCode's scheme for the launch like this:

![Stop Alchemic from loading](./images/screen-shot-stop-alchemic.png)

***--alchemic-nostart*** completely disables Alchemic.

Alchemic can then be programmatically started using:

```objectivec
[Alchemic start];
```

But generally speaking, just letting Alchemic autostart is the best way.

# Using Alchemic

To use Alchemic you will need to do an import at the top of any source code where you will be adding Alchemic statements. Mostly, this will be in ***\*.m*** files as Alchemic works with the runtime and ignores header files.

```objectivec
#import <Alchemic/Alchemic.h>
```

## The context

Alchemic has a central *'Context'* which manages all of the objects and classes that Alchemic needs. You generally don't need to do anything directly with the context as Alchemic provides a range of *macros* which will take care of the dirty work for you. However should you need to access it directly, it can be accessed like this:

```objectivec
[Alchemic mainContext] ...;
```

# Declaring objects

## Singletons 

No matter what you are writing, you will need objects which are instantiated at the beginning of your app, are used by a variety of other objects, and only have a single instance. These are ususlly referred to as [Singletons](https://en.wikipedia.org/wiki/Singleton_pattern). There are a number of opinions amongst developers about singletons and how they should be declared and used in code. Alchemic's approach is to keep an instance of a singleton class in it's context and inject it where ever requested. It doesn't do anything to stop you creating other instances of that class outside of it's context. However any request for an instance of a class that Alchemic views as a singleton will always return the same instance.

To declare a class as a singleton, use this macro in the classes implementation:

```objectivec
@implementation MyClass
ACRegister()
@end
```

The `ACRegister(...)` macro is how Alchemic recognises classes it will be managing, and it will auto-instantiate the singleton object on startup. This is the simplest form of registering a class with Alchemic.

*Note: Mostly there should only be one `ACRegister(...)` for a class. If you add another, a second instance of the class will then be registered. This can be useful in some situations, but generally it's not something that is common.*

*Note: `ACRegister(...)` has the ability to take a number of arguments. Only arguments for selectors must occur in specific order. Other arguments can occur in any order, before or after selector arguments.*


## ![Underconstruction](./images/alchemic-underconstruction.png) Constructors

By default, Alchemic will use the standard `init` method when constructing an instance of a class. However this is not always the best option, so a method is needed which allows us to specify a different initializer and also to pass arguments to it. Here's an example:

```objectivec
@implementation MyClass
ACRegister(ACInitializer(ACSelector(initWithFrame:), ACWithClass(MyOtherClass))
-(instancetype) initWithOtherObject:(id) obj {
    // ...
}
@end
```

There are two parts to this registration. The first is the `ACSelector(...)` argument. This defines the selector of the intializer that will be called. 

The second part is the `ACWithClass(...)`. This defines a search criteria that will be used to locate the argument value for the initializer. If the initializer does not need any arguments then this is not needed. If there are multiple arguments then you need to supply a search criteria for each.

### Search criteria

Search criteria for registrations follows some simple rules. Each selector argument that needs to be satified must be matched by either a single `ACWith...` search criteria, or an Objective-C array of search criteria. The order of the arguments in the selector must match the order of the search criteria.

Search critieria can be any combination of the following:

Macro | Description
--- | ---
`ACWithName(...)` | Search for registered objects based on their name.
`ACWithClass(...)` | Search for registered objects based on their class or if they are derived from the class.
`ACWithProtocol(...)` | Search for registered objects based on if they implement the passed protocol name.

So give a selector `initWithMyObj:withView:`, all of these are valid:

```objectivec
ACRegister(ACSelector(initWithMyObj:withView:), ACWithName(@"MyObj"), ACWithClass(MyView))
ACRegister(ACSelector(initWithMyObj:withView:), (@[ACWithClass(@"MyAbstractObj"), ACWithProtocol(MyBanking)]), ACWithProtocol(MyManagedView))
```

*Note: the extra '(...)' around the Objective-C array. This is required because macros do not understand Objective-C and will mistake the commas in the array for macro argument delimiters.*

## Factories

Sometimes you want to declare a class to Alchemic, but have Alchemic create a new instance everytime you request it. This is what Alchemic regards as a ***Factory***. Factories are not as common as singletons in the DI world, but they can be useful. 

To define a class as a factory, add the `ACIsFactory` macro to the `ACRegister(...)` macro like this:

```objectivec
ACRegister(ACIsFactory)
```

Now every time yor code requests an instance of the class, a new one will be created and returned. 

## Object names

Objects automatically have a matching name generated when they are registered. By using the `ACWithName(...)` macro, this name can be used later to locate them. By default, the name is the name of the class. But sometimes it's handy to provide your own name.  

Using a custom name, we can specify the exact one we want when dealing with multiple registrations. For example, we might register several `NSDateFormatter` objects with Alchemic and give them names like *'JSON date formatter'*, *'DB date formatter'*, etc. Then later, when we need a `NSDateFormatter`, we can inject the correct one by using `ACWithName(...) ` as part of the injection.

Here's how we assign a custom name during registration:

```objectivec
ACRegister(ACAsName(@"JSON date formatter"))
```

## Primary objects

When we have several possible candidate objects for a dependency, we might not want to use custom names to get the exact one we want, but we still need to be able to select just one. Alchemic can define one object as the default object for these situations. It has the concept of ***Primary*** objects which it borrowed from the *Spring framework*. 

The basic idea is that when registering multiple objects which can satisfy a dependency, you can flag one of them as the *'Primary'* object. Later when injecting, Alchemic will use this object as the final selection, regardless of how many other candidates are available. Here's how to declare a Primary:

```objectivec
ACRegister(ACIsPrimary)
```

Primary objects are only checked after all search criteria specified with `ACWith...` criteria has been executed. This ensures that they only matter when the search criteria are not enough. 

*Note that whilst this can solve situations where multiple candidates for a dependency are presents, if it finds Multiple Primary objects for a dependency it will still raise an error.*

### Primary objects and testing

Primary objects are most useful in testing. You can create classes in your test suites and register them as Primary. When Alchemic loads, these test objects will then become the defaults to be injected instead of the production objects, all without having to change a single line of code.

# Injecting dependencies

The main point of a DI framework is to locate an objects dependencies and inject them without the developer having to pass them around, or write code to locate them in other ways. In other words, to save the developer from having to write a lot of [boiler plate](https://en.wikipedia.org/wiki/Boilerplate_code) code and manage the objects themselves. 

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



 


