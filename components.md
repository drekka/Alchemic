---
title: Components
--- 

# How Alchemic works

The following are the main architectural items that you will come across when working with Alchemic.

## The context

Every interaction with Alchemic takes place through the Alchemic context. Implementing the `ALCContext` protocol, the context is essentially a self starting singleton instance that contains all the methods needed to tell Alchemic about your app. The context is also responsible for starting Alchemic, resolving dependencies, peforming injections, etc.

## The data model

Behind the context, Alchemic maintains an in memory data model. In it Alchemic stores all the information about your app's classes. When starting up, it scans the classes in your project and executes any setup methods it finds. This is the _registration_ phase of Alchemic's startup process.

## Object factories

The Alchemic data model contains a collection of [__Object factories__]({{ site.data.pages.objectFactories }}). These describe what sort of object you want them to manage and the dependencies they have. Object factories can manage singleton instances, factories (AKA _Templates_) and references to externally created objects such as `UIViewControllers`. 

Object factories are mostly created automatically during registration.

## Alchemic's boot sequence

Alchemic will automatically start itself when your application loads. It follows this logic:

1. Starts itself on a background thread so that your application's startup is not impacted.
2. _Registration phase:_ Scans all classes in your app for dependency injection declarations and executes them to setup the model.
3. _Resolving phase:_ Resolves all references and configures the internal model based on the found declarations.
3. _Singletons phase:_ Instantiates any classes declared as Singletons and wires up their dependencies.  
4. Post the ["AlchemicFinishedLoading"](#finished-loading) notification.

