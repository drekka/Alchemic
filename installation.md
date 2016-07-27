---
title: Installation
--- 

# [Carthage](https://github.com/Carthage/Carthage)

If your not using [Carthage](https://github.com/Carthage/Carthage), I would like to suggest that you take a few minutes to have a look. IMHO it's the best dependency manager available in the iOS world. I use it in all of my projects.

Add this to your __Cartfile__:

```bash
github "drekka/alchemic" > 2.0
```

Then run either the __bootstrap__ or __update__ carthage commands to download Alchemic and it's dependencies into the  __<project-dir>/Carthage/Checkouts/__ directory and then build them as iOS frameworks into the __<project-dir>/Carthage/Build/iOS/__ directory. 

Once built, You can add following frameworks into your project the same way you would add any other external framework.

Framework | Description
--- | ---
Alchemic.framework | This is the Objective-C core of Alchemic. It's required for both Swift and Objective-C projects.
AlchemicSwift.framework | *ONLY* required for Swift projects. It provides Swift wrappers for parts of Alchemic that are difficult to access otherwise. 
Storyteller.framework | [Story Teller](https://github.com/drekka/StoryTeller) is a alternative logging framework I designed along side Alchemic. It's main claim to find is that it enables more expressive logging rules than your traditional frameworks.
PEGKit.framework | Used by StoryTeller to parse logging expressions.

*Note: You will need to ensure that all of these frameworks are added to your project and copied to the __Frameworks__ directory in your app using the* `carthage copy-frameworks` *command. Please see the carthage documentation on [copying frameworks](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos) for details.*


