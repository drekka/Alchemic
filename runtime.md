---
title: Runtime
---

# Interfacing with Alchemic

Now that we know how to declare objects and inject them, lets look at how we retrieve objects in classes and code which is not managed by Alchemic. In other words, how to get Alchemic to work with the rest of your app.

## Manual dependency injections

Alchemic will automatically inject dependencies into any object it instantiates or manages. There may be situations where you need to create objects independantly and would still like Alchemic to handle the injection of dependencies. This is where __AcInjectDependencies__ can be used.

```objc
// Objective-C
-(instancetype) initWithFrame:(CGRect) aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        AcInjectDependencies(self);
    }
    return self;
}
```

```swift
// Swift
func init(frame:CGRect) {
    AcInjectDependencies(self)
}
```

You can call __AcInjectDependencies__ anywhere in your code and pass it the object whose dependencies you want injected. Alchemic will search for a matching Class factory and use that to inject any dependencies specified in the model.

## Getting objects

Sometimes (in unit tests for example) you want to get an object from Alchemic without specifying an injection. __AcGet__ allows you to search for and return an object (or objects) inline with your code rather than as an injection. 

```objc
// Objective-C
-(void) myMethod {
    NSDateFormatter *formatter = AcGet(NSDateFormatter, AcName(@"JSON date formatter"));
    // Do stuff ....
}
```

```swift
// Swift
func myMethod() {
    var formatter:NSDateFormatter = AcGet(AcName(@"JSON date formatter"))
    // Do stuff ....
}
```

In Objective-C __AcGet__ requires the first argument to be the type that will be returned. This type is needed because the runtime cannot tell Alchemic what is expected and it needs this information to finish processing the results. Especially if you are expecting an array back. In Swift, the runtime can deduce the type through Swift generics. 

Arguments after the type are search criteria used to find candidate builders. So __AcClass__, __AcProtocol__ or __AcName__ can all be used to search the context for objects. Of course it makes no sense to allow any of Alchemic's constants here so only model search criteria are allowed.

Note that __AcGet__ also does standard Alchemic `NSArray` processing. For example the following code will return an array of all Alchemic registered date formatters:

```objc
// Objective-C
-(void) myMethod {
NSArray *formatters = AcGet(NSArray, AcClass(NSDateFormatter));
// Do stuff ....
}
```

```swift
// Swift
func myMethod() {
var formatters = AcGet(NSArray.self, source:AcClass(NSDateFormatter))
// Do stuff ....
}
```

Finally, you can leave out the search criteria macros like this:

```objc
// Objective-C
-(void) myMethod {
NSDateFormatter *formatter = AcGet(NSDateFormatter);
// Do stuff ....
}
```

```swift
// Swift
func myMethod() {
var formatter = AcGet(NSDateFormatter.self)
// Do stuff ....
}
```

Without any criteria, Alchemic will use the passed return type to determine the search criteria for scanning the model based in it's class and any applicable protocols.

## Setting objects

Alchemic will locate the matching object factory for the criteria passed as arguments after the object. It will then set the object as it's value. __ACName__ is most useful when setting values as __AcSet__ expects there to be only one object factory to set. If zero or more than one object factory is found, __AcSet__ will throw an error.

*Note: that setting a new object for an object factory does not effect any previously injected references to the old object. Only injections done after setting the new object will receive it.*


## Invoking methods

__AcInvoke__ is for when you want to access a declared method or initializer and pass in the arguments manually. But you don't have access to the object it's declared on or may not even know it.  For example, you might declare a factory initializer like this:

```objc
// Objective-C
AcInitializer(initWithText:, AcFactory, AcArg(NSString, AcValue(@"Default message")
-(instancetype) initWithText:(NSString *) message {
// ...
}
```

```swift
// Swift
public static func alchemic(cb:ALCBuilder) {
AcInitializer(cb, initializer:"initWithMessage:", 
args:AcArg(NSString.self, source:AcValue(@"Default message"))
)
}
func init(message:NSString) {
// ...
}
```

In this scenario you want the factory method to give you a new instance of the object when you need it, but with a different message. So you can it like this:

```objc
// Objective-C
-(void) myMethod {
MyObj *myObj = AcInvoke(AcName(@"MyObj initWithText:"), @"Message text");
// Do stuff ....
}
```

```swift
// Swift
func myMethod() {
var myObj = AcInvoke(AcName("MyObj initWithText:"), args:"Message text")
// Do stuff ....
}
```

__AcInvoke__ will locate all Alchemic declarations that match the first argument, which must be a search function. Normally it's __AcName__ because the usual scenario is to be address a specific method or initializer. Once Alchemic has located the method, it then invokes it (in the case of a normal method) or creates an instance using it if it is an initializer. In either case the method being addresses __must__ have been registered via __AcInitializer__ or __AcMethod__ so it can be found. 

Also note in the above example, we are using the default name for the method generated by Alchemic. Using __AcInvoke__ is one good reason to make use of [__AcFactoryName__](#custom_names) to add custom names to registrations.

## Managing the UIApplicationDelegate instance

Alchemic has some special processing for `UIApplicationDelegates`. After starting, Alchemic will automatically search for a `UIApplicationDelegate` and if it finds one, inject any dependencies it needs. So there is no need to add any __AcRegister__ calls to the app delegate class. By default, Alchemic will automatically add the application to its model and set it with your app's instance.

*Note: You can still use __AcRegister__ to give the application delegate a name if you like.*


## UIViewControllers and Story Boards ##

Whilst I looked at several options for automatically injecting storyboard created instances of UIViewControllers, I did not find any technique that would work reliably and required less than a single line of code. So for the moment Alchemic does not inject dependencies into view controllers automatically. Instead, the simplest solution is to self inject in `awakeFromNib` or `viewDidLoad`.

```objc
// Objective-C
-(void) viewDidLoad {
    AcInjectDependencies(self);
}
```

```swift
// Swift
func viewDidLoad() {
    AcInjectDependencies(self)
}
```


# Callbacks and notifications

## Dependencies injected

Sometimes it's useful to know when Alchemic has finished injecting values into an object. To facilitate this, add the `AlchemicAware` protocol and implement the `alchemicDidInjectDependencies` method. Alchemic will automatically call this method after it has finished injecting values.

```objc
// Objective-C
@interface MyClass:NSObject<AlchemicAware>
@end 

@implementation MyClass 
-(void) alchemicDidInjectDependencies {
    // Do stuff
}
@end
```

```swift
// Swift
class MyClass:NSObject<AlchemicAware> {
    func alchemicDidInjectDependencies() {
        // Do stuff
    }
}
```


## Alchemic finished starting

Once all singletons have been loaded and injected, Alchemic sends out a notification through the default `NSNotificationCenter`. There is a constant called `AlchemicFinishedLoading` in the `ALCAlchemic` class which can be used like this:

```objc
// Objective-C
[[NSNotificationCenter defaultCenter] 
    addObserverForName:AlchemicFinishedLoading
                object:nil
                 queue:[NSOperationQueue mainQueue]
            usingBlock:^(NSNotification *notification) {
    // .. do stuff
}];
```

```swift
// Swift
-- need example here --
```

This is most useful for classes which are not managed by Alchemic but still need to know when Alchemic has finished loading.

