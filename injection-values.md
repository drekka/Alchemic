---
title: Injection types
---

* [Constants](#constants)
* [Model objects](#model-objects)
    * [By Class/Protocol](#by-classprotocol)
    * [By Name](#by-name)
* [Array injections](#array-injections)

# Injection types

Alchemic can inject a range of different types of data into a method's argument or variable injection.

# Constants

Firstly, Alchemic can inject constant values and has built in support for injecting constant values including scalar types. Check out the [Reference page](ref.html) for the full list and examples. Most of these are fairly simple to understand.

```objc
NSString *_message;
int _retries;

AcInject(_message, AcString(@"hello world"))
AcInject(_retries, AcInt(5))
```

```swift
{{ site.data.code.swift-class }} {
    var message:NSString?
    var retries:CInt = 0
    
    {{ site.data.code.swift-alchemic-method }} {
        AcInject(of, variable:"message", type:NSString.self, AcString("hello world"))
        AcInject(of, variable:"retries", type:ALCType.int, AcInt(5))
    }
}
```

{{layout.swift}}
When injecting variables into Swift classes there are a number of issues to be aware of. Alchemic is written in Objective-C and therefore uses the Objective-C runtime to handle low level stuff such as injecting variables. Because of this, Swift types which are not visible to Objective-C cannot be injected. 

{{layout.swift}}
So when dealing with strings, you need to declare your variable using the Objective-C `NSString` type. Numbers must use their equivalent Swift types - `CInt` for ints, `CDouble` for doubles, `CFloat` for floats etc. Also with numbers, you cannot declare them as optional. ie. No `!` or `?` modifiers. Objective-C does not understand Swift's optionals and will fail to inject them.

{{layout.swift}}
Finally note that in the above examples there is an extra argument to `AcInject`. The `type` argument is needed to tell Alchemic they type of the variable being injected. Unlike when looking at Objective-C classes, Alchemic cannot deduce from the runtime the types of Swift variables and needs to be explicitly told. This argument can take one of two types of data. First a `ALCType` which describes the type of the variable being injected. All the most popular solar types have static methods such as `ALCType.int` to generate this value. 

{{layout.swift}}
Secondly, it can take a `Class`. So if the target variable is (for example) an `NSArray`, then passing `NSArray.self` is valid.


# Model objects

You can also tell Alchemic to search the model for object factories that match various criteria, and then get the objects into inject from the found factories. 

## By Class/Protocol

The most commonly used criteria for a model search, is to search based on the class and/or protocols that an object implements. After locating the factories that manage objects of the required type, Alchemic then instantiates values from them to pass to the injection.

```objc
AcInject(otherObj, AcClass(OtherClass))
AcInject(anotherObj, AcProtocol(MyProtocol))
AcInject(otherObj, AcClass(OtherClass), AcProtocol(MyProtocol))
``` 

```swift
{{ site.data.code.swift-alchemic-method }} {
    AcInject(of, variable:"otherObj", type:NSObject.self, source:AcClass(OtherClass.self))
    AcInject(of, variable:"anotherObj", type:NSObject.self, source:AcProtocol(MyProtocol.self))
    AcInject(of, variable:"otherObj", type:NSObject.self, source:AcClass(OtherClass.self), AcProtocol(MyProtocol.self))
}
``` 

__AcClass__ tells Alchemic to locate object factories that produce objects of the specified type or a class that is derived from that type. __AcProtocol__ searches for object factories that produce objects which implement the specified protocol.

*Note: You can only use one __AcClass__, but as many __AcProtocol__ macros as you want.* 

Where this is of most useful is where your variables are quite general and you want to inject more specific types. For example, you can declare a protocol and inject a specific class. 

```objc
@implementation {
    id<Account> *_account;
}
AcInject(_account, AcClass(AmexAccount))
@end
```

```objc
{{ site.data.code.swift-class }} {
    var account:Account
    {{ site.data.code.swift-alchemic-method }} {
        AcInject(of, variable:"account", type:Account.self, source:AcClass(AmexAccount.self))
    } 
}
```

*Note: As programming to protocols is considered a good practice, protocol based injections allow your classes to be quite general in how they related to other classes in the code. They also make testing a lot easier.*


## By Name

You can also inject an object by retrieving it based on the unique name assigned to it's factory when it was added to the model. For class factories, the default is the name of the class. For method factories it's the method signature. It can also be a custom name you assign.

```objc
@implementation MyClass {
NSDateFormatter *_jsonDateFormatter;
}
AcInject(_jsonDateFormatter_, AcName(@"JSON date formatter"))
@end
```

```swift
{{ site.data.code.swift-class }} {
    var jsonDateFormatter:NSDateFormatter
    {{ site.data.code.swift-alchemic-method }} {
        AcInject(of, variable:"jsonDateFormatter", type:NSDateFormatter.self, source:AcName("JSON date formatter"))
    }
}
```

*Note: The advantage of using names is that they are unique, so __AcName__ will always refer to a single factory. Therefore there is no need to combine it with any other search criteria and Alchemic will throw an error if you do.*

# Array injections

It's possible that a model search will produce more than one value for a variable or method argument and normally Alchemic will throw an error if this is the case.

But Alchemic has a trick up it's sleeve as well - If you specify an array as the target type, Alchemic will automatically inject an array of all the objects produced by the factories instead of throwing an error. 

This is useful when you have a number of object factories for the same type or protocol. As an example, lets assume we have a number of  `NSDateFormatter` object factories registered:

```objc
@implementation MyClass {
    NSArray<NSDateFormatter *> *_dateFormatters;
}
AcInject(_dateFormatters, AcClass(NSDateFormatter))
@end
```

```swift
{{ site.data.code.swift-class }} {
    var dateFormatters:NSArray
    {{ site.data.code.swift-alchemic-method }} {
        AcInject(of:"dateFormatters", type:NSArray.self, source:AcClass(NSDateFormatter.self))
    }
}
```

This can be really useful when you go looking for objects which conform to a specific protocol.




