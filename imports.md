---
title: Imports
---

# Adding Alchemic to your code

Adding Alchemic to your code is quite simple. There are no external configuration files or additional classes required. You simply add an import statement and various single lone macros to your class implementation files (_*.m_).

First you need to import the framework: 

{{ site.lang-title-objc }}
```objc
@import Alchemic;
```

{{ site.lang-title-swift }}
```swift
import AlchemicSwift
```

*__Why is Alchemic in my implementations ?__ - A lot of Alchemic's power comes from how it integrates with your code. By being included in your implementation code, it has the ability to access private initializers, methods and variables. This has the advantage of allowing you to keep your header files clean and simple.*

## Objective-C macros

Alchemic comes with a range of Objective-C pre-processor macros are designed to feel like a form of meta-data, similar to Java's annotations. These macros are generally quite simple and easy to remember. For example:

{{ site.lang-title-objc }}
```objc
@implementation MyClass
AcRegister
@end
```

Yes ... *it's that simple to use!*

*__Why are we using macros ? Macros are 'Evil' !__ I've seen comments like this in a number of circules and I disagree with it. Macros are just another tool. They can be helpful or abused like anything else. Alchemic makes us of them to dramatically reduce the amount of code required to use it. Something that becomes obvious when comparing the Objective-C code to the Swift equivalents (where macros are not available). It's also quite possible to avoid using macros completely when using Alchemic. Just write the Objective-C code in a similar fashion to the Swift code.*** 


## Swift registration method

In Swift, you cannot use macros so Alchemic automatically locates and excutes a specific method in any class you need to configure. Simple add the following method to your class and Alchemic with automatically find it:

{{ site.lang-title-swift }}
```swift
@objc class MyClass {
    @objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
        // Alchemic setup goes here.
    }
}
```

Inside it you can use a variety of Swift functions which are very similar to their Objective-C macro counterparts.

*Note: You can also declare the same method in Objective-C code and use it the same way.*  

