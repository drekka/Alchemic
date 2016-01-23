# Quick guide - Objective-C

This guide is for using Alchemic with Objective-C sources.

Table of Contents

  * [Starting Alchemic](#starting-alchemic)
  * [Common Tasks](#common-tasks)
    * [Register a singleton instance](#register-a-singleton-instance)
    * [Register a singleton created by a method](#register-a-singleton-created-by-a-method)
    * [Register a factory with a name](#register-a-factory-with-a-name)
    * [Register a factory class using a custom initializer which finds all objects with a protocol](#register-a-factory-class-using-a-custom-initializer-which-finds-all-objects-with-a-protocol)
    * [Inject an object](#inject-an-object)
    * [Inject a generaliased reference with a specific type](#inject-a-generaliased-reference-with-a-specific-type)
    * [Inject an array of all objects with a protocol](#inject-an-array-of-all-objects-with-a-protocol)
    * [Register a override object in a unit test](#register-a-override-object-in-a-unit-test)
    * [Self injecting in non\-managed classes](#self-injecting-in-non-managed-classes)
    * [Getting a object in code](#getting-a-object-in-code)
    * [Using a factory initializer with custom arguments](#using-a-factory-initializer-with-custom-arguments)
    * [Register an aysnchronous startup block](#register-an-aysnchronous-startup-block)

## Install via Carthage [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

1. Add to your **Cartfile**:  
 `github "drekka/Alchemic" "master"`
2. Build dependencies:  
 `carthage update`
3. Drag and drop the following frameworks into your project:
 * **<project-root>/Carthage/Build/iOS/Alchemic.framework**
 * **<project-root>/Carthage/Build/iOS/AlchemicSwift.framework**
 * **<project-root>/Carthage/Build/iOS/StoryTeller.framework**
 * **<project-root>/Carthage/Build/iOS/PEGKit.framework**
4. Ensure  the above frameworks are added to a build phase that copies them to the **Framworks** Destination. Check out the [carthage documentation](https://github.com/Carthage/Carthage) for the details of doing this. 

# Starting Alchemic
 
Nothing to do! Magic happens!
 
# Common Tasks

This list is by no means complete. But it gives a good indicative summary of how you can use Alchemic in your application.
 
## Register a singleton instance

```swift
import AlchemicSwift

class MyClass {
    public static func alchemic(cb:ALCBuilder) {
        AcRegister()
    }
}
```

MyClass will be created on application startup and managed as a singleton by Alchemic. 

## Register a singleton created by a method

```swift
import AlchemicSwift

class MyClass

    public static func alchemic(cb:ALCBuilder)  {
        AcMethod(cb, method:"createSomeObjectWithArg:",
            type:SomeObjectClass.self,
            args:AcArg(ArgClass.self, source:AcName("ArgObjName"))
            )
    }

    @objc func createSomeObjectWithArg(argObject:ArgClass) -> SomeObjectClass {
	// Create it using the arg
	return newObj
    }
}
```

MyClass will be instantiated and managed as a singleton. SomeObjectClass will then be instantiated by calling the createSomeObjectWithArg: method. It will also managed as a singleton. 

## Register a factory with a name

```swift
class MyClass {
    public static func alchemic(cb:ALCBuilder) {
        AcRegister(cb, AcFactory(), AcWithName("Thing factory"))
    }
}
```

Every time a MyClass instance is required or requested, a new one will be created and returned.

## Register a factory class using a custom initializer which finds all objects with a protocol

```swift
@objc protocol MyProtocol {
}

class MyClass {
    public static func alchemic(cb:ALCBuilder) {
        AcRegister(cb)
        AcInitializer(cb, initializer:"initWithObjects:", 
        args:AcArg(NSArray.self, AcProtocol(MyProtocol.self))
        )
    }
    @objc init(objects:NSArray) {
        // Do stuff with passed array ...
    }
}
```

MyClass will be registered as a factory, using the initializer to create each instance. Note that we must use the Objective-C equivalent initializer name. The objects argument will be an array sourced from Alchemic managed objects which conform to the MyProtocol protocol. Note that when using protocols, they must be tagged with `@objc`.
 
## Inject an object

```swift
class MyClass {
    var otherThing:MyOtherClass
    public static func alchemic(cb:ALCBuilder) {
        AcRegister(cb)
        AcInject(cb, variable:"otherThing", type:MyOtherClass.self))
    }
}
```

Simplest form of injecting a value. The injected value will be found by searching the model for MyOtherClass objects. It is assumed that only one will be found and Alchemic will throw an error if there is zero or more than one.  

## Inject a generaliased reference with a specific type

```swift
class MyClass {
    var otherThing:MyProtocol
    public static func alchemic(cb:ALCBuilder) {
        AcRegister(cb)
        AcInject(cb, variable:"otherThing", type:MyOtherClass.self,
            source:AcClass(MyOtherClass.self)
        )
    }
}
```

This example shows how Alchemic can locate a specific object based on it's class (MyOtherClass) and inject into a variable which references a protocol.

## Inject an array of all objects with a protocol

```swift
@objc protocol MyProtocol {
}

class MyClass {
    var things:NSArray<MyProtocol>
    public static func(cb:ALCBuilder) {
        AcInject(cb, variable:"things", type:NSArray.self,
            source:AcProtocol(Myprotocol.self)
        )
    }
}
```

Locates all objects in Alchemic that conform to the MyProtocol protocol and injects them as an array.
  
## Register a override object in a unit test

```swift
class MySystemTests:XCTestCase {
    public static func alchemic(cb:ALCBuilder) {
        AcMethod(cb, method:"createOverride",
            type:MyClass.self,
            args:AcPrimary()
        )    
    }
    @objc func createOverride() -> MyClass {
       // Create the override
       return override
    }
}
```
 
Shows how you can use ALchemic registered methods in a unit test to generate objects and use them as overrides for objects in the application code. Mainly useful for substituting in dummy or fake instances for testing purposes. 
 
## Self injecting in non-managed classes

```swift
class MyClass {
    init(frame:GCRect) {
        AcInjectDependencies(self)
    }
}
```

The instance to have dependencies injected is not being created by Alchemic so after creating it, inject values.

## Getting a object in code

```swift
let obj:MyClass = AcGet(AcName("My instance"))
```

You must set a type on the variable when doing this because Alchemic examines this type via Swift generics so it knows what to return.

## Register an aysnchronous startup block

```swift
class MyController:UIViewController {
    func viewDidLoad() {
        AcExecuteWhenStarted {() -> Void in
            self.tableView.reloadData()
        }
    }
}
```

Called after Alchemic has finished loading. Use in code which could run before Alchemic has finished scanning your classes. As Alchemic runs on a background thread, this ensures that the code runs after it has finished loading.