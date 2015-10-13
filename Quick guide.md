# Quick guide

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
3. Drag and drop **<project-root>/Carthage/Build/iOS/Alchemic.framework** into your workspace's dependencies.
4. Ensure  **Alchemic.framework**, **StoryTeller.framework** and **PEGKit.framework** are added to a build phase that copies them to the **Framworks** Destination. Check out the [carthage documentation](https://github.com/Carthage/Carthage) for the details of doing this. 

# Starting Alchemic
 
Nothing to do! Magic happens!
 
# Common Tasks

This list is by no means complete. But it gives a good indicative summary of how you can use Alchemic in your application.
 
## Register a singleton instance

```objectivec
@implementation MyClass
AcRegister()
...
```

MyClass will be created on application startup and managed as a singleton by Alchemic. 

## Register a singleton created by a method

```objectivec
@implementation MyClass
 
AcMethod(SomeOtherClass , createSomeOtherClassWithMyClass:, 
    AcArg(MyClass, AcName(@"MyClass"))
-(SomeOtherClass *) createSomeOtherClassWithMyClass:(MyClass *) myClass {
	// Create it
	return otherClass;
}
...
```

MyClass will be instantiated and managed as a singleton. SomeOtherClass will then be instantiated using the createSomeOtherClassWithMyClass: method and also managed as a singleton. 

## Register a factory with a name

```objectivec
@implementation MyClass
AcRegister(AcIsFactory, AcWithName(@"Thing factory"))
...
```

Every time a MyClass instance is required or requested, a new one will be created and returned.

## Register a factory class using a custom initializer which finds all objects with a protocol

```objectivec
@implementation MyClass
AcInitializer(initWithObjects:, AcArg(NSArray, AcProtocol(MyProtocol)))
-(instancetype) initWithObects:(NSArray<id<MyProtocol>> *objects {
    self = ...
    return self;
}
...
```

MyClass will be registered as a factory, using the initWithObjects: method to create each instance. The objects argument will be an array sourced from Alchemic managed objects which conform to the MyProtocol protocol.
 
## Inject an object

```objectivec
@implementation MyClass {
    MyOtherClass *_otherThing;
}
 AcInject(_otherThing)
...
```

Simplest form of injecting a value. The injected value will be found by searching the model for MyOtherClass objects. It is assumed that only one will be found and Alchemic will throw an error if there is zero or more than one.  

## Inject a generaliased reference with a specific type

```objectivec
@implementation MyClass {
    id<MyProtocol> _otherThing;
}
 AcInject(_otherThing, AcClass(MyOtherClass))
...
```

This example shows how Alchemic can locate a specific object based on it's class (MyOtherClass) and inject into a more generic variable.

## Inject an array of all objects with a protocol

```objectivec
@implementation MyClass {
    NSArray<id<MyProtocol>> *_things;
}
 AcInject(_things, AcProtocol(MyProtocol))
...
```

Locates all objects in Alchemic that conform to the MyProtocol protocol and injects them as an array.
  
## Register a override object in a unit test

```objectivec 
@implementation MySystemTests
AcMethod(MyClass, createOverride, AcIsPrimary)
-(MyClass *) createOverride {
   // Create the override
   return override;
}
```
 
Shows how you can use ALchemic registered methods in a unit test to generate objects and use them as overrides for objects in the application code. Mainly useful for substituting in dummy or fake instances for testing purposes. Could even be used to inject [OCMock](http://ocmock.org) objects.
 
## Self injecting in non-managed classes

```objectivec
-(instancetype) initWithFrame:(CGRect) aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        AcInjectDependencies(self);
    }
    return self;
}
```

The instance to have dependencies injected is not being created by Alchemic so after creating it, inject values.

## Getting a object in code

```objectivec
-(void) someMethod {
    MyClass *myClass = AcGet(MyClass, AcName(@"My instance"));
}
```

## Using a factory initializer with custom arguments

```objectivec
AcInitializer(initWithText:, AcIsFactory, AcWithName(@"createSomething"), AcArg(NSString, AcValue(@"Default message")
-(instancetype) initWithText:(NSString *) message {
    // ...
}
```

```objectivec
-(void) someMethod {
    MyObj *myObj = AcInvoke(AcName(@"createSomething"), @"Overriding message text");
}
```

Declaring a factory method and them calling it manually from other code. Notice that when calling the method there is no requirement to know what class it belongs to.

## Register an aysnchronous startup block

```objectivec
-(void) viewDidLoad {
    AcExecuteWhenStarted(^{
        [self reloadData];
    });
}
```

Called after Alchemic has finished loading. Use in code which starts at application startup. As Alchemic runs on a background thread, this ensures that the code runs after it has finished loading.