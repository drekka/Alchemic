# Alchemic [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
By Derek Clarkson

* [Intro](#intro)
  * [Swift support](#swift-support)
  * [Installation](#installation)
    * [<a href="https://github\.com/Carthage/Carthage">Carthage</a>](#carthage)
  * [Adding Alchemic to your code](#adding-alchemic-to-your-code)
    * [Objective\-C macros](#objective-c-macros)
    * [The registration method](#the-registration-method)
  * [The Alchemic data model](#the-alchemic-data-model)
    * [Class object factories](#class-object-factories)
      * [Using initializers](#using-initializers)
    * [Method object factories](#method-object-factories)
      * [Method arguments](#method-arguments)
  * [Injectable type](#injectable-type)
    * [Constants](#constants)
    * [Model objects by Class/Protocol](#model-objects-by-classprotocol)
    * [Model objects by Name](#model-objects-by-name)
    * [Array injections](#array-injections)
  * [Declaring injections](#declaring-injections)
    * [Variable dependencies](#variable-dependencies)
    * [Method arguments](#method-arguments-1)
      * [Nil method arguments](#nil-method-arguments)
  * [Singletons, factories and external references](#singletons-factories-and-external-references)
    * [Singletons](#singletons)
    * [Factories](#factories)
    * [References](#references)
      * [Setting references](#setting-references)
  * [Other object factory settings](#other-object-factory-settings)
    * [Custom names](#custom-names)
    * [Primary objects](#primary-objects)
      * [Primary objects and testing](#primary-objects-and-testing)
  * [Interfacing with Alchemic](#interfacing-with-alchemic)
    * [Manual dependency injections](#manual-dependency-injections)
    * [Getting objects using <strong>AcGet</strong>](#getting-objects-using-acget)
      * [Getting objects with <strong>AcInvoke</strong>](#getting-objects-with-acinvoke)
  * [Alchemic's boot sequence](#alchemics-boot-sequence)
    * [Managing the UIApplicationDelegate instance](#managing-the-uiapplicationdelegate-instance)
    * [UIViewControllers and Story Boards](#uiviewcontrollers-and-story-boards)
  * [Callbacks and notifications](#callbacks-and-notifications)
    * [Dependencies injected](#dependencies-injected)
    * [Notifications](#notifications)
  * [Additional configuration](#additional-configuration)
    * [Adding bundles &amp; frameworks](#adding-bundles--frameworks)
  * [Errors](#errors)
    * [Exceptions](#exceptions)
    * [Circular dependency detection](#circular-dependency-detection)
  * [Controlling Alchemic](#controlling-alchemic)
    * [Stopping Alchemic from auto\-starting](#stopping-alchemic-from-auto-starting)
    * [Manually starting](#manually-starting)
    * [The Alchemic context](#the-alchemic-context)
  * [Credits](#credits)
  
*Other documents:* 

* [Objective-C quick guide](./Quick guide - Objective-C.md)
* [Swift quick guide](./Quick guide - Swift.md)


#Intro

Alchemic is a [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) framework for iOS. It's job is to make your code simpler by managing your singletons and automating dependency injections. Of course it does a whole lot more.

___Main features___

* Engineered in Objective-C, supports usage in Objective-C and Swift projects.
* No external configuration or factory classes required.
* Automatically starts on a background thread.
* Objects can be created from classes, initializers or methods.
* Object defintions can be specified to be singletons, factories or externally created objects.
* Supports dynamic arguments to methods and initializers.
* Injected objects can be located by class, protocol or a unique name.
* Injection values can be constant values.
* Injected variables do not have to be exposed on public interfaces.
* objects can be specified as primary to allow them to give them priority when resolving.
* Automatic array injections.
* Automatic injection of UIApplicationDelegate dependencies.


# Swift support

Alchemic supports classes written in Swift. However the way you declare things is different because of various differences between the Objective-C and Swift languages. 

Objective-C is unable to understand some Swift constructs such as structs and protocol extensions. Therefore Swift classes and methods that are to be used by Alchemic must be annotated with `@objc` so that Alchemic can see them. 

When injecting values into properties, the type of the property must be an Objective-C type. 

Arguments passed to Alchemic, do not have to be Objective-C types. However they must eventually be resolvable to Objective-C types as per the Swift documentation. 


# Installation


## [Carthage](https://github.com/Carthage/Carthage)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

If your not using [Carthage](https://github.com/Carthage/Carthage), I would like to suggest that you take a look. IMHO it's a far superior dependency manager to Cocoapods, less intrusive and simpler to work with.

Add this to your __Cartfile__:

github "drekka/alchemic" > 2.0

Then run either the __bootstrap__ or __update__ carthage commands to download Alchemic from and compile it and it's dependencies into the  __<project-dir>/Carthage/Build/iOS/__ directory. You can then include the following frameworks into your project the same way you would add any other framework.

Framework | Description
--- | ---
Alchemic.framework | This is the Objective-C core of Alchemic. It's required for both Swift and Objective-C projects.
AlchemicSwift.framework | *ONLY* required for Swift projects. This framework provides the bridging functions that enable Swift to use Alchemic. 
Storyteller.framework | [Story Teller](https://github.com/drekka/StoryTeller) is a alternative logging framework I designed along side Alchemic.
PEGKit.framework | Used by StoryTeller.

*Note: You will need to ensure that all of these frameworks are added to your project and copied to the __Frameworks__ directory in your app.* 


# Adding Alchemic to your code

Alchemic is accessed from your implementation files. To use it, declare a module import at the top of your implementation (*.m files). 

```objc
// Objective-C
@import Alchemic;
```

```swift
// Swift
import AlchemicSwift
```

*Why is Alchemic in my implementations ? - A lot of Alchemic's power comes from how it integrates with your code and for this to work, it needs to enhance your code with it's own. This also means that it has the ability to access initializers and methods which are internal to your classes, thus keeping your header files clean and simple.*

___How Alchemic reads your code___

Alchemic is designed to be as unobtrusive as possible. But it still needs to know what you want it to do. With Objective-C source code you can use a single special method to declare objects, or makes use of a set of pre-processor macros. With Swift source code, only the special method is available because Swift cannot make use of macros.  


## Objective-C macros

The Objective-C pre-processor macros are designed to feel like a form of meta-data, similar to the way Java's annotations work. These macros are generally pretty simple and easy to remember and it's likely that within a short time you will being using them without much thought. Here's a quick example of using a macro:

```objc
// Objective-C
@implementation MyClass
AcRegister
@end
```

Yes ... *it's that simple to use!*

***Note: in the rest of this document, all Objective-C code example will use macros.*** 


## The registration method

Optional in Objective-C and required in Swift, add a special function to your class where you enter declarations for Alchemic:

```objc
@implementation MyClass 
+(void) alchemic:(ALCClassObjectFactory *objectFactory) {
    // Alchemic setup goes here.
}
@end
```

```swift
@objc class MyClass {
    @objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
        // Alchemic setup goes here.
    }
}
```

The passed `ALCClassObjectFactory` instance is one that Alchemic automatically created for the current class.


# The Alchemic data model

Before we look at resolving dependencies and injecting values, we first need to look at how Alchemic creates and manages objects. 

Alchemic maintains an in memory data model which is where it tracks all the objects you tell it about. As it scans the classes in your project and executes registration methods, it populates this model with data representing the declarations it finds. 


## Class object factories

__Class Object Factories__ are created from class definitions and define how to build instances of that class. They also also hold information about dependencies that the class needs to have injected and whether the objects should be instantiated through an initializer.

The simplest form of a declaring a class as a object factory is simply to register it as a singleton.

```objc
// Objective-C
@implementation MyClass
AcRegister()
@end
```

```swift
// Swift
@objc class MyClass {
    @objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
    }
}
```

Alchemic will create a class factory in the model based on finding these declarations and set it up as a singleton instance.

*Note: In Objective-C you only need to use __AcRegister__ if there are no other declarations present or if you want to configure other aspects of the class. In Swift, the presence of the `alchemic()` method is enough to register the class as a singleton.*


### Using initializers

By default, Alchemic will use the standard `init` method when initializing an instance of a class. However it also supports custom initializers and arguments.

```objc
// Objective-C
@implementation MyClass
AcInitializer(initWithOtherObject:, AcClass(MyOtherClass))
-(instancetype) initWithOtherObject:(MyOtherClass *) obj {
    // ...
}
@end
```

```swift
// Swift
@objc class MyClass {
    
    @objc func init(myOtherClass: MyOtherClass) {
        // ...
    }
    
    public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcInitializer(objectFactory, 
            initializer:"initWithMyOtherObject:", 
            args:AcClass(MyOtherClass.self)
        )
    }
}
```

__AcInitiailizer__ tells Alchemic that when creating an instance, which initializer it should use and where to find the argument values needed. 

See [Method arguments](method-arguments) for details on passing arguments. 


## Method object factories

[**Method Object Factories**](https://en.wikipedia.org/wiki/Factory_method_pattern) are defined when Alchemic finds the registration of a method which will be used to create objects. Usually this is because the creation of the object is more complex than can be achieved with a simple class declaration. 

```objc
// Objective-C
@implementation MyClass 

AcMethod(Database, generateDatabaseConnection)
-(id<DBConnection>) generateDatabaseConnection {
    // Complex connection setup code.
    return dbConn;
}

@end
```

```swift
// Swift
@objc class Factory 

    @objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcMethod(objectFactory,
            method:"generateDatabaseConnection",
            type:DBConnection.self
            )
    }

    @objc func generateDatabaseConnection() -> DBConnection {
        // Complex connection setup code.
        return dbConn
    }
}
```

*Note: Unfortunately the Objective-C runtime does not provide much information about methods. So in order for Alchemic to understand what it has to do, we must tell it a fair amount about the method's signature types.*

__AcMethod__ defines any method or function that can create objects. This is similar to __AcRegister__ in that it registers a source of objects which can be injected into other things. 

Before calling the method, Alchemic will first examine it to see if it's an instance method. If so, it will make sure the parent class is instantiated and dependencies injected before calling the method. This allows the method to make use of those dependencies if it wants to when creating the return object. 

If the method is a class (static) method, then Alchemic will simply call the method directly.


### Method arguments

Now lets take a look at a factory method with arguments. Just the same as __AcInitializer__, __AcMethod__ can take arguments which define the values to pass to the method. 

```objc
// Objective-C
AcMethod(NSURLConnection, serverConnectionWithURL:retries:,
    AcString(@"http://db"),
    AcInt(5)
)
-(NSURLConnection *) serverConnectionWithURL:(NSURL *) url 
retries:(int) retries {
    // lots of complex setup code here that creates newConnection.
    return newConnection;
}
```

```swift
// Swift
@objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
    AcMethod(objectFactory, method: "serverConnection:retries:", type:NSURLConnection.self,
        AcString("http://db"),
        AcInt(5)
    )
}
@objc func serverConnection(url:NSURL, retries:Int) -> NSURLConnection {
    // lots of complex setup code here that creates newConnection.
    return newConnection;
}
```

See [Method arguments](#method-arguments) for more details on passing arguments to methods.


# Injectable type

Before we can specify where to inject a value, we need to know where that value comes from.


## Constants

Some times you might want to specify a constant value for a dependency. Alchemic can use constant values for a number of standard types as follows:

Function | Produces (Objective-C, Swift)
--- | ---
AcBool(YES) | BOOL, Boolean
AcInt(5) | int, Int
AcLong(5) | long, Long
AcFloat(2.1) | float, Float
AcDouble(2.1) | double, Double
AcString(@"abc"), AcString("abc") | NSString * , String
AcObject([NSNumber numberWithInt:12]) | NSObject, Object
AcCGFloat(12.0) | CGFloat, CGFloat
AcSize(0, 0) | CGSize, CGSize
AcRect(0, 0, 100, 100) | CGRect, CGRect
AcNil() | id

Most of these functions are fairly simple to understand. __AcNil__ is a special case to be used when you want to set a nil value.

```objc
// Objective-C
AcInject(_message, AcValue(@"hello world"))
```

```swift
// Swift
class MyClass {
    var message:NSString
    public static func alchemic(objectFactory:ALCClassObjectFactory) {
        AcInject(objectFactory, variable:"message", type:NSString.self, AcValue("hello world"))
    }
}
```


## Model objects by Class/Protocol

You can tell Alchemic to search the model for objects based on their class and/or the protocols they conform to.

```objc
// Objective-C
AcInject(otherObj, AcClass(OtherClass))
AcInject(anotherObj, AcProtocol(MyProtocol))
AcInject(otherObj, AcClass(OtherClass), AcProtocol(MyProtocol))
``` 

```swift
// Swift
public static func Alchemic(objectFactory:ACLClassObjectFactory) {
    AcInject(objectFactory, variable:"otherObj", type:NSObject.self, source:AcClass(OtherClass.self))
    AcInject(cb, variable:"anotherObj", type:NSObject.self, source:AcProtocol(MyProtocol.self))
    AcInject(objectFactory, variable:"otherObj", type:NSObject.self, source:AcClass(OtherClass.self), AcProtocol(MyProtocol.self))
}
``` 

__AcInject__ can take only one __AcClass__ and as many __AcProtocol__s macros as you want. 

Where this is of most use is where your variables are quite general and you want to inject more specific types. For example, you can declare a protocol and inject a specific class. 

```objc
// Objective-C
@implementation {
    id<Account> *_account;
}
AcInject(_account, AcClass(AmexAccount))
@end
```

```objc
// Swift
class MyClass {
    var account:Account
    public static func alchemic(objectFactory:ALCClassObjectFactory) {
        AcInject(objectFactory, variable:"account", type:Account.self, source:AcClass(AmexAccount.self))
    } 
}
```

As programming to protocols is considered a good practice, this sort of injection allows you classes to be quite general in how they refer to other classes, yet you can still locate specific objects to inject.


## Model objects by Name

You can also inject an object by retrieving it based on the unique name assigned to it's factory when added to the model.

```objc
// Objective-C
@implementation MyClass {
NSDateFormatter *_jsonDateFormatter;
}
AcInject(_jsonDateFormatter_, AcName(@"JSON date formatter"))
@end
```

```swift
// Swift
class MyClass {
var jsonDateFormatter:NSDateFormatter
    public static func alchemic(objectFactory:ALCClassObjectFactory) {
        AcInject(objectFactory, variable:"jsonDateFormatter", type:NSDateFormatter.self, source:AcName("JSON date formatter"))
    }
}
```

Because __AcName__ will always refer to a single object factory, it must occur by itself.


## Array injections

Normally if an injection produces more than one value for a variable or method argument, then Alchemic will throw an error.

But Alchemic has a trick up it's sleeve which can be very useful. You can specify an array as the target variable or method argument type and Alchemic will automatically wrap all values found in an array and inject that. 

This is most useful when you have a number of model declarations of the same type or protocol. For example, if we want a list of all NSDateFormatters objects that Alchemic is managing:

```objc
// Objective-C
@implementation MyClass {
    NSArray<NSDateFormatter *> *_dateFormatters;
}
AcInject(_dateFormatters, AcClass(NSDateFormatter))
@end
```

```swift
// Swift
class MyClass {
    var dateFormatters:NSArray
    public static func alchemic(objectFactory:ALCClassObjectFactory) {
        AcInject(objectFactory, variable:"dateFormatters", type:NSArray.self, source:AcClass(NSDateFormatter.self))
    }
}
```

When processing candidate builders for an injection, Alchemic will automatically check if the target variable is an array and adjust it's injection accordingly, wrapping objects in NSArrays as required. 


# Declaring injections


##  Variable dependencies

The main point of a DI framework is to locate an objects dependencies and inject them into your objects for you. In other words, to save you from writing of a lot of [boiler plate](https://en.wikipedia.org/wiki/Boilerplate_code) code. 

Alchemic handles dependencies by injecting objects into variables previously declared in the class and referenced using the __AcInject__ function. Arguments to this function define the variable to inject and where to find the value to inject. 

*Note: Whilst Alchemic can inject values into properties as easily as variables, it does not trigger KVO when doing so. __So don't depend on KVO to detect injections__.*

```objc
// Objective-C
@implementation {
    MyOtherClass *_myOtherObj;
}
AcInject(myOtherObj)
@end
```

In Objective-C Alchemic can inject public properties, private properties and variables. You can also use the internal name of properties. So all of the following will work:

```objc
// Objective-C
@interface MyClass
@property(nonatomic, strong, readonly) MyOtherClass *myOtherObj;
@end

@implementation {
    MyOtherClass *_yetAnotherObj;
}
@synthesize myOtherObj = _internalObj;

AcInject(myOtherObj)
AcInject(_internalObj)
AcInject(_yetAnotherObj)
@end
```

When an injection only specifies the the variable name, Alchemic examines the variable for it's type. If it's an object type, Alchemic automatically finds out the class and protocols it conforms to. Alchemic then uses this information to locate candidate object in the model. 

```swift
// Swift
class MyClass
    var otherClass:MyOtherObj?
    public static func alchemic(objectFactory:ALCClassObjectFactory) {
        AcInject(objectFactory, variable:"otherObj", type:MyOtherClass.self))
    }
}
```

Swift is similar, however there are a couple of rules which don't apply to Objective-C: 

* You have to specify the type of the variable in __AcInject__. This is required because the Objective-C runtime that Alchemic uses is not able to determine the type of Swift variables as easily as it can when looking at Objective-C classes.
* The Swift variables have to be of a type that Alchemic can inject. This means classes which extend NSObject. Alchemic cannot inject Swift types such as String or Int. 


## Method arguments

When injecting a value into a method or initializer calls, Alchemic needs to know the type of the argument so it can ensure the value it's injecting is correct.

With simple injections using a constant value or single model search criteria, Alchemic assumes that the type of the argument will be a match for the value passed. So `AcInt(5)` will assume that the variable or argument is an `int`. 

If however, the type of the argument is different to the type of value being injected, or the model search criteria for the argument is more complex than a simple __AcClass__ or __AcProtocol__, we use the __AcArg__ function to fill out the arguments details. 

```objc
// Objective-C
AcMethod(NSURLConnection, serverConnectionWithURL:retries:,
    AcArg(NSURL, AcProtocol(MyCustomProtocol)),
    AcArg(NSUInteger, AcInt(5))
    )
)
```

```swift
// Swift
@objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
    AcMethod(objectFactory, method: "serverConnection:retries:", type:NSURLConnection.self,
        AcArg(NSURL.self, AcProtocol(MyCustomProtocol)),
        AcArg(NSUInteger.self, AcInt(5))
    )
}
```

The first argument to __AcArg__ defines the argument type. This is used when checking candidate values. After that comes the value to inject or model search criteria.


### Nil method arguments

You can also specify nils in method arguments using the __AcNil__ function. In addition, if the remaining arguments to a method are all to be set to nil, then simply leaving them out has the same effect as setting them to nil.


# Singletons, factories and external references 

Alchemic has three different ways of managing objects. 


## Singletons 

No matter what kind of appplication you are writing, you will probably have some objects are created once and used everywhere. These are usually referred to as [Singletons](https://en.wikipedia.org/wiki/Singleton_pattern). There are a number of opinions amongst developers about singletons and how they should be declared and used in code.

By default, Alchemic assumes that any class or method object factory represents a singleton unless told otherwise. It keeps one instance of the class in it's context and injects that same instance wherever it is needed. 

On startup, any object factory that represents a singleton instance will have that instance created and stored ready for use.


## Factories

Not to be confused with Alchemics Object Factories, factories in object management terms mean that every time an instance is needed, the relevant class or method will create a brand new one.
 
Factories can be useful in a variety of situations. For example, an email message class declared as a factory will create a new instance every time it's accessed. When Alchemic recogises an object factory as a factory instead of a singleton, it will create a new object each time it is referenced.

To tell Alchemic to treat a class registration as a factory, add __AcFactory__ to __AcRegister__ like this:

```objc
// Objective-C
@implementation MyClass
AcRegister(AcFactory)
@end
```

```swift
// Swift
@objc class Factory 
    public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcRegister(objectFactory, AcFactory())
    }
}
```

Method factoris follow the same pattern by adding __AcFactory__ to the __AcMethod__ declaration.

```objc
// Objective-C
@implementation MyClass 

AcMethod(Database, generateDatabaseConnection, AcFactory)
-(id<DBConnection>) generateDatabaseConnection {
}

@end
```

```swift
// Swift
@objc class Factory 

    @objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcMethod(objectFactory,
            method:"generateDatabaseConnection",
            type:DBConnection.self,
            AcFactory
            )
    }

}
```


## References

References are particular to iOS development. The idea is they declare that the object being managed will be created outside of Alchemic at some time in the future and passed to Alchemic for dependency injection and management. 

The use case for this is view controllers which are typically managed by storyboards, but we may still want to use Alchemic to inject their dependencies.

```objc
// Objective-C
@implementation MyClass
AcRegister(AcReference)
@end
```

```swift
// Swift
@objc class Factory 
    public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcRegister(objectFactory, AcReference())
    }
}
```

*Note: Because references are created externally, it makes no sense for method factories to declare as references. If you use __AcReference__ on a method factory declaration, Alchemic will throw an error.*


### Setting references

Once you have created a object, 
objects. You can use __AcSet__ to do this:

```objc
// Objective-C
-(void) myMethod {
MyObj *myObj = ... // create the object. 
AcSet(myObj, AcName(@"abc"));
}
```

```swift
// Swift
func myMethod() {
let myObj = ... // create the object. 
AcSet(myObj, inBuilderWith:AcName("abc"))
}
```

Alchemic will locate the matching builder for the criteria passed as arguments after the object and set the object as it's value. __ACName__ is most useful when setting values as __AcSet__ expects there to be only one builder found by the passed crtieria. If zero or more than one builder is returned, __AcSet__ will throw an error.

*Note: that setting a new object for a builder does not effect any previously injected references to the old object. Only injections done after setting the object will receive it.*


# Other object factory settings


## Custom names

Objects are automatically given a name when they are registered and by default it's the class name or method name for method factories.

Object factory | Name
--- | --- 
MyClass | MyClass
-[MyClass methodWithArg:] | -[MyClass methodWithArg:]

This name is indexed and can be used to find particular builder registrations quickly. However sometimes you might want to change it to something more appropriate, especially with method names. 

```objc
// Objective-C
AcRegister(AcWithName(@"JSON date formatter"))
```

```swift
// Swift
public static func alchemic(objectFactory:ALCClassObjectFactory) {
    AcRegister(objectFactory, AcWithName("JSON date formatter"))
}
```

For example, you might want to register several `NSDateFormatter` objects with Alchemic and give them names like *'JSON date formatter'*, *'DB date formatter'*, etc. Then when you need a `NSDateFormatter`, you can inject the relevant one by using __AcName__ to retrieve it.

*Note: names __must__ be unique or Alchemic will throw an error.*


## Primary objects

Sometimes there can be several possible candidate builders for a dependency, but we want some to be selected over others. Alchemic introduces the concept of ___Primary___ factories which it borrowed from the [*Spring framework*](http://spring.io). When multiple object factories can satisfy a dependency and at least one *'Primary'* factory is in the list, Alchemic will filter out the non-primary factories and continue with just the primary ones. 

Here's how to declare a Primary:

```objc
// Objective-C
AcRegister(AcPrimary)
```

```swift
// Swift
public static func alchemic(objectFactory:ALCClassObjectFactory) {
    AcRegister(objectFactory, AcPrimary())
}
```

*Whilst this can solve situations where multiple candidates for a dependency are presents, if Alchemic finds Multiple Primary builders for a dependency which is not an array, it will still raise an error.*


### Primary objects and testing

Primary object factories are most useful in testing. You can register mock or dummy classes from your test suites as a primary and when Alchemic loads, these test factories will become the defaults to be injected instead of the production objects, all without having to change a single line of code. But note here that even though you are specifying overrides, if the original objects are singletons, they will still be instantiated. 


# Interfacing with Alchemic

Now that we know how to declare objects and inject them, lets look at how we retrieve objects in classes and code which is not managed by Alchemic. In other words, how to get Alchemic to work with the rest of your app.


## Manual dependency injections

Depending on what you are doing in your app, you may need to create an object outside of Alchemic and then get Alchemic to inject the object's dependencies.

```objc
// Objective-C
-(instancetype) initWithFrame:(CGRect) aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        AcInjectDependencies(self);
    }
    return self;
}
```

```swift
// Swift
func init(frame:CGRect) {
    AcInjectDependencies(self)
}
```

__AcInjectDependencies__ does this. You can call it anywhere in your code and pass it the object whose dependencies you want injected. Alchemic will search for the closest matching Class factory and use that to inject any dependencies specified in the model.


## Getting objects using __AcGet__

Sometimes (in unit tests for example) you want to get an object from Alchemic without specifying an injection.

__AcGet__ allows you to search for and return an object (or objects) in a similar fashion to how __AcInject__ works. Except it's inline with your code rather than a one off injection and can be accessed as many times as you like.

```objc
// Objective-C
-(void) myMethod {
NSDateFormatter *formatter = AcGet(NSDateFormatter, AcName(@"JSON date formatter"));
// Do stuff ....
}
```

```swift
// Swift
func myMethod() {
var formatter:NSDateFormatter = AcGet(AcName(@"JSON date formatter"))
// Do stuff ....
}
```

In Objective-C __AcGet__ requires the first argument to be the type of what will be returned. This type is needed because the runtime does not know what is expected and Alchemic needs this information to finish processing the results. Especially if you are expecting an array back. In Swift, the runtime can deduce the type through Swift generics. 

Arguments after the type are search criteria used to find candidate builders. So __AcClass__, __AcProtocol__, __AcName__, or __AcValue__ can all be used to either search the context for objects or set a specific value. Note that __AcGet__ also does standard Alchemic `NSArray` processing. For example the following code will return an array of all Alchemic registered date formatters:

```objc
// Objective-C
-(void) myMethod {
NSArray *formatters = AcGet(NSArray, AcClass(NSDateFormatter));
// Do stuff ....
}
```

```swift
// Swift
func myMethod() {
var formatters = AcGet(NSArray.self, source:AcClass(NSDateFormatter))
// Do stuff ....
}
```

Finally, you can leave out the search criteria macros like this:

```objc
// Objective-C
-(void) myMethod {
NSDateFormatter *formatter = AcGet(NSDateFormatter);
// Do stuff ....
}
```

```swift
// Swift
func myMethod() {
var formatter = AcGet(NSDateFormatter.self)
// Do stuff ....
}
```

Without any criteria, Alchemic will use the passed return type to determine the search criteria for scanning the model based in it's class and any applicable protocols.


### Getting objects with __AcInvoke__

__AcInvoke__ is for when you want to access a declared method or initializer and pass in the arguments manually. But you don't have access to the object it's declared on or may not even know it.  For example, you might declare a factory initializer like this:

```objc
// Objective-C
AcInitializer(initWithText:, AcFactory, AcArg(NSString, AcValue(@"Default message")
-(instancetype) initWithText:(NSString *) message {
// ...
}
```

```swift
// Swift
public static func alchemic(cb:ALCBuilder) {
AcInitializer(cb, initializer:"initWithMessage:", 
args:AcArg(NSString.self, source:AcValue(@"Default message"))
)
}
func init(message:NSString) {
// ...
}
```

In this scenario you want the factory method to give you a new instance of the object when you need it, but with a different message. So you can it like this:

```objc
// Objective-C
-(void) myMethod {
MyObj *myObj = AcInvoke(AcName(@"MyObj initWithText:"), @"Message text");
// Do stuff ....
}
```

```swift
// Swift
func myMethod() {
var myObj = AcInvoke(AcName("MyObj initWithText:"), args:"Message text")
// Do stuff ....
}
```

__AcInvoke__ will locate all Alchemic declarations that match the first argument, which must be a search function. Normally it's __AcName__ because the usual scenario is to be address a specific method or initializer. Once Alchemic has located the method, it then invokes it (in the case of a normal method) or creates an instance using it if it is an initializer. In either case the method being addresses __must__ have been registered via __AcInitializer__ or __AcMethod__ so it can be found. 

Also note in the above example, we are using the default name for the method generated by Alchemic. Using __AcInvoke__ is one good reason to make use of __AcWithName__ to add custom names to registrations.


# Alchemic's boot sequence

Alchemic will automatically start itself when your application loads. It follows this logic:

1. Starts itself on a background thread so that your application's startup is not impacted.
2. Scans all classes in your app for dependency injection declarations. 
3. Resolves all references and configures an internal model based on the found declarations.
3. Instantiates any classes declared as Singletons and wire up their dependencies.  
4. Check for a UIApplicationDelegate and if found, injection any dependencies it has declared.
5. Post the ["AlchemicFinishedLoading"](#finished-loading) notification.


## Managing the UIApplicationDelegate instance

Alchemic has some special processing for `UIApplicationDelegates`. After starting, Alchemic will automatically search for a `UIApplicationDelegate` and if it finds one, inject any dependencies it needs. So there is no need to add any __AcRegister__ calls to the app delegate class. By default, Alchemic will automatically add the application to its model and set it with your app's instance.

*Note: You can still use __AcRegister__ to give the application delegate a name if you like.*


## UIViewControllers and Story Boards ##

Whilst I looked at several options for automatically injecting storyboard created instances of UIViewControllers, I did not find any technique that would work reliably and required less than a single line of code. So for the moment Alchemic does not inject dependencies into view controllers automatically. Instead, the simplest solution is to self inject in `awakeFromNib` or `viewDidLoad`.

```objc
// Objective-C
-(void) viewDidLoad {
    AcInjectDependencies(self);
}
```

```swift
// Swift
func viewDidLoad() {
    AcInjectDependencies(self)
}
```


# Callbacks and notifications


## Dependencies injected

Sometimes it's useful to know when Alchemic has finished injecting values into an object. To facilitate this, add the `AlchemicAware` protocol and implement the `alchemicDidInjectDependencies` method. Alchemic will automatically call this method after it has finished injecting values.

```objc
// Objective-C
@interface MyClass:NSObject<AlchemicAware>
@end 

@implementation MyClass 
-(void) alchemicDidInjectDependencies {
    // Do stuff
}
@end
```

```swift
// Swift
class MyClass:NSObject<AlchemicAware> {
    func alchemicDidInjectDependencies() {
        // Do stuff
    }
}
```


## Notifications

Once all singletons have been loaded and injected, Alchemic sends out a notification through the default `NSNotificationCenter`. There is a constant called `AlchemicFinishedLoading` in the `ALCAlchemic` class which can be used like this:

```objc
// Objective-C
[[NSNotificationCenter defaultCenter] 
    addObserverForName:AlchemicFinishedLoading
                object:nil
                 queue:[NSOperationQueue mainQueue]
            usingBlock:^(NSNotification *notification) {
    // .. do stuff
}];
```

```swift
// Swift
-- need example here --
```

This is most useful for classes which are not managed by Alchemic but still need to know when Alchemic has finished loading.


# Additional configuration

Alchemic needs no configuration out of the box. However sometimes there are things you might want to change before it starts. To do this, you need to create one or more classes and implement the `ALCConfig` protocol on them. Alchemic will automatically locate these classes during startup and read them for additional configuration settings. 


## Adding bundles & frameworks

By default, Alchemic scans your apps main bundles sourced from `[NSBundle allBundles]` looking for Alchemic registrations and methods so it can setup it's model of your app. However you may have code residing in other bundles or frameworks that require injections as well. For example you might have setup a common framework for business logic. 

To let Alchemic know that there are further sources of classes that need injections, you need to implement the `ALCConfig` protocol and scanBundlesWithClasses` method like this:

```objc
// Objective-C
@interface MyAppConfig : NSObject<ALCConfig>
@end

@implementation MyAppConfig
-(NSArray<Class> scanBundlesWithClasses {
    return @[[MyAppBusinessLogic class]];
}
@end
```

```swift
// Swift
class MyAppConfig:NSObject<ALCConfig>
    func scanBundlesWithClasses() -> NSArray<AnyClass> {
        return [MyAppBusinessLogic.self]
    }
}
```

During scanning, Alchemic will call this method for a list of classes. For each class returned, it will locate the bundle or framework that it came from and scan all classes within it. So adding an extra framework bundle is simply a matter of returning any class from that bundle.


# Errors


## Exceptions

All the errors generated by Alchemic are related to incorrect usage. For example, trying to set a factory method to be an external reference to an instance, or trying to inject multiple objects into a single variable. Because these are to be caught and dealt with by the developer, Alchemic throws them as instances of `ALCException`, which extends `NSException`. 

This is in line with [Apple's recommendations](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Exceptions/Exceptions.html#//apple_ref/doc/uid/10000012i) which indicate that exceptions should be used for programming errors and `NSError` references used for data errors. 


## Circular dependency detection

It's possible with dependencies to get into a situation where the dependencies of one object reference a second object which needs the first to resolve. In other words, a chicken and egg situation. 

Alchemic attempts to detect these endless loops of dependencies when it starts up by checking through the references that have been created by the macros and looking for loop backs. If it detects one it will immediately throw a `ALCCircularReferenceException` exception. 


# Controlling Alchemic

This section covers controlling Alchemic.


## Stopping Alchemic from auto-starting

If for some reason you do not want Alchemic to auto-start (unit testing perhaps), then you can do this by modifying XCode's scheme for the launch like this:

![Stop Alchemic from loading](./images/screen-shot-stop-alchemic.png)

___--alchemic-nostart___ - disables Alchemic's autostart function.


## Manually starting

Alchemic can programmatically started using:

```objc
// Objective-C
[Alchemic start];
```

```swift
// Swift
Alchemic.start()
```

But generally speaking, just letting Alchemic autostart is the best way.


## The Alchemic context

Alchemic has a central *'Context'* which manages all of the objects and classes that Alchemic needs. You generally don't need to do anything directly with the context as Alchemic provides a range of Objective-C *macros* and Swift functions which will take care of the dirty work for you. However should you need to access it directly, it can be accessed like this:

```objc
// Objective-C
[Alchemic mainContext] ...;
```

```swift
// Swift
Alchemic.mainContext()...
```


# Credits

* Thanks to Adam and Vitaly at Odecee who helped me with getting my head around some of the Swift code.
* Big Thanks to the guys behind [Carthage](https://github.com/Carthage/Carthage) for writing a dependency tool that actual works well with XCode and Git.
* Thanks to the guys behind the [Spring Framework](https://spring.io). The work you have done has made my life so much easier on so many Java projects.
* Thanks to Mulle Cybernetik for [OCMock](ocmock.org). An outstanding mocking framework for Objective-C that has enabled me to test the un-testable many times.
* Thanks to Todd Ditchendorf for [PEGKit](https://github.com/itod/pegkit). I've learned a lot from working with it on [Story Teller](https://github.com/drekka/StoryTeller).
