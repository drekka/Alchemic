---
title: Imports
---

# Adding Alchemic to your code

Adding Alchemic to your code is quite simple. There are no external configuration files or additional classes required. You start by importing the Alchemic framework like this:

```objc
@import Alchemic;

@implementation MyClass
// ...
@end
```

```swift
import AlchemicSwift

class MyClass {
   // ...
}
```

{{layout.objc}}
*__Why do I add Alchemic to my implementations ?__ By being added to your implementation code, Alchemic can access private initializers, methods and variables. It also keeps your header files simple clean.*

{{layout.objc}}
## Objective-C macros

{{layout.objc}}
Alchemic makes use of Objective-C pre-processor macros so it can work like a form of meta-data, similar to Java's annotations. These macros are generally quite simple and easy to remember. For example:

```objc
@implementation MyClass
AcRegister
@end
```

{{layout.objc}}
Yes ... *it's that simple to use!*

{{layout.objc}}
*__Why are we using macros ? Macros are 'Evil' !__*

{{layout.objc}}
I've read comments like this online and I disagree with the idea. Macros are just another tool, they can be helpful or abused like anything else. Alchemic takes advantage of macros to dramatically reduce the amount of code you have to add. Here's what the above registration would look like without macros:

```objc
@implementation MyClass
+(void) _alc_model_configureClassObjectFactory_12:(ALCClassObjectFactory *) classObjectFactory {
    [[Alchemic mainContext] objectFactoryConfig:classObjectFactory, nil];
}
@end
```

{{layout.objc}}
As you can see, there is quite a bit of code being hidden by a very small macro. Most of Alchemic's macros manage similar or even more code.  

{{layout.objc}}
*Note: It's also possible to avoid using macros if you really don't like them. Take a look at how the Swift API works for examples and simply do the same thing in Objective-C.

{{layout.swift}}
## Swift registration method

{{layout.swift}}
To use Alchemic in Swift, you need to add a specific method to your class like this:

```swift
{{ site.data.code.swift-class }} {
    {{ site.data.code.swift-alchemic-method }} {
        // Alchemic setup goes here.
    }
}
```

{{layout.swift}}
Inside this method you use a variety of Swift functions to setup Alchemic. 

*Note the usage of the '_' as the external parameter name in the method signature. This is important as it ensures that Alchemic's Objective-C runtime scanning code can see the method as `alchemic:`. Otherwise it would see it as `alchemicOf:` and not recognise it.* 

