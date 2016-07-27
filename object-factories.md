---
title: Object Factories
---

# Object factories

Object factories are the objects that describe your application classes to  Alchemic. They contain information on the class or method they represent, how it's to be instantiated or called and what injected values it needs.

## Class object factories

__Class Object Factories__ are the most common type of object factory used. One will be automatically created for any class that Alchemic finds registration methods in. They can then be updated with information about whether to build instances of your class or managed external ones, whether  objects should be instantiated through a custom initializer, and how to find and inject object dependencies.

This example is the simplest form of a registering a class. It will create an object factory which generates a singleton instance on startup.

{{ site.lang-title-objc }}
```objc
@implementation MyClass
AcRegister()
@end
```

{{ site.lang-title-swift }}
```swift
@objc class MyClass {
    @objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
    }
}
```

*Note: In Objective-C you only need to use __AcRegister__ if there are no other Alchemic declarations or you want to configure other aspects of the object factory. In Swift, the presence of the `alchemic()` method is enough to register the class as a singleton. Configuration can then be done inside that method.*

### Using initializers

By default, Alchemic will use the `init` method when initializing an instance of a class. However it can also use other initializers and arguments through __AcInitializer__.

{{ site.lang-title-objc }}
```objc
@implementation MyClass
AcInitializer(initWithOtherObject:, AcClass(MyOtherClass))
-(instancetype) initWithOtherObject:(MyOtherClass *) obj {
    // ...
}
@end
```

{{ site.lang-title-swift }}
```swift
@objc class MyClass {
   public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcInitializer(objectFactory, 
            initializer:"initWithMyOtherObject:", 
            args:AcClass(MyOtherClass.self)
        )
    }
   
    @objc init(myOtherClass: MyOtherClass) {
        // ...
    }
    
 }
```

__AcInitiailizer__ tells Alchemic which initializer to call and where to find any argument values it needs. See [Method arguments](method-arguments) for details on passing arguments. 


## Method object factories

[**Method Object Factories**](https://en.wikipedia.org/wiki/Factory_method_pattern) are the second form of object factory that Alchemic has. They are added to the model when Alchemic finds a __AcMethod__ declaration. 

__AcMethod__ tells Alchemic to call a method to create an object. Usually because the creation of the object is more complex than can be achieved with a simple class declaration or initializer. 

{{ site.lang-title-objc }}
```objc
@implementation MyDatabaseService 

AcMethod(Database, generateDatabaseConnection)
-(id<DBConnection>) generateDatabaseConnection {
    // Complex connection setup code.
    return dbConn;
}

@end
```

{{ site.lang-title-swift }}
```swift
@objc class MyDatabaseService 

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

*Note: Unfortunately the Objective-C runtime does not provide much information about methods and their arguments as languages such as Java do. So Alchemic needs you to specify a lot of the details so Alchemic can source the correct values to pass.*

__AcMethod__ can define any class or instance method as a source of objects. If it declares a instance method, Alchemic will ensure that the parent class is instantiated before the method is called. This allows the method to make use of those dependencies if it wants to when creating the return object. If the method is a class method then Alchemic will simply call it directly.


### Method arguments

Now lets look at method arguments. Both __AcInitializer__ and __AcMethod__ can take arguments which define where to find the values to pass to the method when it is executed. 

To see more on the types of values that can be used as method arguments, see [Injection types]({{ site.data.pages.injection-values }}).


#### Simple argument values

Firstly, you can specify a simple constant or single model search criteria.  Alchemic will use this information to determine the correct type of the argument.

{{ site.lang-title-objc }}
```objc
AcMethod(NSURLConnection, serverConnectionToServer:retries:,
    AcClass(MyServer),
    AcInt(5)
)
-(NSURLConnection *) serverConnectionToServer:(MyServer *) server 
retries:(int) retries {
    // ...
}
```

{{ site.lang-title-swift }}
```swift
@objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
    AcMethod(objectFactory, method: "serverConnectionToServer:retries:", type:NSURLConnection.self,
        AcClass(MyServer.self),
        AcInt(5)
    )
}
@objc func serverConnectionToServer(server:MyServer, retries:Int) -> NSURLConnection {
    // ...
}
```

Doing this, Alchemic assumes that the value you specify will match the target argument. So `AcInt(5)` assumes that the argument is an `int` and `AcClass(MyServer)` an argument of type `MyServer`.

However this is not always the case. If the type of the argument is different to the type of value being injected, or the model search criteria for the argument is more complex, we must use the __AcArg__ function to fill out the arguments details. 


#### Complex arguments

{{ site.lang-title-objc }}
```objc
AcMethod(NSURLConnection, serverConnectionToServer:retries:,
    AcArg(NSObject, AcProtocol(MyServerProtocol)),
    AcArg(NSUInteger, AcInt(5))
    )
)
```

{{ site.lang-title-swift }}
```swift
@objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
    AcMethod(objectFactory, method: "serverConnectionToServer:retries:", type:NSObject.self,
        AcArg(NSURL.self, AcProtocol(MyServerProtocol)),
        AcArg(NSUInteger.self, AcInt(5))
    )
}
```

The first argument to __AcArg__ defines the expected argument type. This is used when checking candidate values. After that comes the value to inject or model search criteria. It's possible to have more than one value here.


## Configuring Factories

Class and method factories also have a range of settings that configure how they operate. By default a class or method will assume that they are to genereate a singleton which Alchemic will manage and inject as needed.

But there are other options:

## Templates

Configuring an object factory as a template means that every time Alchemic needs to inject a value, the object factory will create a new one. This is different to the default mode where the factory only creates an object the first time, stores it and keeps returning the same instance. Templates never store the objects they create. 
 
Templates can be useful in a variety of situations. For example, an email message class could be declared as a template. Every time your code needs an instance, a new email message will be created and it's dependencies injected, ready for you to use. 

Templates are configured using the __AcTemplate__ flag macro:

{{ site.lang-title-objc }}
```objc
@implementation MyClass
AcRegister(AcTemplate)
@end
```

{{ site.lang-title-swift }}
```swift
@objc class Factory 
    public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcRegister(objectFactory, AcTemplate())
    }
}
```

Method factories follow the same pattern. Just add the __AcTemplate__ flag to the __AcMethod__ macro:

{{ site.lang-title-objc }}
```objc
@implementation MyClass 
AcMethod(Database, generateDatabaseConnection, AcTemplate)
-(id<DBConnection>) generateDatabaseConnection {
}
@end
```

{{ site.lang-title-swift }}
```swift
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

