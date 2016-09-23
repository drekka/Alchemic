---
title: Runtime
---

 * [Interfacing with Alchemic](#interfacing-with-alchemic)
    * [Manual dependency injections](#manual-dependency-injections)
    * [Getting objects](#getting-objects)
    * [Setting objects](#setting-objects)
    * [Invoking methods](#invoking-methods)
 * [Callbacks and notifications](#callbacks-and-notifications)

# Interfacing with Alchemic

Now that we know how to declare objects and inject them, lets look at how we retrieve objects in classes and code which is not managed by Alchemic. In other words, how to get Alchemic to work with the rest of your app.

## Manual dependency injections

Alchemic will automatically inject dependencies into any object it instantiates or manages. There may be situations where you need to create objects independently and would still like Alchemic to handle the injection of dependencies. This is where __AcInjectDependencies__ can be used.

```objc
-(instancetype) initWithFrame:(CGRect) aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        AcInjectDependencies(self);
    }
    return self;
}
```

```swift
func init(frame:CGRect) {
    AcInjectDependencies(self)
}
```

You can call __AcInjectDependencies__ anywhere in your code and pass it the object whose dependencies you want injected. Alchemic will search for a matching Class factory and use that to inject any dependencies specified in the model.

## Getting objects

Sometimes (in unit tests for example) you want to get an object from Alchemic without setting up an injection. __AcGet__ allows you to search for and return an object (or objects). 

```objc
-(void) myMethod {
    NSDateFormatter *formatter = AcGet(NSDateFormatter, AcName(@"JSON date formatter"));
    // Do stuff ....
}
```

```swift
func myMethod() {
    var formatter:NSDateFormatter = AcGet(AcName(@"JSON date formatter"))
    // Do stuff ....
}
```

{{layout.objc}}
In Objective-C __AcGet__ requires the first argument to be the type that will be returned. This type is needed because the runtime cannot tell Alchemic what is expected and it needs this information to finish processing the results. Especially if you are expecting an array back. 

Arguments after the type are search criteria used to find candidate object factories. So __AcClass__, __AcProtocol__ or __AcName__ can all be used to search the model for objects. 

*Note: It makes no sense to allow any of Alchemic's constants here so only model search criteria are allowed.*

Note that __AcGet__ also does standard Alchemic `NSArray` processing. For example the following code will return an array of all Alchemic registered date formatters:

```objc
-(void) myMethod {
NSArray *formatters = AcGet(NSArray, AcClass(NSDateFormatter));
// Do stuff ....
}
```

```swift
func myMethod() {
var formatters = AcGet(NSArray.self, source:AcClass(NSDateFormatter))
// Do stuff ....
}
```

Finally, you can leave out the search criteria macros like this:

```objc
-(void) myMethod {
    NSDateFormatter *formatter = AcGet(NSDateFormatter);
    // Do stuff ....
}
```

```swift
func myMethod() {
    var formatter = AcGet(NSDateFormatter.self)
    // Do stuff ....
}
```

Without any criteria, Alchemic will use the return type to determine the search criteria for scanning the model based in it's class and any applicable protocols.

## Setting objects

Alchemic also provides a function for setting objects called __AcSet__. Mostly it's used for storing objects in factories which have been setup as reference types using __AcReference__:

```objc
-(void) myMethod {
    NSDateFormatter *formatter = ...; // Create a formatter
    AcSet(NSDateFormatter, AcName(@"myDateFormatter"));
}
```

```swift
func myMethod() {
    var formatter = ...; // Create a formatter 
    AcSet(NSDateFormatter.self, AcName("myDateFormatter"))
}
```

__AcSet__ locates a matching object factory from the criteria passed as arguments after the object to set into the model. __ACName__ is most useful when setting values as __AcSet__ expects there to be only one object factory found from the criteria. If zero or more than one object factory is found, __AcSet__ will throw an error.

*Note: that setting a new object for an object factory does not effect any previously injected references to the old object. Only injections done after setting the new object will receive it.*

## Invoking methods

__AcInvoke__ is for when you want to call a declared method or initializer manually. It's mostly useful when you want to call it, but still let Alchemic handled the method arguments. For example, you might declare a factory initializer like this:

```objc
AcInitializer(initWithText:, AcFactory, AcArg(NSString, AcValue(@"Default message")
-(instancetype) initWithText:(NSString *) message {
    // ...
}
```

```swift
{{ site.data.code.swift-alchemic-method }} {
    AcInitializer(of, initializer:"initWithMessage:", 
        args:AcArg(NSString.self, source:AcValue(@"Default message"))
    )
}
func init(message:NSString) {
    // ...
}
```

In this scenario you want the factory method to give you a new instance of the object when you need it, but with a different message. So you can call it like this:

```objc
-(void) myMethod {
    MyObj *myObj = AcInvoke(AcName(@"MyObj initWithText:"), @"Message text");
    // Do stuff ....
}
```

```swift
func myMethod() {
    var myObj = AcInvoke(AcName("MyObj initWithText:"), args:"Message text")
    // Do stuff ....
}
```

__AcInvoke__ will locate all Alchemic object factories that match the first argument, which must be a search function. Normally it's __AcName__ because the usual scenario is to be address a specific method or initializer. Once Alchemic has located the object factory for the method you want, it then invokes it (in the case of a normal method) or creates an instance using it if it is an initializer. In either case the method being addresses __must__ have been registered via __AcInitializer__ or __AcMethod__ so it can be found in the model and called. 

Also note in the above example, we are using the default name for the method generated by Alchemic. Using __AcInvoke__ is one good reason to make use of [__AcFactoryName__](#custom_names) to add custom names to registrations.

# Callbacks and notifications

## AlchemicAware protocol

The protocol `AlchemicAware` contains several callback methods you can implement in your classes. These methods are executed at specific times to allow your code to respond if you need it. To use them, just create the protocol's method in your class. Actually specifying the  `AlchemicAware` protocol is optional. Alchemic will automatically look for these methods regardless.

```objc
-(void) alchemicDidInjectVariable:(NSString *) variable { 
    // ... 
}
```

```swift
@objc func alchemicDidInjectVariable(variable:NSString) { 
    // ... 
}
```

Called after Alchemic has injected a variable. The variable name is passed as an argument. This is similar to the way KVO calls after a property has been set.

```objc
-(void) alchemicDidInjectDependencies {
    // ...
}
```

```swift
func alchemicDidInjectDependencies() {
    // ...
}
```

Called after all injections for an object have been done. This is the ideal place to perform further configuration. 

## Alchemic notifications

The following is a list of notifications that Alchemic sends out.

Notification | Description
--- | ---
__AlchemicDidCreateObject__ | Sent after Alchemic has finished instantiating an object.
__AlchemicDidFinishStarting__ | Sent after Alchemic has finished it's startup. At this point the model will have been populated and resolved, and all singletons will have been instantiated. This notification is a good way to know when you can run code that needs to execute as soon as Alchemic is ready to serve objects.
__AlchemicDidStoreObject__ | Sent after an object has been stored in the model. This is mainly used internally so that Alchemic can trigger fresh injections based on the new value.

