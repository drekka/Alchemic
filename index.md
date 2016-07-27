---
title: Alchemic
---

Alchemic is a [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) framework for iOS. 

It's job is to help simplify your applications code by creating and managing your applications objects, and the dependencies they need. Alchemic's goal is to do this as simply as possible. 

___Main features___

* Definitions and injections dynamically read from your app's classes.
* Automatically starts on a background thread.
* Can instantiate objects using initializers or factory methods.
* Objects can be managed as singletons, templates or external references.
* Factory Methods and initializers can source argument values from objects or constants.
* Values for injections can be located using class, protocol or unique name searches.
* Works inside your implementations, keeping your public interfaces minimal.
* Automatic array boxing of values.
* Automatic management of UIApplicationDelegate instances.
* Engineered in Objective-C, usable in Objective-C and Swift projects.

# Swift support

Alchemic supports classes written in Swift with some caveats. Objective-C is unable to understand some Swift constructs such as structs and protocol extensions. 

 * Swift classes and methods that are to be used by Alchemic must be annotated with the `@objc` qualifier so Alchemic can see them. 
 * When injecting values into properties, the type of the property must be an Objective-C type. 
 * Arguments passed to Alchemic must be resolvable to Objective-C types as per the Swift documentation. 

# Credits

* Thanks to Adam and Vitaly at [Odecee](http://odecee.com.au) who helped me with getting my head around some of the Swift code.
* Big Thanks to the guys behind [Carthage](https://github.com/Carthage/Carthage) for writing a dependency tool that actual works well with XCode and Git.
* Thanks to the guys behind the [Spring Framework](https://spring.io). The work you have done has made my life so much easier on so many Java projects and inspired a lot of what I've done with Alchemic.
* Thanks to Mulle Cybernetik for [OCMock](ocmock.org) for an outstanding mocking framework unit testing that regularly enabled me to test the un-testable.
* Thanks to Todd Ditchendorf for the [PEGKit](https://github.com/itod/pegkit) text parsing API. I've learned a lot from working with it on [Story Teller](https://github.com/drekka/StoryTeller).
* Finally thanks to everyone who writes the crappy software that inspires me to give things like this ago. You know who you are.


