# Alchemic [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
By Derek Clarkson
 
*Other documents:* 

* [Objective-C quick guide](./Quick guide - Objective-C.md)
* [Swift quick guide](./Quick guide - Swift.md)

# Intro #

Alchemic is a [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) framework for iOS. It's goal is to help you manage object creation, object properties and variables. And it should be as simple and easy to do this as possible.

___Main features___

* Engineered in Objective-C, usable in Objective-C and Swift projects.
* Definitions and injections are dynamically read from the runtime.
* Automatically started on a background thread.
* Objects can be instantiated using initializers or factory methods if desired.
* Objects can be managed as singletons, factories (templates) or externally sourced.
* Arguments to methods and initializers can be other objects or constants.
* Objects can be located using class, protocol or unique name searches.
* Works with implementation variables and methods, minimising public declarations.
* Automatic array boxing for injection.
* Automatic handling of UIApplicationDelegate instances.

# Swift support

Alchemic supports classes written in Swift with some caveats. Objective-C is unable to understand some Swift constructs such as structs and protocol extensions. 

 * Swift classes and methods that are to be used by Alchemic must be annotated with the `@objc` qualifier so Alchemic can see them. 
 * When injecting values into properties, the type of the property must be an Objective-C type. 
 * Arguments passed to Alchemic must be resolvable to Objective-C types as per the Swift documentation. 


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

*Note: You will need to ensure that all of these frameworks are added to your project and copied to the __Frameworks__ directory in your app using the* `carthage copy-frameworks` *command.*


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

*Why is Alchemic in my implementations ? - A lot of Alchemic's power comes from how it integrates with your code. By being in your implementation, it has the ability to access initializers and methods which are internal to your classes. This has the advantage of allowing you to keep your header files clean and simple.*

Alchemic is designed to be as unobtrusive as possible. With both Objective-C and Swift there is a special method you can declare which Alchemic will automatically find. Alternatively, if your project is written in Objective-C, there are also a set of pre-processor macros which can make things even easier.


## Objective-C macros

The Objective-C pre-processor macros are designed to feel like a form of meta-data, similar to Java's annotations. These macros are generally quite simple and easy to remember. For example:

```objc
// Objective-C
@implementation MyClass
AcRegister
@end
```

Yes ... *it's that simple to use!*

***Note: in the rest of this document, all Objective-C code example will use macros.*** 


## The registration method

Optional in Objective-C, but required in Swift, you can add the `+(void) alchemic:` method to your class where you configure Alchemic:

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


# The Alchemic data model

Alchemic maintains an in memory data model in which it stores all the information about  the objects you want to manage. When starting up, it scans the classes in your project, executing any registration methods it finds. 

This data model mostly contains __Object factories__. Object factories describe to Alchemic what sort of object you want it to manage and the dependencies they have. Object factories are almost always added to the model automatically when Alchemic scans you classes and finds particular methods which tell it what you want it to do. This is referred to as _registering_. 


## Class object factories

The first type of object factory Alchemic has are __Class Object Factories__. A class object factory is automatically created and stored in the model if Alchemic finds any registration methods in a class. This object factory can then be updated with information about whether to build instances of your class or managed external ones, whether  objects should be instantiated through a custom initializer, and how to find and inject the object's dependencies.

This example is the simplest form of a registering a class. It will create an object factory which generates a singleton.

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

*Note: In Objective-C you only need to use __AcRegister__ if there are no other declarations present. In Swift, the presence of the `alchemic()` method is enough to register the class as a singleton.*


### Using initializers

By default, Alchemic will use the `init` method when initializing an instance of a class. However it also supports custom initializers and arguments through the __AcInitializer__.

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
 
   public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcInitializer(objectFactory, 
            initializer:"initWithMyOtherObject:", 
            args:AcClass(MyOtherClass.self)
        )
    }
   
    @objc func init(myOtherClass: MyOtherClass) {
        // ...
    }
    
 }
