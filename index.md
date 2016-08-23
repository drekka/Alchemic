---
title: Alchemic {{ site.alchemic-version }}
---

Alchemic {{ site.alchemic-version }} is a [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) framework for iOS. 

*Note: the documentation on this site is based on the coming v2.1 of Alchemic currently under construction in the develop branch.*

Alchemic helps simplify your application's code by creating and managing your applications objects, and the dependencies they need. Alchemic's goal is to do this as simply as possible. 

## Features

* [Configuration]({{ site.data.pages.object-factories }}) and injection declarations dynamically read from your app's classes.
* Automatically starts on a background thread.
* Instantiate objects using [initializers]({{ site.data.pages.object-factories }}#using-initializers) or [factory methods]({{ site.data.pages.object-factories }}#method-object-factories).
* Objects can be managed as singletons, [templates]({{ site.data.pages.object-factories }}#template-mode) or [external references]({{ site.data.pages.object-factories }}#reference-mode).
* [factory methods]({{ site.data.pages.object-factories }}#method-object-factories) and [initializers]({{ site.data.pages.object-factories }}#using-initializers) can source argument values from [objects]({{ site.data.pages.injection-values }}#model-objects) or [constants]({{ site.data.pages.injection-values }}#constants).
* Values for injections can be located using [class, protocol]({{ site.data.pages.injection-values }}#by-classprotocol) or [unique name]({{ site.data.pages.injection-values }}#by-name) searches.
* Works inside your implementations, keeping your public interfaces minimal.
* Automatic [array boxing]({{ site.data.pages.injection-values }}#array-injections) of values.
* Automatic management of [UIApplicationDelegate]({{ site.data.pages.runtime }}#managing-the-uiapplicationdelegate-instance) instances.
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


