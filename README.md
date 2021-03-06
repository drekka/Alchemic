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

# v2.2.9, v2.2.10, v2.2.11, v2.2.12

* Fixed bugs in bundle scanning which caused test bundles to not be scanned. 
* Fixed a bug where aspects where being loaded on incorrect flags.
* Condensed the 'LogModel' output in the logs. Output now looks like
    [*SRTNW~CM] <class> or <method> as 'Name'
  Where the flags `*SRTNW~CM` stand for instantiated, singleton, reference, template, nillable, weak, transient, class and method.
* Fixing bug where the UIApplicationDelegate aspect would fail if there was no application delegate.

# v2.2.8

* Fixing bug where using in a framework with no app delegate was throwing an error.

# v2.2.7

* Fixing version numbers which were missing from the framework.

# v2.2.5

* Bug fix: Ensuring injection callback methods in the AlchemicAware protocol are always called on the main thread.

# v2.2.4

* Refactoring to improve some exception messages.

# v2.2.3

* Swift version of AcWhenReady now public.

# v2.2.2

* Removing  requirement for Address Sanitizer from the built library.

# v2.2.1

* Fixed bug where tranient watches were triggering the re-injection non-transient injections. 
* Changed LogInitialModel to just logModel to dump the model into the logs on startup.

# v2.2.0

* Merged Swift support back into main Alchemic framework.
* Fixed bug where it was possible to inject a nil from a nillable factory into a non-nullable variable or method argument.
* Added support for value transformations when sending values to and from value stores.
* Split value store loading into defaults and current values for better management of incoming data.
* Added an abstract aspect parent class.
* Fixed bug where app delegates with no injections were not being added to the model.
* Cleaned up value handling code.
* Fixed bug where frameworks were not being scanned correctly on devices which resulted in Alchemic registrations being missed.
* Fixed bug where having API projects in the current Xcode workspace was causing class scanning failures.  
* Fixed bug where startup code that looked for a UIApplicationDelegate was executing before the app had been started. Therefore a nil was being returned.

# v2.1.1

* Updated context description to print the current model. Useful for debugging.
* Fixed bug where post startup blocks could trigger a lifecycle failure if they called inject dependencies.
* Refactored startup code with better threading.
* AcTransient has been moved from injection declarations to factory declarations where it makes far more sense.



