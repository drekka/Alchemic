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

# Credits

* Thanks to Adam and Vitaly at [Odecee](http://odecee.com.au) who helped me with getting my head around some of the Swift code.
* Big Thanks to the guys behind [Carthage](https://github.com/Carthage/Carthage) for writing a dependency tool that actual works well with XCode and Git.
* Thanks to the guys behind the [Spring Framework](https://spring.io). The work you have done has made my life so much easier on so many Java projects.
* Thanks to Mulle Cybernetik for [OCMock](ocmock.org). An outstanding mocking framework for Objective-C that has enabled me to test the un-testable many times.
* Thanks to Todd Ditchendorf for [PEGKit](https://github.com/itod/pegkit). I've learned a lot from working with it on [Story Teller](https://github.com/drekka/StoryTeller).
* Finally thanks to everyone who writes the crappy software that inspires me to give things like this ago. You know who you are.


