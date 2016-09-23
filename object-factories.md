---
title: Object Factories
---

 * [Class object factories](#class-object-factories)
    * [Using initializers](#using-initializers)
 * [Method object factories](#method-object-factories)
    * [Simple argument values](#simple-argument-values)
    * [Complex arguments](#complex-arguments)
 * [Configuring Factories](#configuring-factories)
    * [Template mode](#template-mode)
    * [Reference mode](#reference-mode)
    * [Custom names](#custom-names)
    * [Primary object factories](#primary-object-factories)
    * [Weak factories](#weak-factories)


# Object factories

Object factories describe your application's objects to Alchemic. They contain information on the class or method that generates them, how they are to be instantiated and what injections they need.

## Class object factories

__Class Object Factories__ are the most common type of object factory used. One will be automatically created for any class that Alchemic finds registration methods in. They contain information about whether to build instances of your class or managed external ones, whether objects should be instantiated through a custom initializer, and how to find and inject variable dependencies.

This example is the simplest form of a registering a class. It will create an object factory which generates a singleton instance on startup.

```objc
@implementation MyClass
AcRegister()
@end
```

```swift
{{ site.data.code.swift-class }} {
    {{ site.data.code.swift-alchemic-method }} {
    }
}
```

{{layout.objc}}
*Note: You only need to use __AcRegister__ if there are no other Alchemic declarations or you want to configure other aspects of the object factory.*

{{layout.swift}}
In Swift the presence of the `alchemic()` method is enough to register the class as a singleton. Configuration can then be done inside that method.*

### Using initializers

By default, Alchemic will use the `init` method when initializing an instance of a class. However it can also use other initializers and arguments through __AcInitializer__.

```objc
@implementation MyClass
AcInitializer(initWithOtherObject:, AcClass(MyOtherClass))
-(instancetype) initWithOtherObject:(MyOtherClass *) obj {
    // ...
}
@end
```

```swift
{{ site.data.code.swift-class }} {
    {{ site.data.code.swift-alchemic-method }} {
        AcInitializer(of, 
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

```objc
@implementation MyDatabaseService 

AcMethod(Database, generateDatabaseConnection)
-(id<DBConnection>) generateDatabaseConnection {
    // Complex connection setup code.
    return dbConn;
}

@end
```

```swift
{{ site.data.code.swift-class }} {
    {{ site.data.code.swift-alchemic-method }} {
        AcMethod(of,
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

*Note: Unfortunately the Objective-C runtime does not provide as much information about methods and their arguments as other runtimes such as the Java one do. So you need to specify the details so Alchemic can source the correct values to inject into the arguments.*

__AcMethod__ can define any class or instance method as a source of objects. If it declares a instance method, Alchemic will ensure that the parent class is instantiated before the method is called. This ensures that the factory method can make use of the parent class's injected values if required. On the other hand, if the method is a class method then Alchemic will simply call it directly.

### Simple argument values

Both __AcInitializer__ and __AcMethod__ can take arguments which define where to find the values to pass to the method when it is executed. To see more on the types of values that can be used as method arguments, see [Injection types]({{ site.data.pages.injection-values }}).

To that end, Alchemic can take a variety of criteria when you declare a method's arguments.

Firstly, you can specify a simple constant or single model search criteria.  Alchemic will use the type of the argument to determine the type of the argument being set.

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

```swift
{{ site.data.code.swift-alchemic-method }} {
    AcMethod(of, method: "serverConnectionToServer:retries:", type:NSURLConnection.self,
        AcClass(MyServer.self),
        AcInt(5)
    )
}
@objc func serverConnectionToServer(server:MyServer, retries:Int) -> NSURLConnection {
    // ...
}
```

Doing this, Alchemic assumes that the value you specify will match the target argument. So `AcInt(5)` assumes that the argument is an `int` and `AcClass(MyServer)` an argument of type `MyServer`.

### Complex arguments

When the argument critieria is more complex than a simple value, you can use __AcArg__ to define a more detailed criteria:

```objc
AcMethod(NSURLConnection, serverConnectionToServer:retries:,
    AcArg(NSObject, AcProtocol(MyServerProtocol)),
    AcArg(NSUInteger, AcInt(5))
    )
)
```

```swift
{{ site.data.code.swift-alchemic-method }} {
    AcMethod(of, method: "serverConnectionToServer:retries:", type:NSObject.self,
        AcArg(NSURL.self, AcProtocol(MyServerProtocol)),
        AcArg(NSUInteger.self, AcInt(5))
    )
}
```

The first argument to __AcArg__ defines the expected argument type. This is used when checking candidate values. After that comes the value to inject or model search criteria and it's possible to have more than one value here.


## Configuring Factories

Class and method factories also have a range of settings that configure how they operate. By default a class or method will create an object factory in singleton mode. This means that Alchemic will create and manage a single instance of the class, injecting it where necessary.

### Template mode

Configuring an object factory to use template mode tells it that every time Alchemic asks for an object, the object factory will create a new instance. Hence calling it template mode because it acts like a template, continuously creating new instances on each request. 
 
Templates can be useful in a variety of situations. For example, an email message class could be declared as a template. Every time your code request an instance from Alchemic, a new email message will be created, have it's dependencies injected and returned, ready for use. 

Templates are configured using __AcTemplate__:

```objc
@implementation MyClass
AcRegister(AcTemplate)
@end
```

```swift
{{ site.data.code.swift-class }} {
    {{ site.data.code.swift-alchemic-method }} {
        AcRegister(of, AcTemplate())
    }
}
```

Method factories follow the same pattern. Just add __AcTemplate__ to __AcMethod__:

```objc
@implementation MyClass 
AcMethod(Database, generateDatabaseConnection, AcTemplate)
-(id<DBConnection>) generateDatabaseConnection {
}
@end
```

```swift
{{ site.data.code.swift-class }} {
    {{ site.data.code.swift-alchemic-method }} {
        AcMethod(of,
            method:"generateDatabaseConnection",
            type:DBConnection.self,
            AcTemplate()
            )
    }
}
```


### Reference mode

Often you cannot use Alchemic to create objects. For example, `UIViewController` instances created by story boards, or instances created by other APIs. However you can still use Alchemic to manage them, inject their dependencies, and then inject them into other objects when needed. 

To manage these instances, set a class object factories into reference mode. This tells Alchemic not to create objects. Instead it assumes that you will pass the object to it at some stage in the future. Similar to what is commonly called 'Lazy' instantiation. 

```objc
@implementation MyClass
AcRegister(AcReference)
@end
```

```swift
{{ site.data.code.swift-class }} {
    {{ site.data.code.swift-alchemic-method }} {
        AcRegister(of, AcReference())
    }
}
```

*Note: Because the objects are created externally, it makes no sense for method factories to be configured as references. If you use __AcReference__ on a method factory declaration, Alchemic will throw an error.*

Once you have created a object, you can use __AcSet__ to pass it to Alchemic (see [Inline usage - Setting objects]({{ site.data.pages.runtime }}) for more details):

```objc
-(void) viewDidLoad {
    AcSet(self);
}
```

```swift
override func viewDidLoad() {
    AcSet(self)
}
```

### Custom names

Objects are automatically associated with a unique name when they are registered. By default it's the class name, or in the case of method factories - the method name. For example:

Object factory | Name
--- | --- 
Class MyClass | MyClass
Method -[MyClass methodWithArg:] | -[MyClass methodWithArg:]

Most of the time you probably don't need to care about these names. However there are situations where it's useful to be able to assign your own name. Especially with method names which are not that intuitive. To change the name associated with an object factory, use __AcFactoryName__ to provide a custom name:

```objc
AcRegister(AcFactoryName(@"JSON date formatter"))
```

```swift
{{ site.data.code.swift-alchemic-method }} {
    AcRegister(of, AcFactoryName("JSON date formatter"))
}
```

*Note: names __must__ be unique or Alchemic will throw an error.*

One good example of where this can be useful is when dealing with various method factories which produce similar types of objects.

```objc
AcMethod(NSDateFormatter, jsonDateFormatter, AcWithName(@"JSON date formatter"))
-(NSDateFormatter *) jsonDateFormatter { ... }

AcMethod(NSDateFormatter, displayDateFormatter, AcWithName(@"Display date formatter"))
-(NSDateFormatter *) displayDateFormatter { ... }
```

You can see examples of using these names in values - [model objects by name]({{site.data.pages.injection-values}}#model-objects-by-name) section. 

### Primary object factories

Sometimes we want to define an object factory as effectively being more important than others when deciding what to inject. A good example being unit tests where you want to insert a dummy/mock object into Alchemic's model. Effectively you want the dummy object factory to override the default one when injecting into other objects.

To solve this, Alchemic copies the concept of *__Primary__* object factories from the [*Spring framework*](http://spring.io). 

When Alchemic has located multiple object factories for a dependency and before injecting them, it checks each one to see if it's configured as a *'Primary'* object factory. If one or more are configured this way, then all the others are ignored and Alchemic only keeps the primaries for the injection. 

```objc
AcRegister(AcPrimary)
```

```swift
{{ site.data.code.swift-alchemic-method }} {
    AcRegister(of, AcPrimary())
}
```

*Whilst this can solve situations where multiple candidates for a dependency are presents, if Alchemic finds multiple Primary object factories for a dependency which is not an array, it will still raise an error.*

### Weak factories

Normally you want an object factory to retain the instance it is storing so that it is preserved for future injections. But there are times when you also want the object factory to store it weakly. 

An example of this is when setting up reference object factories for `UIViewController` instances. In this case, by setting the factories as weak, Alchemic does not interfere with the normal unloading of the view controllers and thus, avoids memory leaks. Simple use __ACWeak__ to configure the object factory.

```objc
AcRegister(AcWeak)
```

```swift
{{ site.data.code.swift-alchemic-method }} {
    AcRegister(of, AcWeak())
}
```

*Note: __AcWeak__ can only be specified on singleton or reference object factory types.* 


