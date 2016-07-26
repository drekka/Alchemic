---
title: Injections
---

Variable dependencies

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

### Nillable dependencies

Normally if Alchemic attempts to do an injection and the value to be injected resolves down to a nil, an exception will be thrown. However you can configure an injection using __AcWeak__ to tell Alchemic that it can inject nil values. 

```objc
// Objective-C
@implementation {
    MyOtherClass *_possiblyNil;
}

AcInject(_possiblyNil, AcWeak)
@end
```

### Transient dependencies

Configuring a dependency as transient tells Alchemic that you expect it to change from time to time. With transient dependencies, Alchemic watches all object factories that the dependency sources values from. When one of these values change, Alchemic automatically re-injects the dependency with the new values.

```objc
// Objective-C
@implementation {
    MyOtherClass *_changingInstance;
}

AcInject(_changingInstance, AcTransient)
@end
```

*Note: __AcTransient__ is only allowed in a limited set of situations. It can only be used when all the values for the injection are either singleton or reference factories. Constants are also not allowed.*

Transient injections trigger some additional processing by Alchemic. Firstly, when a factory has a transient dependency, the factory automatically tracks all the objects it has injected in a weak collection. Including objects created externally and injected via the __AcInjectDependencies__ function. It then starts watching all the factories that have been resolved by the transient dependencies. Finally when one of those watches reports a new value being set (for example, with __AcSet__), Alchemic then loops trough all the transient dependies and previously injected objects, and re-injects the updated values. 

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