```

__AcInitiailizer__ tells Alchemic which initializer it should use and where to find the argument values needed. See [Method arguments](method-arguments) for details on passing arguments. 


## Method object factories

[**Method Object Factories**](https://en.wikipedia.org/wiki/Factory_method_pattern) are the second form of object factory that Alchemic has. They are added to the model when Alchemic finds a __AcMethod__ declaration. __AcMethod__ tells Alchemic that the method selector passed as an argument can be used to create objects. Usually because the creation of the object is more complex than can be achieved with a simple class declaration or initializer. 

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

*Note: Unfortunately the Objective-C runtime does not provide much information about methods and their arguments. So Alchemic needs this information to be passed to __AcMethod__.*

__AcMethod__ can define any class or instance method as a source of objects. If it declares a instance method, Alchemic will ensure that the parent class is instantiated before the method is called. This allows the method to make use of those dependencies if it wants to when creating the return object. If the method is a class method then Alchemic can simply call it directly.


### Method arguments

Now lets look at methods with arguments. Both __AcInitializer__ and __AcMethod__ can take arguments which define the values to pass to the method when it is executed. 


#### Simple arguments

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

Alchemic needs to know is the type of the argument so it can ensure the value it's injecting is correct. If you are injecting a simple value using a constant or single model search criteria, Alchemic assumes that the type of the argument will be a match for the value passed. So `AcInt(5)` will assume that the variable or argument is an `int` and `AcClass(MyClass)` will be injected into an argument of type `MyClass`.

However, If the type of the argument is different to the type of value being injected, or the model search criteria for the argument is more complex, we must use the __AcArg__ function to fill out the arguments details. 


#### Complex arguments

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


#### Nil arguments

You can also specify nils in method arguments using the __AcNil__ function. In addition, if the remaining arguments to a method are all nil, then simply leaving them out has the same effect as setting them to nil.


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


e are usually referred to as [Singletons](https://en.wikipedia.org/wiki/Singleton_pattern). There are a number of opinions amongst developers about singletons and how they should be declared and used in code.

By default, Alchemic assumes that any class or method object factory represents a singleton unless told otherwise. It keeps one instance of the class in it's context and injects that same instance wherever it is needed. 

On startup, any object factory that represents a singleton instance will have that instance created and stored ready for use.


# Locating dependencies

When Alchemic encounters a initialiser or method argument, or a variable that needs a value injected. It must have be told where to obtains the value for it.


## Constants

Alchemic can inject constant values and has built in support for a number types:

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
AcNil | id

Most of these functions are fairly simple to understand. __AcNil__ is a special case to be used when you want to set a nil value (__AcNil()__ in Swift).

```objc
// Objective-C
AcInject(_message, AcString(@"hello world"))
```

```swift
// Swift
class MyClass {
    var message:NSString
    public static func alchemic(objectFactory:ALCClassObjectFactory) {
        AcInject(objectFactory, variable:"message", type:NSString.self, AcString("hello world"))
    }
}
```


## Model objects by Class/Protocol

You can tell Alchemic to search the model for object factories on their class and/or the protocols they conform to. After locating them, it then instantiates values from them for injection.

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

__AcClass__ tells Alchemic to locate object factories that produce objects of the specified type or a class that is derived from that type. __AcProtocol__ searches for object factories that produce objects which implement the specified protocol.

*Note: You can only use one __AcClass__, but as many __AcProtocol__ macros as you want.* 

Where this is of most useful is where your variables are quite general and you want to inject more specific types. For example, you can declare a protocol and inject a specific class. 

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

As programming to protocols is considered a good practice, this sort of injection allows you classes to be quite general in how they refer to other classes in the code, yet you can still locate specific objects to inject.


## Model objects by Name

You can also inject an object by retrieving it based on the unique name assigned to it's factory when added to the model. By default the name is the name of the class, or class and method. It can also be custom name.

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

*Note: object factory names are unique, so __AcName__ will always refer to a single factory. Therefore Alchemic will expect it to be the only search criteria.


## Array injections

It's possible that a model search will produce more than one value for a variable or method argument. Normally Alchemic will throw an error if this is the case.

But Alchemic has a trick up it's sleeve you can use in this situation. If you specify an array as the target type, Alchemic will automatically inject an array of all the objects produced by the factories instead of throwing an error. 

This is useful when you have a number of object factories for the same type or protocol. As an example, lets assume we have a number of  `NSDateFormatter` object factories registered:

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

This can be really useful when you go looking for objects which conform to a specific protocol.


# Configuring Factories #

Class and method factories also have a range of settings that configure how they operate.

## Templates

Configuring an object factory as a template means that every time  Alchemic needs an object, the object factory will create a new one. This is different to the default mode where the factory only creates an object the first time and stores it. Templates never store the objects they create. 
 
Templates can be useful in a variety of situations. For example, an email message class could declared as a template. Every time your code needs an instance, a new email message will be created. 

To tell Alchemic to configure an object factory as a template, add __AcTemplate__ to __AcRegister__ like this:

```objc
// Objective-C
@implementation MyClass
AcRegister(AcTemplate)
@end
```

```swift
// Swift
@objc class Factory 
    public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcRegister(objectFactory, AcTemplate())
    }
}
```

Method factories follow the same pattern. Just add __AcTemplate__ to the __AcMethod__ call:

```objc
// Objective-C
@implementation MyClass 

