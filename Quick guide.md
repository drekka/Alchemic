# Quick guide

## Install via Carthage [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

1. Add to your **Cartfile**:  
 `github "drekka/Alchemic" "master"`
2. Build dependencies:  
 `carthage update`
3. Drag and drop **<project-root>/Carthage/Build/iOS/Alchemic.framework** into your workspace's dependencies.
4. Ensure  **Alchemic.framework** is added to a build phase that copies it to the **Framworks** Destination. 

## Starting Alchemic
 
Nothing to do!
 
## Common Tasks

This list is by no means complete. but it gives a good indicative summary of what you can do.
 
### Register a singleton

```objectivec
@implementation MyClass
AcRegister()
...
```

MyClass will be created on application startup and managed as a singleton by Alchemic. 

### Register a singleton created by a method

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

### Register a factory with a name

```objectivec
@implementation MyClass
AcRegister(AcIsFactory, AcWithName(@"Thing factory"))
...
```

Every time a MyClass instance is requested, a new one will be created and returned.

### Register a factory class using a custom initializer which finds all objects with a protocol

```objectivec
@implementation MyClass
AcInitializer(initWithObjects:, AcArg(NSArray, AcProtocol(MyProtocol)))
-(instancetype) initWithObects:(NSArray<id<MyProtocol>> *objects {
    self = ...
    return self;
}
...
```

 
### Inject an object

```objectivec
@implementation MyClass {
    MyOtherClass *_otherThing;
}
 AcInject(_otherThing)
...
```

### Inject a generaliased reference with a specific type

```objectivec
@implementation MyClass {
    id<MyProtocol> _otherThing;
}
 AcInject(_otherThing, AcClass(MyOtherClass))
...
```

### Inject an array of all objects with a protocol

```objectivec
@implementation MyClass {
    NSArray<id<MyProtocol>> *_things;
}
 AcInject(_things, AcProtocol(MyProtocol))
...
```
 
### Register a override object in a unit test

```objectivec 
@implementation MySystemTests
AcMethod(MyClass, createOverride, AcIsPrimary)
-(MyClass *) createOverride {
   // Create the override
   return override;
}
```
 
### Self injecting in non-managed classes

```objectivec
-(instancetype) initWithFrame:(CGRect) aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        AcInjectDependencies(self);
    }
    return self;
}
```

### Getting a object in code

```objectivec
-(void) someMethod {
    MyClass *myClass = AcGet(MyClass, AcName(@"My instance"));
}
```

### Using a factory initializer with custom arguments

```objectivec
AcInitializer(initWithText:, AcIsFactory, AcArg(NSString, AcValue(@"Default message")
-(instancetype) initWithText:(NSString *) message {
    // ...
}
```

```objectivec
-(void) someMethod {
    MyObj *myObj = AcInvoke(AcName(@"MyObj initWithText:"), @"Overriding message text");
}
```

### Register an aysnchronous startup block

```objectivec
-(void) viewDidLoad {
    AcExecuteWhenStarted(^{
        [self reloadData];
    });
}
```