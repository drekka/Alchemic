---
title: Imports
---

# Adding Alchemic to your code

Alchemic is used within your implementation files. Simply declare a module import at the top of your implementation (_*.m_ files). 

{{ site.lang-title-objc }}
```objc
@import Alchemic;
```

{{ site.lang-title-swift }}
```swift
import AlchemicSwift
```

*Why is Alchemic in my implementations ? - A lot of Alchemic's power comes from how it integrates with your code. By being in your implementation, it has the ability to access initializers and methods which are internal to your classes. This has the advantage of allowing you to keep your header files clean and simple.*

## Objective-C macros

The Objective-C pre-processor macros are designed to feel like a form of meta-data, similar to Java's annotations. These macros are generally quite simple and easy to remember. For example:

{{ site.lang-title-objc }}
```objc
@implementation MyClass
AcRegister
@end
```

Yes ... *it's that simple to use!*

***Note: in the rest of this document, all Objective-C code example will use these macros.*** 


## Swift registration method

In Swift you can add the `+(void) alchemic:` method to your class to configure Alchemic:

{{ site.lang-title-swift }}
```swift
@objc class MyClass {
    @objc public static func alchemic(objectFactory: ALCClassObjectFactory) {
        // Alchemic setup goes here.
    }
}
```

Once added you can then use a variety of Swift functions which are very similar or the same as their Objective-C equivalents.

*Note: You can also declare the same method in Objective-C code and use it in the same way.*  

