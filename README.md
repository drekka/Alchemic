# [Alchemic](http://drekka.github.io/Alchemic) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
By Derek Clarkson
 
Alchemic is a [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) framework for iOS. It's goal is to help you manage object creation, object properties and variables. And it should be as simple and easy to do this as possible.

Please take a look at the [main documentation site](http://drekka.github.io/Alchemic) for details on installing and configuring Alchemic.

___Main features___

* Engineered in Objective-C, usable in Objective-C and Swift projects.
* Definitions and injections are dynamically read from the runtime.
* Self starting on a background thread.
* Uses default initializers, custom initializers or factory methods to instantiate objects.
* Supports singletons, factories (templates) or externally created objects.
* Supports methods and initializer arguments from objects or constants.
* Objects can be located using class, protocol or unique name searches.
* Works with implementation variables and methods, minimising public declarations.
* Automatic array boxing for injections.
* Automatic handling of UIApplicationDelegate instances.
* Support for NSUserDefaults and Apple's cloud based key-value stores.
* and much, much more.

# V2.1.2 #

* Fixed bug where it was possible to inject a nil from a nillable factory into a non-nullable variable or method argument.
* Added support for value transformations when sending values to and from value stores.
* Split value store loading into defaults and current values for better management of incoming data.
* Added an abstract aspect parent class.
* Fixed bug where app delegates with no injections were not being added to the model.
* Cleaned up value handling code.
* Fixed bug where frameworks were not being scanned correctly on devices which resulted in Alchemic registrations being missed.

# v2.1.1 #

* Updated context description to print the current model. Useful for debugging.
* Fixed bug where post startup blocks could trigger a lifecycle failure if they called inject dependencies.
* Refactored startup code with better threading.
* AcTransient has been moved from injection declarations to factory declarations where it makes far more sense.