AcMethod(Database, generateDatabaseConnection, AcTemplate)
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
            AcTemplate()
            )
    }

}
```


## References

References are very useful. The idea is they tell the object factory not to create objects at all. Instead external code will create the object and the object factory will store the object and inject it's dependencies.

The use case for this is view controllers. Typically they get created by storyboards. Upon creation, we can tell Alchemic to store a reference to it and inject dependencies.  By storing a reference, Alchemic can then inject it into other objects.

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

*Note: Because references are created externally, it makes no sense for method factories to be configured as references. If you use __AcReference__ on a method factory declaration, Alchemic will throw an error.*

### Setting references

Once you have created a object, you can use __AcSet__ to store it in a reference type object factory:

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

Alchemic will locate the matching object factory for the criteria passed as arguments after the object. It will then set the object as it's value. __ACName__ is most useful when setting values as __AcSet__ expects there to be only one object factory to set. If zero or more than one object factory is found, __AcSet__ will throw an error.

*Note: that setting a new object for an object factory does not effect any previously injected references to the old object. Only injections done after setting the new object will receive it.*

## Custom names

Objects are automatically given a name when they are registered. By default it's the class name or method name for method factories. For example:

Object factory | Name
--- | --- 
Class MyClass | MyClass
Method -[MyClass methodWithArg:] | -[MyClass methodWithArg:]

However you might want to change it to something more appropriate, especially with method names which are not that intuitive. To do this, you use __AcFactoryName__ to provide a custom name for the object factory:

```objc
// Objective-C
AcRegister(AcFactoryName(@"JSON date formatter"))
```

```swift
// Swift
public static func alchemic(objectFactory:ALCClassObjectFactory) {
    AcRegister(objectFactory, AcFactoryName("JSON date formatter"))
}
```

For example, one use for custom names is you have several `NSDateFormatter` object factories. Using __ACFactoryName__ allows you to provide meaningful names such as  *'JSON date formatter'*, *'DB date formatter'*, etc.

*Note: names __must__ be unique or Alchemic will throw an error.*

## Primary objects

Sometimes we want to define an object factory as effectively being more important than others. A good example being when writing unit tests where you wan to inset a dummy object. You want the dummy object factory to override the default one.

To solve this, Alchemic introduces the concept of ___Primary___ object factories which it has borrowed from the [*Spring framework*](http://spring.io). 

When Alchemic has located multiple object factories for a dependency and before injecting them, it checks each one to see if it's configured as a *'Primary'* object factory. If one or more are configured this way, then all the others are ignored and Alchemic only injects the primary ones. 

Here's how to declare a Primary object factory:

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

## Weak factories

If you want to an object factory to hold not retain an object it is storing, you can configure the factory to hold a weak reference instead of the default strong reference using __AcWeak__: 

```objc
// Objective-C
AcRegister(AcWeak)
```

```swift
// Swift
public static func alchemic(objectFactory:ALCClassObjectFactory) {
    AcRegister(objectFactory, AcWeak())
}
```

*Note: __AcWeak__ can only be specified on singleton or reference object factory types.* 

The most common use case for __AcWeak__ is when configuring reference object factories for view controllers. By configuring them as weak, you can be assured that when the view controller is unloaded, that Alchemic will not keep it in memory.

# Interfacing with Alchemic

Now that we know how to declare objects and inject them, lets look at how we retrieve objects in classes and code which is not managed by Alchemic. In other words, how to get Alchemic to work with the rest of your app.

## Manual dependency injections

Alchemic will automatically inject dependencies into any object it instantiates or manages. There may be situations where you need to create objects independantly and would still like Alchemic to handle the injection of dependencies. This is where __AcInjectDependencies__ can be used.

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

You can call __AcInjectDependencies__ anywhere in your code and pass it the object whose dependencies you want injected. Alchemic will search for a matching Class factory and use that to inject any dependencies specified in the model.

## Getting objects

Sometimes (in unit tests for example) you want to get an object from Alchemic without specifying an injection. __AcGet__ allows you to search for and return an object (or objects) inline with your code rather than as an injection. 

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

In Objective-C __AcGet__ requires the first argument to be the type that will be returned. This type is needed because the runtime cannot tell Alchemic what is expected and it needs this information to finish processing the results. Especially if you are expecting an array back. In Swift, the runtime can deduce the type through Swift generics. 

Arguments after the type are search criteria used to find candidate builders. So __AcClass__, __AcProtocol__ or __AcName__ can all be used to search the context for objects. Of course it makes no sense to allow any of Alchemic's constants here so only model search criteria are allowed.

Note that __AcGet__ also does standard Alchemic `NSArray` processing. For example the following code will return an array of all Alchemic registered date formatters:

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

Also note in the above example, we are using the default name for the method generated by Alchemic. Using __AcInvoke__ is one good reason to make use of [__AcFactoryName__](#custom_names) to add custom names to registrations.


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

Alchemic needs no configuration out of the box. However sometimes there are things you might want to change before it starts. To do this, you need to create one or more classes and implement the `ALCConfig` protocol on them. Alchemic will automatically locate these classes during startup and read them for additional configuration.

## Additional bundles to scan

By default, Alchemic scans your apps main bundles sourced from `[NSBundle allBundles]` and examines each class if finds, looking for Alchemic registrations and methods to setup the model. However you may have classes in other bundles that use  Alchemic and you want Alchemic to scan those as well. For example you might have setup a common framework for business logic. 

To let Alchemic know that there are classes that need managing in that bundle, you need to implement the `ALCConfig` protocol `scanBundlesWithClasses` method like this:

```objc
// Objective-C
@interface MyAppConfig : NSObject<ALCConfig>
@end

