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

