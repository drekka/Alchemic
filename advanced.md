---
title: Advanced usage
---

# Advanced usage

## Config classes

It's possible you may need to configure Alchemic outside of the class you want it to manage. You might not not have access to the source code or simply don't want to make it depend on Alchemic. For example, you might want to manage a service class from a framework that is not aware of Alchemic. 

To get around this sort of problem, you can create a class and implement the `AlchemicConfig` protocol. On start-up, Alchemic will find these methods and execute them to handle the extra setup instructions. 

```objc
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
class MyAppConfig:NSObject<AlchemicConfig>
    @objc static func configureAlchemic(context:ALCContext) {
        let of = context.registerObjectFactoryForClass(MyService.class);
        of.objectFactoryConfig:of, AcFactoryName("myService"), nil);
        of.objectFactory(of registerVariableInjection:"aVar", nil);
    }
}
```

In this example we are telling Alchemic to create and manage a singleton instance of `MyService` which comes from an API framework that is not Alchemic aware.

## Stopping Alchemic from auto-starting

If for some reason you do not want Alchemic to auto-start (unit testing perhaps), then you can do this by modifying XCode's scheme for the launch like this:

![Stop Alchemic from loading](./images/screen-shot-stop-alchemic.png)

___--alchemic-nostart___ - disables Alchemic's autostart function.


## Manually starting

Alchemic can programmatically started using:

```objc
[Alchemic start];
```

```swift
Alchemic.start()
```

But generally speaking, just letting Alchemic autostart is the best way.

