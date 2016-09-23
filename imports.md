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
Alchemic makes use of Objective-C pre-processor macros so it can be added to your code as if it was meta-data, similar to Java's annotations. These meta-data macros are generally quite simple and easy to remember. For example:

```objc
@implementation MyClass
AcRegister
@end
```

{{layout.objc}}
*But before we continue, a political statement from our sponsors ...*

{{layout.objc}}
*__Why are we using macros ? Macros are 'Evil' !__*

{{layout.objc}}
I've come across this sentiment in the past and I disagree with it. Macros are just another tool we can choose to use, and they can be helpful or abused like anything else. In Alchemic's case, it uses preprocessor macros to dramatically reduce the amount of code you have to type. 

{{layout.objc}}
For example Here's what the above registration would look like without using the `AcRegister` macro:

```objc
@implementation MyClass
+(void) _alc_model_configureClassObjectFactory_12:(ALCClassObjectFactory *) classObjectFactory {
    [[Alchemic mainContext] objectFactoryConfig:classObjectFactory, nil];
}
@end
```

{{layout.objc}}
As you can see, there is quite a bit of code being hidden by a very small macro. Most of Alchemic's macros hide similar or even more code.  

{{layout.objc}}
*__But I still don't like macros' !__*

{{layout.objc}}
Ok, it's also possible to avoid using them if you really want to. Flip over to the documentation for the Swift version of Alchemic. You can use Alchemic registration method to do the same job. Just convert the Swift code to Objective-C and you'll be macro free.

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

{{layout.swift}}
*Note the usage of the '_' as the external parameter name in the method signature. This is important as it ensures that Alchemic's Objective-C runtime scanning code can see the method as having the `alchemic:` signature. Otherwise it would see it as `alchemicOf:` and not execute it.* 

