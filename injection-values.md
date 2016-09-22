---
title: Injection types
---

* [Injection types](#injection-types)
       * [Constants](#constants)
     * [Model objects](#model-objects)
        * [By Class/Protocol](#by-classprotocol)
      * [By Name](#by-name)
    * [Array injections](#array-injections)

# Injection types

Alchemic has a range of things it can inject into a method argument or variable injection.

## Constants

Alchemic can inject constant values and has built in support for injecting  constant values including scalar types. Most of these are fairly simple to understand.

```objc
AcInject(_message, AcString(@"hello world"))
AcInject(_retries, AcInt(5))
```

```swift
{{ site.data.code.swift-class }} {
    var message:NSString
    {{ site.data.code.swift-alchemic-method }} {
        AcInject(of, variable:"message", type:NSString.self, AcString("hello world"))
        AcInject(of, variable:"retries", type:Int.self, AcInt(5))
    }
}
```

## Model objects

### By Class/Protocol

You can tell Alchemic to search the model for object factories on their class and/or the protocols they conform to. After locating them, it then instantiates values from them for injection.

{{ site.lang-title-objc }}
```objc
AcInject(otherObj, AcClass(OtherClass))
AcInject(anotherObj, AcProtocol(MyProtocol))
AcInject(otherObj, AcClass(OtherClass), AcProtocol(MyProtocol))
``` 

{{ site.lang-title-swift }}
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

{{ site.lang-title-objc }}
```objc
@implementation {
    id<Account> *_account;
}
AcInject(_account, AcClass(AmexAccount))
@end
```

{{ site.lang-title-swift }}
```objc
{{ site.data.code.swift-class }} {
    var account:Account
    {{ site.data.code.swift-alchemic-method }} {
        AcInject(of, variable:"account", type:Account.self, source:AcClass(AmexAccount.self))
    } 
}
```

As programming to protocols is considered a good practice, this sort of injection allows you classes to be quite general in how they refer to other classes in the code, yet you can still locate specific objects to inject.


### By Name

You can also inject an object by retrieving it based on the unique name assigned to it's factory when added to the model. By default the name is the name of the class, or class and method. It can also be custom name.

{{ site.lang-title-objc }}
```objc
@implementation MyClass {
NSDateFormatter *_jsonDateFormatter;
}
AcInject(_jsonDateFormatter_, AcName(@"JSON date formatter"))
@end
```

{{ site.lang-title-swift }}
```swift
{{ site.data.code.swift-class }} {
    var jsonDateFormatter:NSDateFormatter
    {{ site.data.code.swift-alchemic-method }} {
        AcInject(of, variable:"jsonDateFormatter", type:NSDateFormatter.self, source:AcName("JSON date formatter"))
    }
}
```

*Note: object factory names are unique, so __AcName__ will always refer to a single factory. Therefore Alchemic will expect it to be the only search criteria.


## Array injections

It's possible that a model search will produce more than one value for a variable or method argument. Normally Alchemic will throw an error if this is the case.

But Alchemic has a trick up it's sleeve you can use in this situation. If you specify an array as the target type, Alchemic will automatically inject an array of all the objects produced by the factories instead of throwing an error. 

This is useful when you have a number of object factories for the same type or protocol. As an example, lets assume we have a number of  `NSDateFormatter` object factories registered:

{{ site.lang-title-objc }}
```objc
@implementation MyClass {
    NSArray<NSDateFormatter *> *_dateFormatters;
}
AcInject(_dateFormatters, AcClass(NSDateFormatter))
@end
```

{{ site.lang-title-swift }}
```swift
{{ site.data.code.swift-class }} {
    var dateFormatters:NSArray
    {{ site.data.code.swift-alchemic-method }} {
        AcInject(of:"dateFormatters", type:NSArray.self, source:AcClass(NSDateFormatter.self))
    }
}
```

This can be really useful when you go looking for objects which conform to a specific protocol.




