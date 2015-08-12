# Alchemic [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
By Derek Clarkson

Other documents: [What is Direct Injection (DI)?](./WhatIsDI.md), [Macro reference](./macros.md)

 * [Installation](#installation)
 * [Alchemic](#alchemic)
     * [Starting](#starting)
     * [Stopping](#stopping)
     * [Adding to your code](#adding-to-your-code)
     * [The context](#the-context)
 * [Macros](#macros)
 * [Creating objects](#creating-objects)
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
 * [Getting objects](#getting-objects)
     * [Unmanaged instances](#unmanaged-instances)
     * [Programmatically obtaining objects](#programmatically-obtaining-objects)
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

This should download Alchemic from this repository and compile it and it's dependencies into the  **<project-dir>/Carthage/Build/iOS/** directory. You can then include these frameworks into your project the same way you would add any other framework. Here's a list of what will be build:

Framework | Description
--- | ---
Alchemic.framework | This software.
Storyteller.framework | [Story Teller](https://github.com/drekka/StoryTeller) is a alternative logging framework. Add to your project along with Alchemic. 
PEGKit.framework | Used by StoryTeller and already included as a sub-framework. *You do not need to add this to your project.*

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

To use Alchemic you will need to do an import at the top of any source code where you will be adding Alchemic statements. This will be in the ***\*.m*** files as Alchemic works with the runtime and ignores header files.

```objectivec
#import <Alchemic/Alchemic.h>
```

*Because Alchemic works with the runtime, it accesses the classes rather than the headers. This means it can access methods and initializers that are not declared in headers or visible to other classes.  The advantage of this is that it gives you the ability to create initializers and methods which only Alchemic can see. This can make the interfaces declared in your headers much simpler.*

## The context

Alchemic has a central *'Context'* which manages all of the objects and classes that Alchemic needs. You generally don't need to do anything directly with the context as Alchemic provides a range of *macros* which will take care of the dirty work for you. However should you need to access it directly, it can be accessed like this:

```objectivec
[Alchemic mainContext] ...;
```

# Macros

Alchemic is designed to be as unobtrusive as possible. But it still needs to know a fair amount of information about your classes and methods. To achieve this it uses a sort of meta-data defined using a number of pre-processor macros. These macros are generally pretty simple and easy to remember and it's likely that within a short time you will being using them without much thought. 

Most of these macros take one or more arguments. For example the `AcArg(...)` macro takes at least two arguments and possibly more. To help keep the macros susinct and avoid you having to type needless boiler plate, there are some common conventions used:

 * When  macro needs a type, you only need to specify the relevant class or protocol. For example  
`AcProtocol(NSCopying)` is the macro form of  
 `[ALCProtocol withProtocol:@protocol(NSCopying)]`.
 * Selectors are also shortened by macros where needed. For example  
 `AcInitializer(myInitMethod)` is the macro form of  
 `[[ALCAlchemic mainContext] registerClassInitializer:classBuilder initializer:@selector(initializerSel), nil];`
 * Property names are also shortened. So that code completion can assist, they are **not** expressioned as strings. For example `AcInject(myVar)` 
 * Many macros make use of varadic lists so you can add as many criteria as you like in a single line.

# Creating objects

Before we look at resolving dependencies and injecting values, we first need to look at how we tell Alchemic about the objects we want to create.

## Singletons 

No matter what you are writing, you will need objects which are instantiated at the beginning of your app, are used by a variety of other objects, and only have a single instance. These are ususlly referred to as [Singletons](https://en.wikipedia.org/wiki/Singleton_pattern). There are a number of opinions amongst developers about singletons and how they should be declared and used in code. Alchemic's approach is to keep an instance of a singleton class in it's context and inject it where ever requested. It doesn't do anything to stop you creating other instances of that class outside of the context. However any request to Alchemic for an instance of a class that it views as a singleton will always return the same instance.

To declare a class as a singleton, use this macro in the class's implementation:
  
```objectivec
@implementation MyClass
AcRegister()
@end
```

The `AcRegister(...)` macro is how Alchemic recognises classes it will be managing, and it will auto-instantiate any registered classes as singletons on startup. This is the simplest form of registering a class with Alchemic.

*Note: Mostly there should only be one `AcRegister(...)` for a class. If you add another, a second instance of the class will then be registered. This can be useful in some situations, but generally it's not something that is commonly done.*

## Initializers

By default, Alchemic will use the standard `init` method when initializing an instance of a class. However this is not always the best option, so Alchemic provides a method for specifing a different initializer and how to locate any arguments it needs. Here's an example:

```objectivec
@implementation MyClass
AcInitializer(initWithOtherObject:, AcArg(MyOtherClass, AcClass(MyOtherClass))
-(instancetype) initWithOtherObject:(id) obj {
    // ...
}
@end
```

The `AcInitiailizer(...)` macro tells Alchemic that when it needs to create an instance of MyClass, it should use the `initWithOtherObject:` initializer. The first argument to this macro is required and specifies the initializer selector. After that is a series of `AcArg(...)` macros which define where to get the value for each argument that the selector has. 

`AcInitializer(...)` takes all the same macros that can be used with `AcRegister(...)` to define various attributes of the instance that will be created. In fact, there is no need to use `AcRegister(...)` at all as the arguments for it will be ignored when there is an `AcInitializer(...)` macro present.

### AcArg(type, search-criteria, ...)

`AcArg(...)` is a macro that helps both `AcInitializer(...)` and `AcMethod(...)` locate argument values to be passed to the methods they are going to be calling. The first argument to `AcArg(...)` is the type of the argument. After that is a list of one or more [Object search criteria](#object-search-criteria) which tell Alchemic where and how to obtain the value for that argument. 

## Factories

Sometimes you want to declare a class to Alchemic, but have Alchemic create a new instance every time you need the object. This is what Alchemic regards as a ***Factory***. Factories are not as common as singletons in the DI world, but they can be useful in a variety of situations. For example, you could declare a SMS message class as a factory. Then every time you need one, Alchemic will create a new SMS message object and give it to you with all it's dependencies injected.

To tell Alchemic to treat a class registration as a factory, add the `AcIsFactory` macro to the `AcRegister(...)` macro like this:

```objectivec
AcRegister(AcIsFactory)
```

Now every time yor code requests an instance of the class, a new one will be created and returned. 

## Object names

Objects are automatically given a name when they are registered. By default, it's the class name. If you  add the `AcName(...)` macro you can specify a custom name to use instead. This can be extremely useful when dealing with multiple similar registrations. For example, we might register several `NSDateFormatter` objects with Alchemic and give them names like *'JSON date formatter'*, *'DB date formatter'*, etc. Then when we need a `NSDateFormatter`, we can inject the relevant one by using `AcName(...) ` argument resolver as part of the injection.

Here's how we assign a custom name during registration:

```objectivec
AcRegister(AcWithName(@"JSON date formatter"))
```

## Generating objects using methods

*Note: This is a seperate subject because it's slightly more complex to setup than classes and dependencies.* 

Sometimes we want to use methods to create objects for injecting into dependencies. For example, we might want to have a method that generates a `Transaction` object based on some passed arguments and we want a new transaction each time we inject one into a class.

Unfortunately the Objective-C runtime does not track any information about the argument and return types of methods. Only for variables. It can tell us how many arguments there are and whether they are primitive types, structs or objects, but thats pretty much it. The up shot is that there is no way for Alchemic to automatically discover information about a method at runtime beyond this basic information. So when using methods we have to define more information so that Alchemic knows how to use it.

Lets take a look at two sample methods:

```objectivec
@implementation Factory {
    int x;
}

AcMethod(Database, generateDatabaseConnection)
-(id<DBConnection>) generateDatabaseConnection {
    // Complexe connection setup code.
    return dbConn;
}

AcMethod(NSString, makeATransaction, AcIsFactory))
-(NSString *) makeATransaction {
    return [[Transaction alloc] 
        initWithName:[NSString stringWithFormat:@"Transaction %i", ++x]];
}
@end
```

We use the `AcMethod(...)` macro to define ay method that can create objects. This macro is similar to `AcRegister(...)` in that it registers a source of objects which can be injected into other things. 

The first example creates a singleton instance. Alchemic will only call the method once and reuse the returned object every time it needs it. This allows you to utilise more complex code to setup singletons when you need it. The second example which generates transactions needs to generate a new one each time it is needed. So this one has the `AcIsFactory` flag. 

*Note: You will also notice that we don't need to register the class separately. Alchemic is smart enough to register the class automatically and create it hen necessary to access it's factory methods. If you want to tweak the class you can still use a `AcRegister(...) macro. Otherwise it's not needed.*

Factory method registrations are stored in the Alchemic context along side the classes. For their names, Alchemic uses a combination of the class and method selector. Like class registrations, you can make use of the `AcWithName(...)` macro to give a factory method a more meaningful and useful associated name. 

Now lets take a look at a factory method that takes arguments:

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

Here we need to use `AcArg(...)` macros that will allow Alchemic to locate values to be passed to the method's arguments. Alchemic uses this information to select appropriate values and pass them as method arguments to the factory method when it's creating an instance with it. It needs both the type of the argument and how to locate the value.

Unlike variable dependencies, which can appear in any order, `AcArg(...)` arguments **must appear in the same order as the selector arguments**. Alchemic will use the argument order to match the selector arguments.

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

Alchemic specifies dependencies in a very similar fashion to how it registers classes. Here's a basic dependency registration:

```objectivec
@interface MyClass
@property(nonatomic, assign, readonly) MyOtherClass *otherClass;
@end

@implementation
AcInject(otherClass)
// Rest of class ...
@end
```

The `Acinject(...)` macro does all the work of telling Alchemic that there is a dependency that needs to be injected into instances of the class. If there are no other arguments on the injection, Alchemic will lookup the variable based on the passed name, work out what class and protocols it implements, and use that information to locates potential candidates within the context. Alchemic can inject public properties like the above example, but also private properties and variables. You can also use the internal name of properties if you want. So all of the following will work:

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

## Object search criteria 

In order to inject a variable, Alchemic needs a way to locate potential values. Generally it can examine the variable and work out for itself what to inject. But often you might want to provide your own criteria for what gets injected. Plus there are some situations where Objective-C cannot provide Alchemic with the information it needs to work out what to inject. 

Lets look at how to take control of what is injected.

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
// Rest of class ...
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
// Rest of class ...
@end
```

Again we are making a general reference to a `NSDateFormatter`, but using the name assigned by Alchemic to locate the specific one needed for the injection.

### Constant values

Some times you might want to specify a constant value for a dependency. In this case we can use the `AcValue(...)` macro like this:

```objectivec
@implementation {
    NSString *_message;
}

AcInject(_message, AcValue(@"hello world"))
// Rest of class ...
@end
```

`AcValue(...)` cannot be used with any of the macros that perform searches for objects and must occur by itself. In other words, it makes no sense to define a search criteria that looks for objects and a constant value. It's either one or the other.

*Note: If defining arguments for a [factory method](#factory-method), `AcWithValue(...)` can be used for individual arguments along side other arguments that search the model for objects. See [Factory methods](#factory-methods) for more details.*

## Arrays

Alchemic has another trick up it's sleeve borrwed from the [*Spring framework*](http://spring.io). If you want to get an array of all the objects that match a [search criteria](#object-search-criteria), you can just specify to inject an array variable, and Alchemic will automatically inject a list of all objects that match the criteria. 

For example, if we want a list of all NSDateFormatters objects that Alchemic knows about:

```objectivec
@implementation {
    NSArray<NSDateFormatter *> *_dateFormatters;
}

AcInject(_dateFormatters, AcClass(NSdateFormatter))

@end
```

When processing the available objects to inject, Alchemic will automatically check for the target type being an array and adjust it's injection accordingly, wrapping objects in NSArrays as required.

# Getting objects

Now that we know how to declare objects and inject them, lets look at how we retieve objects in classes and code which is not managed by Alchemic. In other words, how to access objects in the rest of your app.

## Unmanaged instances

Not all objects can be created and injected by Alchemic. For example, UIViewControllers in storyboards are created by the storyboard. Whilst I looked at several options for automatically injecting these instances, I did not find any that worked reliably and didn't require a lot of effort to code. So for the moment Alchemic does not inject dependencies into these classes them automatically.

You can still declare dependencies in these classes and get them injected as if Alchemic had automatically done it. You just have to make the call to trigger the injection process programmatically like this:

```objectivec
-(instancetype) initWithFrame:(CGRect) aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        AcInjectDependencies(self);
    }
    return self;
}
```

You can add the `AcInjectDependencies(...)` macro anywhere in the class. For example you might do it in the `viewDidLoad` method lf a `UIViewController`. 

## Programmatically obtaining objects

Sometimes (in testing for example) you want to get an object from Alchemic without specifying an injection. this can be easily done via this macro:

```objectivec
NSDateFormatter *formatter = AcGet(NSDateFormatter, AcName(@"JSON date formatter"));
```

`AcGet(...)` requires the first argument to be the type of what will be returned. This type is needed because the runtime does not know what is expected to be returned and Alchemic needs this information to finish processing the results. 

Arguments after the type are search criteria macros used to find the object. So `AcClass(...)`, `AcProtocol(...)`, `AcName(...)`, `AcValue(...)` or '`AcProperty(...)` macros are all useable to either search the context for objects or set a specific value. Note that `AcGet(...)` also does standard Alchemic `NSArray` processing. For example the following code will return an array of all Alchemic registered date formatters:*

```objectivec
NSArray *formatters = AcGet(NSArray, AcClass(NSDateFormatter));
```

Finally, you can leave out the search criteria macros like this:

```objectivec
NSDateFormatter *formatter = AcGet(NSDateFormatter);
```

Without any criteria, Alchemic will use the passed return type to determine the search criteria for scanning the model based in it's class and any applicable protocols.

## Asynchronous startup

Alchemic bootstraps itself in a background thread rather than take up precious time during the  application start. However, it also means that any classes that make calls to `AcInjectDependencies(...)` may execute this call before Alchemic has finished reading the classes and building it's dependency model.

To address this Alchemic provides asynchronous callback which can be used in any code that runs at the beginning of your app and needs to ensure that something is execute ***After*** Alchemic has finished starting up. 

For example you might have a table view controller that needs data from a singleton that Alchemic injects. You should engineer the table view controller to work if the singleton dependency is nil, and to register a callback which refreshs the table after Alchemic has finished loading.

```objectivec
AcExecuteWhenStarted(^{
    [self.tableView reloadData];
});
```

If Alchemic has already started then the block is executed immediately on the current thread. If Alchemic has not started then the block is copied, and executed after Alchemic has finished loading on the **main thread**

*Note: Whilst Alchemic can inject values into properties as easily as variables, it does not trigger KVO at this time. So don't depend on KVO to detect injections.*

### UIApplicationDelegate

Alchemic has some special processing for UIApplicationDelegates. AFter starting, Alchemic will automatically search for a UIApplicationDelegate and if it finds one, inject any dependencies it needs. There is no need to add any `AcRegister(...)` macros to the app delegate class.

## Callbacks and notifications

### Dependencies injected

Sometimes it's useful to know when Alchemic has finished injecting values into an object. To facilitate this, Alchemic supplies a protocol which is called after an object has had dependencies injected:

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

This method will automatically be called after all dependencies have been injected. You actually don't need to use the protocol as Alchemic simply looks for the method. The protocol is just a conveniance. 

*Also note that this method is __ONLY__ called on classes which Alchemic is managing or when `AcInjectDependencies(...)` is used.*

### Finished loading

Once all singletons have been loaded and injected, Alchemic sends out a notification through the NSNotificationCenter object. There is a constant called `AlchemicFinishedLoading` in the `ALCAlchemic` class which can be used like this:

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

By default, Alchemic scans your apps main bundles for classes. This is sourced from `[NSBundle allBundles]`. Alchemic also scans the Alchemic framework itself for internal classes. However you may have code residing in other bundles or frameworks that require injections as well. For example you might have setup a common framework for business logic. 

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
 
 


