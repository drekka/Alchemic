---
title: Runtime
---

 * [Managing the UIApplicationDelegate instance](#managing-the-uiapplicationdelegate-instance)
 * [UIViewControllers and Story Boards](#uiviewcontrollers-and-story-boards)

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

