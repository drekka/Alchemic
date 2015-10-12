# Alchemic [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
By Derek Clarkson

Other documents: [What is Direct Injection (DI)?](./WhatIsDI.md), [Quick guide](./Quick guide.md), [Macro ref](./macros.md)

 * [Installation](#installation)
 * [Alchemic](#alchemic)
     * [Starting](#starting)
     * [Stopping](#stopping)
     * [Adding to your code](#adding-to-your-code)
     * [The context](#the-context)
 * [Macros](#macros)
 * [Creating objects](#creating-objects)
      * [Builders](#builders)
      * [Singletons](#singletons)
      * [Initializers](#initializers)
      * [Factories](#factories)
      * [Object names](#object-names)
      * [Generating objects using methods](#generating-objects-using-methods)
      * [Primary objects](#primary-objects)
          * [Primary objects and testing](#primary-objects-and-testing)
 * [Injecting dependencies](#injecting-dependencies)
     * [Object search criteria](#object-search-criteria)
         * [Searching by class and protocols](#searching-by-class-and-protocols)
         * [Searching by Name](#searching-by-name)
         * [Constant values](#constant-values)
     * [Arrays](#arrays)
 * [Getting and setting objects](#getting-objects)
     * [Unmanaged instances](#unmanaged-instances)
     * [Programmatically obtaining objects](#programmatically-obtaining-objects)
     * [Setting values](#setting-values)
 * [Asynchronous startup](#asynchronous-startup)
     * [UIApplicationDelegate](#uiapplicationdelegate)
 * [Callbacks and notifications](#callbacks-and-notifications)
 * [Configuration](#configuration)
 * [Circular dependencies](#circular-dependencies)
 * [Credits](#credits)

#Intro

Alchemic is a [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) framework for iOS.  It's based loosely on ideas from the [Spring](http://projects.spring.io/spring-framework/) Java framework and after trying out several other iOS DI frameworks. 

The main ideas driving the Alchemic design are:

 * Keep it simple to use.
 * Keep it as unobtrusive as possible.
 * Minimal code, preferrable - ***None !***
 * Flexibility.

##Main features
* Singletons by default
* Factory classes
* Method based object creation
* Initializer argument injection
* Method argument injection
* Value resolution by class, protocol or name.
* Constant value injection
* Primary instances
* Self starting
* Automatic registration of classes and methods through bundle scanning
* Automatic array population by class, protocol or name
* Circular dependency detection
* Macro driven
* UIApplicationDelegate aware
* Asynchronous loading

# Installation

## [Carthage](https://github.com/Carthage/Carthage)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

If your not using [Carthage](https://github.com/Carthage/Carthage), I would like to suggest that you take a look if you developing for iOS 8+. IMHO it's a far superior dependency manager to Cocoapods, less intrusive and simpler to work with.

Add this to your **Cartfile**:

    github "drekka/alchemic" > 1.0

Then if you have not already included other dependenies, use this:

`carthage bootstrap`

Or:

`carthage update`

This should download Alchemic from this repository and compile it and it's dependencies into the  **<project-dir>/Carthage/Build/iOS/** directory. You can then include these frameworks into your project the same way you would add any other framework. 

*Note: You will need to ensure that all of these frameworks are added to your project and copied to the __Frameworks__ directory in your app.* 

Framework | Description
--- | ---
Alchemic.framework | This API.
Storyteller.framework | [Story Teller](https://github.com/drekka/StoryTeller) is a alternative logging framework. 
PEGKit.framework | Used by StoryTeller.

# Alchemic

## Starting

Alchemic will automatically start itself when the app loads. During this process it will follow this sequence of events:

1. Start itself on a background thread.
2. Scan all classes in your app for dependency injection commands. 
3. Instantiate any classes it recognises as Singletons and wire up their dependencies.
4. Check for a UIApplicationDelegate and if found, checks it for injections.
5. Executes post-startup blocks.
5. Posts the ["AlchemicFinishedLoading"](#finished-loading) notification.

*Look at [Asynchronous startup](#asynchronous-startup) for more details on Alchemic's starting and how to know when you can access objects.*

## Stopping

If for some reason you do not want Alchemic to auto-start (unit testing perhaps), then you can do this by modifying XCode's scheme for the launch like this:

![Stop Alchemic from loading](./images/screen-shot-stop-alchemic.png)

***--alchemic-nostart*** - disables Alchemic's autostart function.

Alchemic can programmatically started using:

```objectivec
[Alchemic start];
```

But generally speaking, just letting Alchemic autostart is the best way.

## Adding to your code

To use Alchemic, import the Alchemic umbrella header at the top of your implementations (___*.m___ files). 

```objectivec
#import <Alchemic/Alchemic.h>
```

*Alchemic works with implementations rather than the headers. This means it can access methods and initializers that are not public or visible to other classes.  The advantage of this is that you have the ability to create initializers and methods which only Alchemic can see. Thus simplifying your headers.*

## The context

Alchemic has a central *'Context'* which manages all of the objects and classes that Alchemic needs. You generally don't need to do anything directly with the context as Alchemic provides a range of *macros* which will take care of the dirty work for you. However should you need to access it directly, it can be accessed like this:

```objectivec
[Alchemic mainContext] ...;
```

# Macros

Alchemic is designed to be as unobtrusive as possible. But it still needs to know a fair amount of information about your code. So it uses pre-processor macros as a form of meta-data, similar to Java's annotations. These macros are generally pretty simple and easy to remember and it's likely that within a short time you will being using them without much thought. 

Most of these macros take one or more arguments. For example the `AcArg(...)` macro takes at least two arguments and possibly more. To help keep the macros susinct and avoid having to type needless boiler plate, there are some common conventions used:

 Convention | Description
 --- | ---
 Types (Classes & Protocols) | You only need to specify the relevant class or protocol when a type is needed.<br />For example `AcProtocol(NSCopying)` is the macro form of<br />`[ALCProtocol withProtocol:@protocol(NSCopying)]`.
 Selectors | You only need to specify the selector name. For example `AcInitializer(myInitMethod)` is the macro form of<br />```[[ALCAlchemic mainContext] registerClassInitializer:classBuilder initializer:@selector(initializerSel), nil];```
Properties | Property names are also shortened. So that code completion can assist, they are **not** expressed as strings. For example `AcInject(myVar)`. 
Varadic macros |  Many macros make use of varadic lists so you can add as many criteria as you like in a single line.

# Creating objects

Before we look at resolving dependencies and injecting values, we first need to look at how we tell Alchemic about the objects we want to create.

## Builders

Alchamic uses what it calls '**Builders**' to declare how objects are created. They can both build objects and inject dependencies. There are 3 main types of builders:

* **Class builders** which define information about a class and can build instances of that class. Class builders also hold information about dependencies that the class may have and how they are located and injected.
* **Initializer builders** which define information about a class's initializer and can build instances of the class by executing the initializer and passing it arguments. 
* **Method builder** which define information about a method in a class and can build objects by calling the method and returning the result. Method builders are very similar to initializer builder, only differing in how the method is called.


## Singletons 

No matter what you are writing, you will probably need objects which are instantiated at the beginning of your app, are used by a variety of other objects, and only have a single instance. These are usually referred to as [Singletons](https://en.wikipedia.org/wiki/Singleton_pattern). There are a number of opinions amongst developers about singletons and how they should be declared and used in code. 

Alchemic's approach is to assume that builders represent a singleton by default. It keeps one instance of the class in it's context and injects it where ever requested. However it doesn't do anything to stop you creating other instances of that class outside of the context. To tell Alchemic that a particular class is to be treated as a singleton, use this macro in the class's implementation:
  
```objectivec
@implementation MyClass
AcRegister()
@end
```

This is the simplest form of registering a class with Alchemic. The `AcRegister(...)` macro is how Alchemic recognises the class. It will auto-instantiate any classes with this macro as singletons on startup. 

*Note: Mostly there should only be one `AcRegister(...)` for a class. If you add another, a second instance of the class will then be registered. This can be useful in some situations, but generally it's not something that is commonly done.*

## Initializers

By default, Alchemic will use the standard `init` method when initializing an instance of a class. However this is not always the best option, so Alchemic provides a method for specifying a different initializer and how to locate any arguments it needs:

```objectivec
@implementation MyClass
AcInitializer(initWithOtherObject:, AcArg(MyOtherClass, AcClass(MyOtherClass))
-(instancetype) initWithOtherObject:(id) obj {
    // ...
}
@end
```

The `AcInitiailizer(...)` macro tells Alchemic that when it needs to create an instance of MyClass, it should use the `initWithOtherObject:` initializer. The first argument to this macro is required and specifies the initializer selector. After that is a series of zero or more `AcArg(...)` macros which define where to get the value for each argument that the selector declares. 

`AcInitializer(...)` can also take all the same macros that can be used with `AcRegister(...)` to define various attributes of the instance that will be created. In fact, there is no need to use `AcRegister(...)` at all as the arguments for it will be ignored when there is an `AcInitializer(...)` macro present.

### AcArg(type, value, ...)

`AcArg(...)` is a macro that helps both `AcInitializer(...)` and `AcMethod(...)` locate argument values to be passed to the methods they are going to be calling. The first argument to `AcArg(...)` is the type of the argument. After that is a list of one or more [Object search criteria](#object-search-criteria) or macros that define values. These tell Alchemic where and how to obtain the value for that argument. The value can also be **nil** if you want to pass a nil. 

*Note: `AcArg(...)` arguments must be in the same order as the selector's arguments. This is how Alchemic matches them up when passing values.*

## Factories

Sometimes you want to declare a class to Alchemic, but have Alchemic create a new instance every time you need the object. In other words, a ***Factory***. Factories are not as common as singletons in the DI world, but they can be useful in a variety of situations. For example, you could declare a SMS message class as a factory. Then every time you need one, Alchemic will create a new SMS message object and give it to you with all it's dependencies injected.

To tell Alchemic to treat a class registration as a factory, add the `AcIsFactory` macro to the `AcRegister(...)` macro like this:

```objectivec
AcRegister(AcIsFactory)
```

Now every time your code requests an instance of the class, a new one will be created and returned. 

*Note that `AcIsFactory` can also be added to the `AcInitializer(...)` and `AcMethod(...)` macros as well.*

## Object names

Objects are automatically given a name when they are registered. By default, it's the class name. If you  add the `AcWithName(...)` macro you can specify a custom name to use instead. This can be extremely useful when dealing with multiple similar registrations. For example, we might register several `NSDateFormatter` objects with Alchemic and give them names like *'JSON date formatter'*, *'DB date formatter'*, etc. Then when we need a `NSDateFormatter`, we can inject the relevant one by using `AcName(...) ` argument resolver as part of the injection.

Here's how we assign a custom name during registration:

```objectivec
AcRegister(AcWithName(@"JSON date formatter"))
```

*Note: names __must__ be unique. This aids in searching for objects to inject.*

## Generating objects using methods

Sometimes we want to use methods to create objects for injecting into dependencies. For example, we might want to have a method that generates a `Transaction` object based on some passed arguments. 

*Unfortunately the Objective-C runtime does not track any information about the argument and return types of methods they way it does for variables. So there is no way for Alchemic to automatically discover information about a method at runtime beyond some very basic information. So when using methods we have to tell Alchemic a lot more information that for classes.*

Lets take a look at two sample methods which Alchemic will use to create objects:

```objectivec
@implementation Factory {
    int x;
}

AcRegister()

// First a singleton
AcMethod(Database, generateDatabaseConnection)
-(id<DBConnection>) generateDatabaseConnection {
    // Complex connection setup code.
    return dbConn;
}

// And a factory
AcMethod(NSString, makeATransaction, AcIsFactory))
-(NSString *) makeATransaction {
    return [[Transaction alloc] 
        initWithName:[NSString stringWithFormat:@"Transaction %i", ++x]];
}
@end
```

We use the `AcMethod(...)` macro to define ay method that can create objects. This macro is similar to `AcRegister(...)` in that it registers a source of objects which can be injected into other things. 

The first example creates a singleton instance. Alchemic will only call the method once and reuse the returned object every time it needs it. This allows you to utilise more complex code to setup singletons when you need it. The second example which generates transactions needs to generate a new one each time it is needed. So this one has the `AcIsFactory` flag. 

Factory method registrations are stored in the Alchemic context along side the classes. For their names, Alchemic uses a combination of the class and method selector using the format "*ClassName method:signature:*". Like class registrations, you can make use of the `AcWithName(...)` macro to give a factory method a more meaningful and useful associated name. 

Now lets take a look at an example factory method with arguments:

```objectivec
AcMethod(NSURLConnection, serverConnectionWithURL:retries:,
	AcWithName(@"serverConnection"), 
	AcArg(NSURL, AcName(@"db-server-url")),
	AcArg(NSNumber, AcValue(@5))
	)
-(NSURLConnection *) serverConnectionWithURL:(NSURL *) url 
                                     retries:(NSNumber *) retries {
    // lots of complex setup code here that creates newConnection.
    return newConnection;
}
```

Here we need to use `AcArg(...)` macros that will allow Alchemic to locate values to be passed to the method's arguments. Alchemic uses this information to select appropriate values and pass them as method arguments to the factory method when it's creating an instance with it. It needs both the type of the argument and how to locate the value for it.

Method arguments call also pass nils. If you need to pass a nil argument you can use `AcValue(nil)` as the value part of `AcArg(...)`. If *all* the remaining arguments to a method are nil, then you can simply leave then out.

Here are some other examples of the above declaration with nils: 

```objectivec
// Passing a nil URL.
AcMethod(NSURLConnection, serverConnectionWithURL:retries:,
	AcArg(NSURL, AcValue(nil)),
	AcArg(NSNumber, AcValue(@5))
	)
// Passing a nil retries value.
AcMethod(NSURLConnection, serverConnectionWithURL:retries:,
	AcArg(NSURL, AcName(@"db-server-url"))
	)
// All arguments are nil
AcMethod(NSURLConnection, serverConnectionWithURL:retries:)
```

## Primary objects

When we have several possible candidate objects for a dependency, we might not want to use custom names to get the exact one we want, but we still need to be able to select just one. Alchemic can define one object as the default object for these situations. It has the concept of ***Primary*** objects which it borrowed from the [*Spring framework*](http://spring.io). 

The basic idea is that when registering multiple objects which can satisfy a dependency, you can flag one of them as the *'Primary'* object. Later when injecting, if Alchemic see's an objected tagged as a primary, it will use it in preference to other objects. Here's how to declare a Primary:

```objectivec
AcRegister(AcIsPrimary)
```

Primary objects are only checked once a list of candidate objects for ain injection have been located. This ensure that they don't override more specific criteria.

*Note that whilst this can solve situations where multiple candidates for a dependency are presents, if it finds Multiple Primary objects for a dependency, Alchemic will still raise an error.*

### Primary objects and testing

Primary objects are most useful in testing. You can register mock or dummy objects from your test suites and set them as Primaries. When Alchemic loads, these test objects will then become the defaults to be injected instead of the production objects, all without having to change a single line of code.

# Injecting dependencies

The main point of a DI framework is to locate an objects dependencies and inject them without the developer having to write code to manage the objects. In other words, to save the developer from having to write a lot of [boiler plate](https://en.wikipedia.org/wiki/Boilerplate_code) code. 

Alchemic specifies variable dependencies in a very similar fashion to how it registers classes. Here's a basic variable dependency registration:

```objectivec
@interface MyClass
@property(nonatomic, assign, readonly) MyOtherClass *otherClass;
@end

@implementation
AcInject(otherClass)
// Rest of class ...
@end
```

The `Acinject(...)` macro does all the work of telling Alchemic that there is a dependency that needs to be injected into instances of the class. If there are no other arguments on the injection, Alchemic will lookup the variable based on the passed name, work out what class and protocols it implements, and use that information to locates potential candidates within the context. 

*Note: Variables are where the Objective-C runtime does actually provide quite detailed information so it's possible for Alchemic to work out exactly what type of object to look for.* 

Alchemic can inject public properties like the above example, but also private properties and variables. You can also use the internal name of properties if you want. So all of the following will work:

```objectivec
@interface MyClass
@property(nonatomic, assign, readonly) MyOtherClass *otherClass;
@end

@implementation {
    YetAnotherClass *_yetAnotherClass;
}

AcInject(otherClass)
AcInject(_otherClass)
AcInject(_yetAnotherClass)
// Rest of class ...
@end
```

*Note: Whilst Alchemic can inject values into properties as easily as variables, it does not trigger KVO when doing so. __So don't depend on KVO to detect injections__.*

## Object search criteria 

In order to inject a variable, Alchemic needs a way to locate potential values. Generally it can examine the variable and work out for itself what to inject. But often you might want to provide your own criteria for what gets injected. Plus there are some situations where Objective-C cannot provide Alchemic with the information it needs to work out what to inject. 

### Searching by Class and Protocols

You can tell Alchemic to ignore the type information of the dependency you are injecting and define your own class and/or protocols to use for selecting candidate objects. Here's an example:

```objectivec
AcInject(otherClass, 
    AcClass(MySpecialClass), 
    AcProtocol(NSCopying), 
    AcProtocol(MyOwnProtocol)
    )
``` 

You can only specify one `AcClass(...)`, but as many `AcProtocol(...)` macros as you want. It's quite useful when your variables are quite general and you want to inject more specific types. For example, assuming that `AmexAccount` implements the `Account` protocol, we can write this:

```objectivec
@implementation {
    id<Account> *_account;
}
AcInject(_account, AcClass(AmexAccount))
@end
```

As programming to protocols is considered a good practice, this sort of injection allows you classes to be quite general in how they refer to other classes, yet you can still locate specific objects to inject.

### Searching by Name

Earlier on we discussed storing objects under custom names in the context so they can be found later. Here's an example of how we use a custom name to locate a specific instance of an object:

```objectivec
@implementation {
    NSDateFormatter *_jsonDateFormatter;
}
AcInject(otherClass, AcName(@"JSON date formatter"))
@end
```

Again we are making a general reference to a `NSDateFormatter`, but using the name assigned by Alchemic to locate the specific one needed for the injection.

The `AcName(...)` macro cannot occur with any other macros. However, if defining arguments for a [factory method](#factory-method), `AcName(...)` can be used for individual arguments along side other arguments that search the model for objects. See [Factory methods](#factory-methods) for more details.*

### Constant values

Some times you might want to specify a constant value for a dependency. In this case we can use the `AcValue(...)` macro like this:

```objectivec
@implementation {
    NSString *_message;
}
AcInject(_message, AcValue(@"hello world"))
@end
```

The `AcValue(...)` macro cannot occur with of the search macros. `AcValue(nil)` is also valid and will pass a nil to the target method.

## Arrays

Alchemic has another trick up it's sleeve it borrowed from the [*Spring framework*](http://spring.io). If you want to get an array of all the objects that match a [search criteria](#object-search-criteria), you can just specify to inject an array variable, and Alchemic will automatically inject a `NSArray` instance containing all objects that match the criteria. 

For example, if we want a list of all NSDateFormatters objects that Alchemic is managing:

```objectivec
@implementation {
    NSArray<NSDateFormatter *> *_dateFormatters;
}
AcInject(_dateFormatters, AcClass(NSDateFormatter))
@end
```

When processing the available objects to inject, Alchemic will automatically check if the target variable is an array and adjust it's injection accordingly, wrapping objects in NSArrays as required. 

*Note: If the target variable is not an `NSArray` type and multiple objects are found, them Alchemic will throw an error.*

# Getting objects

Now that we know how to declare objects and inject them, lets look at how we retrieve objects in classes and code which is not managed by Alchemic. In other words, how to manage objects in the rest of your app.

## Unmanaged instances

Not all objects can be created and injected by Alchemic. For example, UIViewControllers in storyboards are created by the storyboard. 

*Whilst I looked at several options for automatically injecting these instances, I did not find any that worked reliably and didn't require a lot of effort to code. So for the moment Alchemic does not inject dependencies into them automatically.*

***However*** you can still declare dependencies in these classes and get them injected as if Alchemic had created them. You just have to make a call to trigger the injection process programmatically like this:

```objectivec
-(instancetype) initWithFrame:(CGRect) aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        AcInjectDependencies(self);
    }
    return self;
}
```

You can add the `AcInjectDependencies(...)` macro anywhere in the class. For example you might do it in the `viewDidLoad` method instead. 

## Programmatically obtaining objects

Sometimes (in testing for example) you want to get an object from Alchemic without specifying an injection.

### AcGet(...)

`AcGet(...)` allows you to search for and return an object (or objects) in a similar fashion to how `AcInject(...)` works. Except it's inline with your code rather than a one off injection and can be accessed as many times as you like.

```objectivec
-(void) myMethod {
    NSDateFormatter *formatter = AcGet(NSDateFormatter, AcName(@"JSON date formatter"));
    // Do stuff ....
}
```

`AcGet(...)` requires the first argument to be the type of what will be returned. This type is needed because the runtime does not know what is expected to be returned and Alchemic needs this information to finish processing the results. Especially if you are expecting an array back.

Arguments after the type are search criteria macros used to find the object. So `AcClass(...)`, `AcProtocol(...)`, `AcName(...)`, or `AcValue(...)` macros are all useable to either search the context for objects or set a specific value. Note that `AcGet(...)` also does standard Alchemic `NSArray` processing. For example the following code will return an array of all Alchemic registered date formatters:*

```objectivec
-(void) myMethod {
    NSArray *formatters = AcGet(NSArray, AcClass(NSDateFormatter));
    // Do stuff ....
}
```

Finally, you can leave out the search criteria macros like this:

```objectivec
-(void) myMethod {
    NSDateFormatter *formatter = AcGet(NSDateFormatter);
    // Do stuff ....
}
```

Without any criteria, Alchemic will use the passed return type to determine the search criteria for scanning the model based in it's class and any applicable protocols.

### AcInvoke(...)

`AcInvoke(...)` is for when you want to access a declared method or initializer and pass in the arguments manually. But you don't have access to the object it's declared on. For example, you might declare a factory initializer like this:

```objectivec
AcInitializer(initWithText:, AcIsFactory, AcArg(NSString, AcValue(@"Default message")
-(instancetype) initWithText:(NSString *) message {
    // ...
}
```

In this scenario you want the factory method to give you a new instance of the object when you need it, but with a different message. So you can it like this:

```objectivec
-(void) myMethod {
    MyObj *myObj = AcInvoke(AcName(@"MyObj initWithText:"), @"Overriding message text");
    // Do stuff ....
}
```

`AcInvoke(...)` will locate all Alchemic declarations that match the first argument, which must be a search macro. Normally it's the `AcName(...)` macro because the usual scenario here is to be addresses a specific method or initializer. Once Alchemic has located the method, it then invokes it (in the case of a normal method) or creates an instance using the initializer. In either case the method being addresses **must** have been registered via a `AcInitializer(...)` or `AcMethod(...)` macro so it can be found. 

Also note in the above example, we are using the default name for the method generated by Alchemic. Using `AcInvoke(...)` is one good reason to make use of the `AcWithName(...)` macro to add custom names to registrations.

## Setting values

Sometimes you have created an object outside of Alchemic, but want Alchemic to manage it. For example, you might have a view controller you want Alchemic to inject into other objects. You can use the `AcSet(...)` macro to do this:

```objectivec
-(void) myMethod {
    MyObj *myObj = ... // create the object. 
    AcSet(myObj, AcName(@"abc"));
}
```

Alchemic will locate the matching builder for the criteria passed as arguments after the object and set the object as it's value. `ACName(...)` is most useful when setting values as `AcSet(...)` expects there to be only one builder found by the passed macros. If zero or more than one builder is returned it will throw an error.

*Note: that setting a new value for a builder does not effect any previously injected references to the old value. Only injections done after setting the value will use the new value.*

## Asynchronous startup

Alchemic bootstraps itself in a background thread rather than taking up precious time during your application's startup. However, it also means that any classes that make calls to `AcInjectDependencies(...)` may attempt to execute it before Alchemic has finished reading the classes and building it's model of your app.

To address this Alchemic provides asynchronous callback which can be used in any code that runs at the beginning of your app and needs to ensure that something is execute ***After*** Alchemic has finished starting up. 

An example is that you might have a table view controller that needs data from a singleton that Alchemic injects. To deal with this situation, you should engineer the table view controller to work if the singleton dependency is nil, and to register a callback which refreshes the table after Alchemic has finished loading lie this:

```objectivec
-(void) viewDidLoad {
    AcExecuteWhenStarted(^{
        [self.tableView reloadData];
    });
}
```

If Alchemic has already started then the block is executed immediately on the current thread. If Alchemic has not started then the block is copied, and executed after Alchemic has finished loading. It will be executed on the **main thread**.

### UIApplicationDelegate

Alchemic has some special processing for UIApplicationDelegates. After starting, Alchemic will automatically search for a UIApplicationDelegate and if it finds one, inject any dependencies it needs. So there is no need to add any `AcRegister(...)` macros to the app delegate class.

*Note: You can still use `AcRegister(...)` to give the application delegate a name if you like. By default, Alchemic will automatically add the application to its model and set it with your app's instance.*

## Callbacks and notifications

### Dependencies injected

Sometimes it's useful to know when Alchemic has finished injecting values into an object. To facilitate this, Alchemic supplies a protocol which is called after an object has had it's dependencies injected:

```objectivec
@interface MyClass : NSObject<AlchemicAware>
```

```objectivec
@implementation MyClass 
-(void) alchemicDidInjectDependencies {
    // Do stuff
}
@end
```

This method will automatically be called after all dependencies have been injected. You actually don't need to use the protocol as Alchemic simply looks for the method. The protocol is just a convenience. 

*Also note that this method is __ONLY__ called on classes which Alchemic is managing or when `AcInjectDependencies(...)` is used.*

### Finished loading

Once all singletons have been loaded and injected, Alchemic sends out a notification through the `NSNotificationCenter` object. There is a constant called `AlchemicFinishedLoading` in the `ALCAlchemic` class which can be used like this:

```objectivec
[[NSNotificationCenter 
    defaultCenter] addObserverForName:AlchemicFinishedLoading
                               object:nil
                                queue:[NSOperationQueue mainQueue]
                           usingBlock:^(NSNotification *notification) {
                                     // .. do stuff
                                     }];
```

This is most useful for classes which are not managed by Alchemic but still need to know when Alchemic has finished loading.

# Configuration

Alchemic needs no configuration out of the box. However sometimes there are things you might want to change before it starts. To do this, you need to create one or more classes and implement the `ALCConfig` protocol on them. Alchemic will automatically locate these classes during startup and read them for additional configuration settings. 

## Additional bundles

By default, Alchemic scans your apps main bundles sourced from `[NSBundle allBundles]` looking for Alchemic registrations and methods so it can setup it's model of your app. However you may have code residing in other bundles or frameworks that require injections as well. For example you might have setup a common framework for business logic. 

To let Alchemic know that there are further sources of classes that need injections, you need to implement the `scanBundlesWithClasses` method like this:

```objectivec
#import <Alchemic/Alchemic.>
@interface MyAppConfig : NSObject<ALCConfig>
@end

@implementation MyAppConfig

-(NSArray<Class> scanBundlesWithClasses {
    return @[[MyAppBusinessLogic class]];
}

@end
```

During scanning, Alchemic will read the list of classes. For each one, it will locate the bundle or framework that it came from and scan all classes within it. So you only need to refer to a single class to get all classes in it's bundle scanned.

# Circular dependencies

It's possible with dependencies to get into a situation where the dependencies of one object reference a second object which needs the first to resolve. In other words, a chicken and egg situation. 

Alchemic attempts to detect these endless loops of dependencies when it starts up by checking through the references that have been created by the macros and looking for loop backs. If it detects one it will immediately throw an exception.

Generally speaking though, they are actually quite hard to create because Alchemic creates as many objects as possible before injecting dependencies. So they are not depending on objects that do not yet exist. 

# Credits

 * Big Thanks to the guys behind [Carthage](https://github.com/Carthage/Carthage) for writing a dependency tool that actual works well with XCode and Git.
 * Thanks to the guys behind the [Spring Framework](https://spring.io). The work you have done has made my life so much easier on so many Java projects.
 * Thanks to Mulle Cybernetik for [OCMock](ocmock.org). An outstanding mocking framework for Objective-C that has enabled me to test the un-testable many times.
 * Thanks to Todd Ditchendorf for [PEGKit](https://github.com/itod/pegkit). I've learned a lot from working with it on [Story Teller](https://github.com/drekka/StoryTeller).
 
 


