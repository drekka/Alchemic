---
title: Injections
---

# Variable injections

The main point of a DI framework is to locate an objects dependencies and inject them into it for you. In other words, to save you from writing of a lot of [boiler plate](https://en.wikipedia.org/wiki/Boilerplate_code) code. 

Alchemic handles dependencies by injecting objects into your class's variables using the __AcInject__ macro. Arguments to __AcInject__ define the variable to inject and where to find the value to be set. 

*Note: Whilst Alchemic can inject values into properties as easily as variables, it does not trigger KVO when doing so. __So don't depend on KVO to detect injections__.*

In Objective-C Alchemic can inject public properties, private properties and private variables. You can also use the internal name of properties. So all of the following will work:

{{ site.lang-title-objc }}
```objc
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

When an injection only specifies the the variable name as the above examples do, Alchemic examines the variable for it's type information. it's class, protocols it conforms to, etc. Alchemic uses this information to locate candidate object factories in the model. Then it collects the values from those factories and sets the variable with the objects it's found. 

In Swift, an injection is declared like this:

{{ site.lang-title-swift }}
```swift
class MyClass
    var otherClass:MyOtherObj?
    public static func alchemic(objectFactory:ALCClassObjectFactory) {
        AcInject(objectFactory, variable:"otherObj", type:MyOtherClass.self))
    }
}
```

Swift has a couple of rules that don't apply to Objective-C: 

* You have to specify the type of the variable in __AcInject__. This is required because the Objective-C runtime that Alchemic uses is not able to determine the type of Swift variables as easily as it can when looking at Objective-C classes.
* The Swift variables have to be of a type that Alchemic can inject. This means classes which extend NSObject. Alchemic cannot inject Swift types such as String, Ints or structs. 

## Nillable dependencies

Normally if Alchemic attempts to do an injection and the value to be injected resolves down to a nil, an exception will be thrown. However you can configure an injection using __AcNillable__ to tell Alchemic that it can inject nil values. 

{{ site.lang-title-objc }}
```objc
@implementation {
    MyOtherClass *_possiblyNil;
}

AcInject(_possiblyNil, AcNillable)
@end
```

## Transient dependencies

Sometimes you want to have a dependency re-injected if the value changes. For example, you might have a view controller which gets created a number of times and you want to inject it into another class. 

For these sorts of scenarios you can tag a dependency as transient using the __AcTransient__ macro. This tells Alchemic to watch the object factories and if one of them changes it's value, to then re-inject the dependency automatically. 

In addition, when a class object factory has a transient dependency, it tracks all the objects it has injected. When a reinjection is needed, the factor will automatically reinject all of the objects it knows about.

{{ site.lang-title-obc }}
```objc
@implementation {
    MyOtherClass *_changingInstance;
}

AcInject(_changingInstance, AcTransient)
@end
```

*Note: __AcTransient__ is only allowed in a limited set of situations. It can only be used when all the values for the injection are either singleton or reference factories. Constants are also not allowed.*



