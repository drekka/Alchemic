---
title: Object Factories
---

# Class object factories

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

Configuring Factories #

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




