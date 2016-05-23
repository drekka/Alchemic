# Alchemic [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
By Derek Clarkson

### Other documents: 

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

# Creating objects

Before we look at resolving dependencies and injecting values, we first need to look at how we tell Alchemic about the objects we want to create. 

Alchemic maintains an in memory data model. As it scans the classes in your project and executes registration methods, it populates this model with data representing the declarations it finds. 

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

*Note: In Objective-C you only need to use __AcRegister__ if there are no other declarations present or you want to configure other aspects of the singleton. In Swift, the presence of the `alchemic()` method is enough to register the class as a singleton.*

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

__AcInitiailizer__ tells Alchemic that when it needs to create an instance of MyClass, what initializer it should use, and where to find the argument values needed. 

See [Declaring method arguments](#declaring-method-arguments) for details on passing arguments. 

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

Before calling the method, Alchemic will first examine it to see if it's an instance method. If so, it will make sure the parent class is instantiated and dependencies injected before calling the method. This allows the methof to make use of those dependencies if it wants to. 

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

See [Declaring method arguments](#declaring-method-arguments) for details on passing arguments.

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

# Declaring method arguments

You have already seen the simplest form of __AcInitializer__ or __AcMethod__ argument where we simply declare `AcInt(5)`, `AcClass(MyOtherClass)`, etc. However this is actually not enough for Alchemic to set a method argument. It also needs to know what type of value it is injecting. So when Alchemic get passed a simple value like this, it automatically assumes that the argument type is the same type as the value passed.
If however, we need to specify the type of the argument because it's different to the type of value being passed, or the criteria for that value is more complex than a sigle value, we use the __AcArg__ function. 

```objc
// Objective-C
AcMethod(NSURLConnection, serverConnectionWithURL:retries:,
    AcArg(NSString, AcString(@"http://db")),
    AcArg(int, AcInt(5))
    )
)
```

```swift
// Swift
@objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
    AcMethod(objectFactory, method: "serverConnection:retries:", type:NSURLConnection.self,
        AcArg(String.self, AcString("http://db")),
        AcArg(Int.self, AcInt(5))
    )
}
```

The first argument to __AcArg__ defines the argument type. This is used when checking candidate values. After that is a list of one or more [Object search criteria](#object-search-criteria). Value for an argument can come from other model objects, or can be defined as [constant values](). 

*Note: Arguments must be in the same order as the selector's arguments so that Alchemic can match them.*

## Constant values

Some times you might want to specify a constant value for a dependency. In this case we can use __AcValue__ like this:

```objc
// Objective-C
@implementation MyClass {
NSString *_message;
}
AcInject(_message, AcValue(@"hello world"))
@end
```

```swift
// Swift
class MyClass {
var message:NSString
public static func alchemic(cb:ALCBuilder) {
AcInject(cb, variable:"message", type:NSString.self, AcValue("hello world"))
}
}
```

__AcValue__ cannot occur with any of the search functions. __AcValue__ can also pass a nil to the target method if you want.

## Model searches

In order to inject a variable, Alchemic needs a way to locate potential values. Generally it can examine the variable and work out for itself what to inject. But often you might want to provide your own criteria for what gets injected. Plus there are some situations where the runtime cannot provide Alchemic with the information it needs to work out what to inject. 

### Searching by Class and Protocols

You can tell Alchemic to ignore the type information of the dependency you are injecting and define your own class and/or protocols to use for selecting candidate objects. Here's an example:

```objc
// Objective-C
AcInject(otherObj, AcClass(OtherClass))
AcInject(anotherObj, AcProtocol(MyProtocol))
``` 

```swift
// Swift
public static func Alchemic(cb:ALCBuilder) {
AcInject(cb, variable:"otherObj", type:NSObject.self, source:AcClass(OtherClass.self))
AcInject(cb, variable:"anotherObj", type:NSObject.self, source:AcProtocol(MyProtocol.self))
}
``` 

__AcInject__ can take any number of Alchemic commands which are used to locate candidate builders. But you can only specify one __AcClass__ and as many __AcProtocol__s macros as you want. It's quite useful when your variables are quite general and you want to inject more specific types. 

For example, assuming that `AmexAccount` implements the `Account` protocol, we can write this:

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
class {
var account:Account
public static func alchemic(cb:ALCBuilder) {
AcInject(cb, variable:"account", type:Account.self, source:AcClass(AmexAccount.self))
} 
}
```

As programming to protocols is considered a good practice, this sort of injection allows you classes to be quite general in how they refer to other classes, yet you can still locate specific objects to inject.

### Searching by Name

Earlier on we discussed storing objects under custom names in the context so they can be found later. Here's an example of how we use a custom name to locate a specific instance of an object:

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
public static func alchemic(cb:ALCBuilder) {
AcInject(cb, variable:"jsonDateFormatter", type:NSDateFormatter.self, source:AcName("JSON date formatter"))
}
@end
}
```

Again we are making a general reference to a `NSDateFormatter`, but using the name assigned by Alchemic to locate the specific one needed for the injection.

__AcName__ must occur by itself as a criteria for finding builders as __AcClass__ and __AcProtocol__ become redundant when is used.

## Nils

Nils can also be passed as arguments. To do this you use __AcValue__ with a nil argument as __AcArg__'s source. Alternatively, if *all* the remaining arguments to a method are nil, then simply leaving them out has the same effect as setting them to nil.

Here are some other examples of the above declaration with nils: 

```objc
// Objective-C
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

```swift
// Swift
public static func alchemic(cb: ALCBuilder) {
// Passing a nil URL.
AcMethod(cb, method: "serverConnection:retries:", type:NSURLConnection.self,
AcArg(NSURL.self, source:AcValue(nil)),
AcArg(NSNumber.self, source:AcValue(5))
)
// Passing a nil retries.
AcMethod(cb, method: "serverConnection:retries:", type:NSURLConnection.self,
AcArg(NSURL.self, source:AcName("db-server-url"))
)
// All arguments are nil.
AcMethod(cb, method: "serverConnection:retries:", type:NSURLConnection.self)
}
```

## Injecting into arrays

Alchemic has another trick up it's sleeve borrowed from the [*Spring framework*](http://spring.io). If you want to get an array of all the objects that match a [search criteria](#object-search-criteria), you can just specify to inject an array variable, and Alchemic will automatically inject a `NSArray` instance containing all objects that match the criteria. 

For example, if we want a list of all NSDateFormatters objects that Alchemic is managing:

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
public static func alchemic(cb:ALCBuilder) {
AcInject(cb, variable:"dateFormatters", type:NSArray.self, source:AcClass(NSDateFormatter.self))
}
}
```

When processing candidate builders for an inejction, Alchemic will automatically check if the target variable is an array and adjust it's injection accordingly, wrapping objects in NSArrays as required. 

*Note: If the target variable is not an `NSArray` type and multiple objects are found, them Alchemic will throw an error.*




# Other object factory settings

## Custom names

Objects are automatically given a name when they are registered and by defaultit's the class name. This name is indexed and can be used to find particular builder registrations quickly. However the name of the class is not always the best choice, so Alchemic provides a way to index the builder under a name of your choosing. Adding the __AcWithName__ macro to the builder registration you can specify a custom name to use to index the builder. 

```objc
// Objective-C
AcRegister(AcWithName(@"JSON date formatter"))
```

```swift
// Swift
public static func alchemic(cb: ALCBuilder) {
AcRegister(cb, AcWithName("JSON date formatter"))
}
```

An example of using naming might be that you register several `NSDateFormatter` objects with Alchemic and give them names like *'JSON date formatter'*, *'DB date formatter'*, etc. Then when you need a `NSDateFormatter`, you can inject the relevant one by using __AcName__ to locate it by name.

*Note: names __must__ be unique. This aids in searching for objects to inject.*


## Primary objects

When we have several possible candidate builders for a dependency, we might not want to use custom names to get the exact one we want, but we still need to be able to select just one. Alchemic can define one builder as the default one for these situations. It has the concept of ___Primary___ objects which it borrowed from the [*Spring framework*](http://spring.io). 

The basic idea is that when multiple builders can satisfy a dependency, you can flag one of them as the *'Primary'* builder. If Alchemic has more than one possible candidate builder for an injection and one of them is tagged as a primary, it will automatically choose that builder as the one to use. 

Here's how to declare a Primary:

```objc
// Objective-C
AcRegister(AcPrimary)
```

```swift
// Swift
public static func alchemic(cb:ALCBuilder) {
AcRegister(cb, AcPrimary())
}
```

Primary objects are ___only___ checked once a list of candidate builders for ain injection have been located. This ensure that they don't override more specific criteria.

*Whilst this can solve situations where multiple candidates for a dependency are presents, if Alchemic finds Multiple Primary buildr for a dependency, it will still raise an error.*

### Primary objects and testing

Primary builders are most useful in testing. You can register mock or dummy classes from your test suites as Primaries. When Alchemic loads, these test builders will then become the defaults to be injected instead of the production objects, all without having to change a single line of code.

# Injecting dependencies

The main point of a DI framework is to locate an objects dependencies and inject them without you having to write code to do it. In other words, to save the writing of a lot of [boiler plate](https://en.wikipedia.org/wiki/Boilerplate_code) code. Alchemic specifies variable dependencies using __AcInject__ with a variety of arguments telling it what to inject. 

*Note: Whilst Alchemic can inject values into properties as easily as variables, it does not trigger KVO when doing so. __So don't depend on KVO to detect injections__.*

## Objective-C 

Here's a basic Objective-C example:

```objc
// Objective-C
@interface MyClass
@property(nonatomic, strong, readonly) MyOtherClass *otherObj;
@end

@implementation
AcInject(otherObj)
// Rest of class ...
@end
```

When being used in Objective-C source code, Alchemic can inject public properties like the above example, but also private properties and variables. You can also use the internal name of properties if you want. So all of the following will work:

```objc
// Objective-C
@interface MyClass
@property(nonatomic, strong, readonly) MyOtherClass *otherObj;
@end

@implementation {
YetAnotherClass *_yetAnotherObj;
}

AcInject(otherObj)
AcInject(_otherObj)
AcInject(_yetAnotherObj)
// Rest of class ...
@end
```

When there is no arguments after the variable name, Alchemic will it up based on the name, work out what class and protocols the variable's type implements, and use that information to locates potential candidates within the context. 

## Swift

Here's a simple Swift example of specifying an injection:

```swift
// Swift
class MyClass
var otherClass:MyOtherObj?
public static func alchemic(cb: ALCBuilder) {
AcInject(cb, variable:"otherObj", type:MyOtherClass.self))
}
}
```

There are a couple of rules when specifying injections in Swift: 

* You have to specify the type of the variable in __AcInject__. This is required because the Objective-C runtime that Alchemic uses is not able to determin the type of Swift variables as easily as it can when looking at Objective-C classes.
* The Swift variables have to be a tupe that Alchemic can inject. This means classes which extend NSObject. Alchemic cannot inject Swift types such as String or Int. 



# Interfacing with Alchemic

Now that we know how to declare objects and inject them, lets look at how we retrieve objects in classes and code which is not managed by Alchemic. In other words, how to get Alchemic to work with the rest of your app.

## Non-managed objects

Not all objects can be created and injected by Alchemic. For example, UIViewControllers in storyboards are created by the storyboard.  However you can still declare dependencies in these classes and get them injected as if Alchemic had created them. 

Firstly when registering class injections, either avoid adding __AcRegister__, or add the __AcExternal__ flag. Either method will tell Alchemic to use the builder for declaring injections only and to not create any instances. 

Later in your code you can make a call to trigger the injection process programmatically like this:

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

You can add __AcInjectDependencies__ anywhere in the class. For example you might do it in the `viewDidLoad` method instead. 

*Whilst I looked at several options for automatically injecting storyboard created instances, I did not find any technique that would work well and required less code. So for the moment Alchemic does not inject dependencies into them automatically.*

## Programmatically obtaining objects

Sometimes (in testing for example) you want to get an object from Alchemic without specifying an injection.

### Getting objects using __AcGet__

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

### Setting values with __AcSet__

Sometimes you have created an object outside of Alchemic, but want Alchemic to manage it. For example, you might have a view controller you want Alchemic to inject into other objects. You can use __AcSet__ to do this:

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

# Alchemic's boot sequence

Alchemic will automatically start itself when your application loads. It follows this logic:

1. Starts itself on a background thread so that your application's startup is not impacted.
2. Scans all classes in your app for dependency injection declarations. 
3. Resolves all references and configures an internal model based on the found declarations.
3. Instantiates any classes declared as Singletons and wire up their dependencies.  
4. Check for a UIApplicationDelegate and if found, injection any dependencies it has declared.
5. Post the ["AlchemicFinishedLoading"](#finished-loading) notification.

*Look at [Asynchronous startup](#asynchronous-startup) for more details on Alchemic's starting and how to know when you can access objects.*


## Asynchronous startup

Alchemic bootstraps itself in a background thread rather than taking up precious time during your application's startup. However, it also means that any classes that make calls to __AcInjectDependencies__ may attempt to execute before Alchemic has finished reading the classes and building it's model of your application.

To address this Alchemic provides an asynchronous callback which can be used in any code that runs at the beginning of your app and needs to ensure that something is execute after Alchemic has finished starting up. 

For example, you might have a table view controller that needs data from a singleton that Alchemic injects. To deal with this situation, you should engineer the table view controller to work if the singleton dependency is nil, and to register a callback which refreshes the table after Alchemic has finished loading like this:

```objc
// Objective-C
-(void) viewDidLoad {
AcExecuteWhenStarted(^{
[self.tableView reloadData];
});
}
```

```swift
// Swift
func viewDidLoad() {
AcExecuteWhenStarted {() -> Void in
self.tableView.reloadData()
}
}
```

If Alchemic has already finished starting then the block is executed immediately on the current thread. If Alchemic has not started then the block is copied, and executed after Alchemic has finished loading. It will then be executed on the __main thread__.

## Managing the UIApplicationDelegate instance

Alchemic has some special processing for `UIApplicationDelegates`. After starting, Alchemic will automatically search for a `UIApplicationDelegate` and if it finds one, inject any dependencies it needs. So there is no need to add any __AcRegister__ calls to the app delegate class. By default, Alchemic will automatically add the application to its model and set it with your app's instance.

*Note: You can still use __AcRegister__ to give the application delegate a name if you like.*

## Callbacks and notifications

### Dependencies injected

Sometimes it's useful to know when Alchemic has finished injecting values into an object. To facilitate this, a protocol is available which is called after an object has had it's dependencies injected:

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

This method will automatically be called after all dependencies have been injected. You actually don't need to use the protocol as Alchemic simply looks for the method. The protocol is just a convenience. 

*Also note that this method is __ONLY__ called on classes which Alchemic is managing or when __AcInjectDependencies__ is used.*

### Finished loading

Once all singletons have been loaded and injected, Alchemic sends out a notification through the `NSNotificationCenter` object. There is a constant called `AlchemicFinishedLoading` in the `ALCAlchemic` class which can be used like this:

```objc
// Obejctive-C
[[NSNotificationCenter 
defaultCenter] addObserverForName:AlchemicFinishedLoading
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

To let Alchemic know that there are further sources of classes that need injections, you need to implement the `scanBundlesWithClasses` method like this:

```objc
// Objective-C
#import <Alchemic/Alchemic.h>
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
import Alchemic
class MyAppConfig:NSObject<ALCConfig>
func scanBundlesWithClasses() -> NSArray<AnyClass> {
return [MyAppBusinessLogic.self]
}
}
```

During scanning, Alchemic will read the list of classes. For each one, it will locate the bundle or framework that it came from and scan all classes within it. So you only need to refer to a single class to get all classes in it's bundle scanned.

# Errors

## Exceptions

Alchemic deals with errors by throwing exceptions. This is in line with [Apple's recommendations](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Exceptions/Exceptions.html#//apple_ref/doc/uid/10000012i) which indicate that exceptions should be used for programming errors and `NSError` references used for data errors. All the errors generated by Alchemic are related to incorrect usage. For example, trying to set a factory method to be an external reference to an instance, or trying to inject multiple objects into a single variable. Because these are to be caught and dealt with by the developer, Alchemic throws them as exceptions.  

## Circular dependency detection

It's possible with dependencies to get into a situation where the dependencies of one object reference a second object which needs the first to resolve. In other words, a chicken and egg situation. 

Alchemic attempts to detect these endless loops of dependencies when it starts up by checking through the references that have been created by the macros and looking for loop backs. If it detects one it will immediately throw an exception. 

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




