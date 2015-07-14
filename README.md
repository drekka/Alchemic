# Alchemic
By Derek Clarkson

![Underconstruction](./images/alchemic-underconstruction.png) ***Currently Alchemic is in development.*** Wherever you see this logo, it means that this section of Alchemic is still being worked on. 

 * [Installation](#installation)
 * [Alchemic](#alchemic)
     * [Starting](#starting)
     * [Stopping](#stopping)
     * [Adding to your code](#adding-to-your-code)
     * [The context](#the-context)
 * [Declaring objects](#declaring-objects)
      * [Singletons](#singletons)
      * [Constructors](#-constructors)
      * [Factories](#factories)
      * [Object names](#object-names)
      * [Primary objects](#primary-objects)
          * [Primary objects and testing](#primary-objects-and-testing)
 * [Injecting dependencies](#injecting-dependencies)
 * [Resolving argument values](#resolving-argument-values)
     * [Classes and protocols](#classes-and-protocols)
     * [Names](#names)
     * [Constant values](#-constant-values)
     * [Property values](#-property-values)
 * [Factory methods](#factory-methods)
 * [Macro reference](./macros.md)

#Intro

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

# Alchemic

## Starting

Alchemic will automatically start itself when the app loads. During this process it will following this sequence of events:

1. Start itself on a background thread.
2. Scan all classes in your app for dependency injection commands. 
3. Instantiate any classes it recognises as Singletons and wire up their dependencies.

## Stopping

If for some reason you do not want Alchemic to auto-start (unit testing perhaps), then you can do this by modifying XCode's scheme for the launch like this:

![Stop Alchemic from loading](./images/screen-shot-stop-alchemic.png)

***--alchemic-nostart*** completely disables Alchemic.

Alchemic can then be programmatically started using:

```objectivec
[Alchemic start];
```

But generally speaking, just letting Alchemic autostart is the best way.

## Adding to your code

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

Before we look at resolving dependencies and injecting values, we first need to look at declaring classes so that Alchemic can find them.

## Singletons 

No matter what you are writing, you will need objects which are instantiated at the beginning of your app, are used by a variety of other objects, and only have a single instance. These are ususlly referred to as [Singletons](https://en.wikipedia.org/wiki/Singleton_pattern). There are a number of opinions amongst developers about singletons and how they should be declared and used in code. Alchemic's approach is to keep an instance of a singleton class in it's context and inject it where ever requested. It doesn't do anything to stop you creating other instances of that class outside of the context. However any request to Alchemic for an instance of a class that it views as a singleton will always return the same instance.

To declare a class as a singleton, use this macro in the class's implementation:

```objectivec
@implementation MyClass
ACRegister()
@end
```

The `ACRegister(...)` macro is how Alchemic recognises classes it will be managing, and it will auto-instantiate any registered classes as singletons on startup. This is the simplest form of registering a class with Alchemic.

*Note: Mostly there should only be one `ACRegister(...)` for a class. If you add another, a second instance of the class will then be registered. This can be useful in some situations, but generally it's not something that is common.*

## ![Underconstruction](./images/alchemic-underconstruction.png) Constructors

By default, Alchemic will use the standard `init` method when constructing an instance of a class. However this is not always the best option, so Alchemic provides a method for specifing a different initializer and how to locate any arguments it needs. Here's an example:

```objectivec
@implementation MyClass
ACRegister(ACInitializer(ACSelector(initWithOtherObject:), ACWithClass(MyOtherClass))
-(instancetype) initWithOtherObject:(id) obj {
    // ...
}
@end
```

The `ACSelector(...)` argument defines the selector of the intializer that will be called. 

The `ACWithClass(...)` is an argument resolver used to locate the object to be passed to the initializer. See [Resolving argument values](#resolving-argument-value) for details on argument resolving.

## Factories

Sometimes you want to declare a class to Alchemic, but have Alchemic create a new instance every time you need the object. This is what Alchemic regards as a ***Factory***. Factories are not as common as singletons in the DI world, but they can be useful in a variety of situations. For example, you could declare a SMS message class as a factory. Then every time you need one, Alchemic will create a new SMS message object and give it to you with all it's dependencies injected.

To tell Alchemic to treat a class registration as a factory, add the `ACIsFactory` macro to the `ACRegister(...)` macro like this:

```objectivec
ACRegister(ACIsFactory)
```

Now every time yor code requests an instance of the class, a new one will be created and returned. 

## Object names

Objects are automatically given a name when they are registered. By default, it's the class name. If you  add the `ACWithName(...)` macro you can specify a custom name to use instead. This can be extremely useful when dealing with multiple similar registrations. For example, we might register several `NSDateFormatter` objects with Alchemic and give them names like *'JSON date formatter'*, *'DB date formatter'*, etc. Then when we need a `NSDateFormatter`, we can inject the relevant one by using `ACWithName(...) ` argument resolver as part of the injection.

Here's how we assign a custom name during registration:

```objectivec
ACRegister(ACAsName(@"JSON date formatter"))
```

## Primary objects

When we have several possible candidate objects for a dependency, we might not want to use custom names to get the exact one we want, but we still need to be able to select just one. Alchemic can define one object as the default object for these situations. It has the concept of ***Primary*** objects which it borrowed from the *Spring framework*. 

The basic idea is that when registering multiple objects which can satisfy a dependency, you can flag one of them as the *'Primary'* object. Later when injecting, Alchemic will use this object in preference to the others. Here's how to declare a Primary:

```objectivec
ACRegister(ACIsPrimary)
```

Primary objects are only checked once a list of candidate objects has been located. This ensures that dependencies where specifically named objects are used are still given priority.

*Note that whilst this can solve situations where multiple candidates for a dependency are presents, if it finds Multiple Primary objects for a dependency, Alchemic will still raise an error.*

### Primary objects and testing

Primary objects are most useful in testing. You can register mock or dummy objects from your test suites and set them as Primaries. When Alchemic loads, these test objects will then become the defaults to be injected instead of the production objects, all without having to change a single line of code.

# Injecting dependencies

The main point of a DI framework is to locate an objects dependencies and inject them without the developer having to write code to manage the objects. In other words, to save the developer from having to write a lot of [boiler plate](https://en.wikipedia.org/wiki/Boilerplate_code) code. 

Alchemic specifies dependencies in a very similar fashion to how it registers classes. Here's a basic dependency registration:

```objectivec
@interface MyClass
@property(nonatomic, assign, readonly) MyOtherClass *otherClass;
@end

@implementation
ACInject(ACIntoVariable(otherClass))
// Rest of class ...
@end
```

The `ACinject(...)` macro does all the work of telling Alchemic that there is a dependency that needs to be injected into instances of the class. The `ACIntoVariable(...)` argument gives the variable to be injected. It's required as Alchemic cannot do an injection without knowing what to inject into. 

If there are no other arguments on the injection, then Alchemic will lookup the variable, work out what class and protocols it implements, and use that information to locates potential candidates within the context. Alchemic can inject public properties like the above example, but also private properties and variables. You can also use the internal name of properties if you want. So all of the following will work:

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

# Resolving argument values 

In order to process an injection, Alchemic needs a way to locate potential objects. When handling a dependency injection, it can generally examine the variable and work out for itself what to inject. But often you might want to provide your own criteria for what gets injected. Plus there are other situations where Objective-C cannot provide Alchemic with the information it needs to locate the objects. 

This is where you need to provide more information so that Alchemic can locate the objects it needs for the dependency.

## Classes and Protocols

You can tell Alchemic to ignore the type information of the dependency you are injecting and define your own class and/or protocols to use for selecting candidate objects. Here's an example:

```objectivec
ACInject(ACIntoVariable(otherClass), ACWithClass(MySpecialClass), ACWithProtocol(NSCopying), ACWithProtocol(MyOwnProtocol))
``` 

You can only specify one `ACWithClass(...)`, but as many `ACWithProtocol(...)` macros as you want. The main purposes of this is to allow you to control what is injected. It's quite useful when your variables are quite general and you want to inject more specific types. For example:

```objectivec
@implementation {
    id<Account> *_account;
}

ACInject(ACIntoVariable(_account), ACWithClass(AmexAccount))
// Rest of class ...
@end
```

## Names

Earlier on we discussed storing objects under custom names in the context so they can be found later. Here's an example of how we use a custom name to locate a specific instance of an object:

```objectivec
@implementation {
    NSDateFormatter *_jsonDateFormatter;
}

ACInject(ACIntoVariable(otherClass), ACWithName(@"JSON date formatter"))
// Rest of class ...
@end
```


## ![Underconstruction](./images/alchemic-underconstruction.png) Constant values

Some times you might want to specify a constant value for a dependency. In this case we can use the 
`ACWithValue(...)` macro like this:

```objectivec
@implementation {
    NSString *_message;
}

ACInject(ACIntoVariable(_message), ACWithValue(@"hello world"))
// Rest of class ...
@end
```

`ACWithValue(...)` cannot be used with any of the macros that perform searches for objects and must occur by itself. 

## ![Underconstruction](./images/alchemic-underconstruction.png) Property values

Property values are sourced from data sources such as Plist files or localization files. To access them you need to have the ***key*** of the value you need to obtain and use the `ACWithProperty(...)` macro like this:

```objectivec
@implementation {
    NSString *_message;
}

ACInject(ACIntoVariable(_message), ACWithProperty(@"my.app.hello.message"))
// Rest of class ...
@end
```

`ACWithProperty(...)` cannot be used with any of the macros that perform searches for objects and must occur by itself. 

# Factory methods

This is a seperate subject because it's slightly more complex to setup than classes and dependencies. Sometimes it's useful to use methods to create the objects we want to provide for injecting into dependencies. For example, we might want to hae a method that generates a `NSDateFormatter` object based on some passed arguments and we want to use it to define several date formatters which can be injected.

We know the method we need to use, but unfortunately the Objective-C runtime does not track any information about the argument and return types of methods. This goes to the way that the runtime see's methods and sends messages to objects. The runtime can tell us how many arguments there are and whether they are primitive types, structs or objects, but thats pretty much it. The up shot is that there is no way automatically discover information about a method at runtime beyond the basic type and arguments it uses. So to use a method to generate objects we have to define more information about it so that Alchemic knows what it produces as well as what arguments it needs.

Lets take a look at a simple example:

```objectivec
@implementation Factory {
    int x;
}

ACRegister(ACReturnType(NSString), ACSelector(makeAString));
-(NSString *) makeAString {
    x++;
    return [NSString stringWithFormat:@"Factory string %i", x];
}
@end
```

We use the same `ACRegister(...)` macro that we use to declare classes, but this time we add macros that define this registration as being for a method instead. 

*Note: You will also see that we actually don't register the class at all. Alchemic is smart enough to register the class automatically and create it as necessary to access it's factory methods.*

To tell Alchemic that we are declaring a factory method, we add the `ACSelector(...)`. On seeing this Alchemic now knows to call the method specified by the selector to create the object when it needs one.

Factory method registrations are stored in the Alchemic context along side the classes. For their names, it uses a combination of the class and method selector. Like class registrations, you can make use of the `ACAsName(...)` macro to give a factory method a more meaningful and useful name. 

Essentially there are two required arguments to the `ACRegister(...)` macro when declaring factory methods. The `ACFActorySelector(...)` argument which defines the selector to be called, and the `ACReturnType(...)` argument which defines the class of the object that will be returned. Both are required, and can appear in any order.

Now lets take a look at a factory method that takes arguments:

```objectivec
ACRegister(
	ACAsName(@"buildAComponentString"), 
	ACReturnType(NSString), 
	ACSelector(makeAStringWithComponent:), 
	ACWithClass(Component),
	(@[ACWithProtocol(MyProtocol), ACWithProtocol(NSCopying)])
	)
-(NSString *) makeAStringWithComponent:(Component *) component myOtherObject:(id) otherObj {
    x++;
    return [NSString stringWithFormat:@"Component Factory string %i", x];
}
```

In addition to the `ACSelector(...)` and `ACReturnType(...)` macros, we must specify argument macros that will allow Alchemic to values to be passed to the method's arguments. Alchemic uses these to select appropriate values and pass them as method arguments to the factory method.

Unlike variable dependencies, the macros that define the selector arguments **must appear in the same order** as the selector arguments. Once Alchemic has resolved values, it will use the argument indexes to set earch argument in turn.

*Note: If you want to use more than one qualifier *(as per the second argument above)* you need to wrap them in `(@[...])`. This defines an Objective-C array of arguments to be used. This is required because macros do not understand Objective-C and will mistake the commas in the array for macro argument delimiters.*


 