References are an alternatice to singletons and templates. They are most useful when dealing with UI classes such as `UIViewController` instances. 

References tell the object factory not to create objects at all. Instead external code will create the object and give it to Alchemic to inject dependencies and manage from there on.

The use case for this is view controllers. Typically they get created by storyboards. Upon creation, we can tell Alchemic to store a reference to it and inject it's dependencies. By storing the instance, Alchemic can then inject it into other objects.

{{ site.lang-title-objc }}
```objc
@implementation MyClass
AcRegister(AcReference)
@end
```

{{ site.lang-title-swift }}
```swift
@objc class Factory 
    public static func alchemic(objectFactory: ALCClassObjectFactory) {
        AcRegister(objectFactory, AcReference())
    }
}
```

*Note: Because references are created externally, it makes no sense for method factories to be configured as references. If you use __AcReference__ on a method factory declaration, Alchemic will throw an error.*

Once you have created a object, you can use __AcSet__ to pass it to Alchemic (see [Inline usage - Setting objects]({{ site.data.pages.runtime }}) for details):

{{ site.lang-title-objc }}
```objc
-(void) viewDidLoad {
    AcSet(self);
}
```

{{ site.lang-title-swift }}
```swift
override func viewDidLoad() {
    AcSet(self)
}
```

## Custom names

Objects are automatically given a name when they are registered. By default it's the class name or method name for method factories. For example:

Object factory | Name
--- | --- 
Class MyClass | MyClass
Method -[MyClass methodWithArg:] | -[MyClass methodWithArg:]

However you might want to change it to something more appropriate, especially with method names which are not that intuitive. To do this, you use __AcFactoryName__ to provide a custom name for the object factory:

{{ site.lang-title-objc }}
```objc
AcRegister(AcFactoryName(@"JSON date formatter"))
```

{{ site.lang-title-swift }}
```swift
public static func alchemic(objectFactory:ALCClassObjectFactory) {
    AcRegister(objectFactory, AcFactoryName("JSON date formatter"))
}
```

For example, one use custom names is you have several `NSDateFormatter` object factories. Using __ACFactoryName__ allows you to provide meaningful names such as  *'JSON date formatter'*, *'DB date formatter'*, etc.

*Note: names __must__ be unique or Alchemic will throw an error.*

## Primary objects

Sometimes we want to define an object factory as effectively being more important than others. A good example being when writing unit tests where you want to inset a dummy object. You want the dummy object factory to override the default one.

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




