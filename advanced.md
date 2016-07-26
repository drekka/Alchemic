---
title: Advanced usage
---

# Additional configuration

Alchemic needs no configuration out of the box. However sometimes there are things you might want to change before it starts. To do this, you need to create one or more classes and implement the `AlchemicConfig` protocol on them. Alchemic will automatically locate these classes during startup and read them for additional configuration.

## Programmatically registering factories

It's possible you need to configure Alchemic in a way that cannot be handled using the built-in macros. For example, a singleton service class from a framework that is not aware of Alchemic. You might not not have access to the source code, or simply don't want to make it depend on Alchemic.

To get around this sort of problem, you can create a class and add the `AlchemicConfig configureAlchemic:(id<ALCContext>) context` like this:

```objc
// Objective-C
@interface MyAppConfig : NSObject<AlchemicConfig>
@end

@implementation MyAppConfig
+(void) configureAlchemic:(id<ALCContext>) context {
    ALCClassObjectFactory of = [Context registerObjectFactoryForClass:[MyService class]];
    [context objectFactoryConfig:of, AcFactoryName(@"myService"), nil];
    [Context objectFactory:of registerVariableInjection:@"aVar", nil];
}
@end
```

```swift
// Swift
class MyAppConfig:NSObject<AlchemicConfig>
    @objc static func configureAlchemic(context:ALCContext) {
        let of = context.registerObjectFactoryForClass(MyService.class);
        of.objectFactoryConfig:of, AcFactoryName("myService"), nil);
        of.objectFactory(of registerVariableInjection:"aVar", nil);
    }
}
```

Here we are telling Alchemic to create and manage a singleton instance of `MyService` which comes from an API framework that is not Alchemic aware.


## Stopping Alchemic from auto-starting

If for some reason you do not want Alchemic to auto-start (unit testing perhaps), then you can do this by modifying XCode's scheme for the launch like this:

![Stop Alchemic from loading](./images/screen-shot-stop-alchemic.png)

___--alchemic-nostart___ - disables Alchemic's autostart function.


## Manually starting

Alchemic can programmatically started using:

```objc
// Objective-C
[Alchemic start];
```

```swift
// Swift
Alchemic.start()
```

But generally speaking, just letting Alchemic autostart is the best way.

