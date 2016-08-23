---
title: Runtime
---

 * [Managing the UIApplicationDelegate instance](#managing-the-uiapplicationdelegate-instance)
 * [UIViewControllers and Story Boards](#uiviewcontrollers-and-story-boards)
 * [NSUserDefaults](#nsuserdefaults)

# Managing the UIApplicationDelegate instance

Alchemic has some special processing for `UIApplicationDelegates`. After starting, Alchemic will automatically search for a `UIApplicationDelegate` and if it finds one, inject any dependencies it needs. So there is no need to add any __AcRegister__ calls to the app delegate class. By default, Alchemic will automatically add the application to its model and set it with your app's instance.

*Note: You can still use __AcRegister__ to give the application delegate a name if you like.*

# UIViewControllers and Story Boards ##

Whilst I looked at several options for automatically injecting storyboard created instances of UIViewControllers, I did not find any technique that would work reliably and required less than a single line of code. So for the moment Alchemic does not inject dependencies into view controllers automatically. Instead, the simplest solution is to self inject in `awakeFromNib` or `viewDidLoad`.

{{ site.lang-title-objc }}
```objc
-(void) viewDidLoad {
    AcInjectDependencies(self);
}
```

{{ site.lang-title-swift }}
```swift
func viewDidLoad() {
    AcInjectDependencies(self)
}
```

# NSUserDefaults

Alchemic provides a set of tools for automatically managing data which you want stored in the user defaults area. Alchemics user defaults management feature is activated by adding the `AcEnabledUserDefaults` macro. This can be on any class in your app. Alchemic will automatically find it. For example:

```objc
@implementation MyClass
AcEnabledUserDefaults
@end
```

Once enabled, Alchemic will automatically add user defaults support to the model by adding a singleton factory to the model which instantiates an instance of `ALCUserDefaults` on startup. `ALCUserDefaults` provides the following features:

 * Automatically locates the `Root.plist` file in the main bundle if it exists and loads it's contents into the user defaults.
 * Allows user defaults to be read or written by either KVC or subscipted code. 
 * Supports developers writing classes that extend `ALCUserDefaults` and implement properties for the user default settings.

Here's a more complete example of accessing the user defaults: 

{{ site.lang-title-objc }}
```objc
@implementation MyClass {
    ALCUserDefaults *_defaults;
}

AcEnabledUserDefaults
AcInject(_defaults)

-(void) someMethod {
    NSString *name = _defaults["username"];
    _defaults["username"] = "derek";
}

@end
```

Setting a value automatically saves it to user defaults.

## Custom user defaults

By extending `ALCUserDefaults` to create your own class you can add properties to match the user defaults. You then declare the class as a singleton in Alchemic's model. With user defaults enabled, Alchemic will see your custom user defaults in the model and not add it's own.

When instantiated, the code inside the parent `ALCUserDefaults` will first load all user defaults into the properties, then locate all the writeable properties and KVO watch them. When you set a new value, the KVO watch will automatically forward it to the user defaults system. 

The up shot of this is that a fully Alchemic integrated user defaults with code completable properties, defaults sourced from a `Roots.plist` file, and backed by `[NSUserDefaults standardUserDefaults]` is a simple as this:

{{ site.lang-title-objc }}
```objc
@interface MyUserDefaults: ALCUserDefaults
@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) int nbrLogins;
@end
```

{{ site.lang-title-objc }}
```objc
@implementation MyUserDefaults
AcEnableUserDefaults
@end
```

{{ site.lang-title-objc }}
```objc
@implementation MyClass {
    MyUserDefaults *_defaults;
}

AcInject(_defaults)

-(void) someMethod {
    NSString *name = _defaults.username;
    _defaults.username = "derek";
}

@end
```


