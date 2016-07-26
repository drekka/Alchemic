---
title: Alchemic
---

Alchemic is a [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) framework for iOS. It's goal is to help you manage object creation, object properties and variables. And it should be as simple and easy to do this as possible.

___Main features___

* Engineered in Objective-C, usable in Objective-C and Swift projects.
* Definitions and injections are dynamically read from the runtime.
* Automatically started on a background thread.
* Objects can be instantiated using initializers or factory methods if desired.
* Objects can be managed as singletons, factories (templates) or externally sourced.
* Arguments to methods and initializers can be other objects or constants.
* Objects can be located using class, protocol or unique name searches.
* Works with implementation variables and methods, minimising public declarations.
* Automatic array boxing for injection.
* Automatic handling of UIApplicationDelegate instances.

# Swift support

Alchemic supports classes written in Swift with some caveats. Objective-C is unable to understand some Swift constructs such as structs and protocol extensions. 

 * Swift classes and methods that are to be used by Alchemic must be annotated with the `@objc` qualifier so Alchemic can see them. 
 * When injecting values into properties, the type of the property must be an Objective-C type. 
 * Arguments passed to Alchemic must be resolvable to Objective-C types as per the Swift documentation. 