@implementation MyAppConfig
+(NSArray<Class>) scanBundlesWithClasses {
    return @[[MyAppBusinessLogic class]];
}
@end
```

```swift
// Swift
class MyAppConfig:NSObject<ALCConfig>
    @objc static func scanBundlesWithClasses() -> NSArray<AnyClass> {
        return [MyAppBusinessLogic.self]
    }
}
```

During scanning, Alchemic will call this method for a list of classes. For each class returned, it will locate the bundle or framework that it came from and scan all classes within it. So adding an extra framework bundle is simply a matter of returning any class from that bundle.

## Custom setups

Another possible use case if where you need to configure Alchemic in a way that cannot be handled using the built-in macros. A use case would be to manage instances of a class that does not have Alchemic declarations. For example, a singleton service class from a framework that is not aware of Alchemic. 

To get around this sort of problem, add the `ALCConfig configure:(id<ALCContext>) context` like this:

```objc
// Objective-C
@interface MyAppConfig : NSObject<ALCConfig>
@end

@implementation MyAppConfig
+(void) configure:(id<ALCContext>) context {
    ALCClassObjectFactory of = [Context registerObjectFactoryForClass:[MyService class]];
    [context objectFactoryConfig:of, AcFactoryName(@"myService"), nil];
    [Context objectFactory:of registerVariableInjection:@"aVar", nil];
}
@end
```

```swift
// Swift
class MyAppConfig:NSObject<ALCConfig>
    @objc static func configure(context:ALCContext) {
        let of = context.registerObjectFactoryForClass(MyService.class);
        of.objectFactoryConfig:of, AcFactoryName("myService"), nil);
        of.objectFactory(of registerVariableInjection:"aVar", nil);
    }
}
```

Here we are telling Alchemic to create and manage a singleton instance of `MyService` which comes from an API framework that is not Alchemic aware.  

# Errors

## Exceptions

All the errors generated by Alchemic are related to incorrect usage. For example, trying to set a factory method to be an external reference to an instance, or trying to inject multiple objects into a single variable. Because these are to be caught and dealt with by the developer, Alchemic throws them as instances of `ALCException`, which extends `NSException`. 

This is in line with [Apple's recommendations](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Exceptions/Exceptions.html#//apple_ref/doc/uid/10000012i) which indicate that exceptions should be used for programming errors and `NSError` references used for data errors. 


## Circular dependency detection

It's possible with dependencies to get into a situation where the dependencies of one object reference a second object which needs the first to resolve. In other words, a chicken and egg situation. 

Alchemic attempts to detect these endless loops of dependencies when it starts up by checking through the references that have been created by the macros and looking for loop backs. If it detects one it will immediately throw a `ALCCircularReferenceException` exception. 


# Controlling Alchemic

This section covers manually controlling Alchemic.

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

* Thanks to Adam and Vitaly at [Odecee](http://odecee.com.au) who helped me with getting my head around some of the Swift code.
* Big Thanks to the guys behind [Carthage](https://github.com/Carthage/Carthage) for writing a dependency tool that actual works well with XCode and Git.
* Thanks to the guys behind the [Spring Framework](https://spring.io). The work you have done has made my life so much easier on so many Java projects.
* Thanks to Mulle Cybernetik for [OCMock](ocmock.org). An outstanding mocking framework for Objective-C that has enabled me to test the un-testable many times.
* Thanks to Todd Ditchendorf for [PEGKit](https://github.com/itod/pegkit). I've learned a lot from working with it on [Story Teller](https://github.com/drekka/StoryTeller).
* Finally thanks to everyone who writes the crappy software that inspires me to give things like this ago. You know who you are.
