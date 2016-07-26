---
title: Components
--- 

# How Alchemic works

## The context

Every interaction with Alchemic takes place through the Alchemic context. Implementing `ALCContext`, the context is essentially a singleton instance that contains all the methods needed to tell Alchemic about the classes and methods you want it to manage. The context is also responsible for resolving dependencies and starting Alchemic.

## The data model

Behind the context, Alchemic maintains an in memory data model in which it stores all the information about  the objects you want to manage. When starting up, it scans the classes in your project, executing any registration methods it finds. 

This data model mostly contains [__Object factories__](./object-factories.html). Object factories describe to Alchemic what sort of object you want it to manage and the dependencies they have. Object factories are almost always added to the model automatically when Alchemic scans you classes and finds particular methods which tell it what you want it to do. This is referred to as _registering_.

## Alchemic's boot sequence

Alchemic will automatically start itself when your application loads. It follows this logic:

1. Starts itself on a background thread so that your application's startup is not impacted.
2. Scans all classes in your app for dependency injection declarations and executes them to setup the model.
3. Resolves all references and configures the internal model based on the found declarations.
3. Instantiates any classes declared as Singletons and wires up their dependencies.  
4. Check for a UIApplicationDelegate and if found, injection any dependencies it has declared.
5. Post the ["AlchemicFinishedLoading"](#finished-loading) notification.

