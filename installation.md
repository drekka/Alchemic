---
title: Installation
--- 

# [Carthage](https://github.com/Carthage/Carthage)

If your not using [Carthage](https://github.com/Carthage/Carthage), I would like to suggest that you take a look. IMHO it's a far superior dependency manager to Cocoapods, less intrusive and simpler to work with.

Add this to your __Cartfile__:

github "drekka/alchemic" > 2.0

Then run either the __bootstrap__ or __update__ carthage commands to download Alchemic from and compile it and it's dependencies into the  __<project-dir>/Carthage/Build/iOS/__ directory. You can then include the following frameworks into your project the same way you would add any other framework.

Framework | Description
--- | ---
Alchemic.framework | This is the Objective-C core of Alchemic. It's required for both Swift and Objective-C projects.
AlchemicSwift.framework | *ONLY* required for Swift projects. This framework provides the bridging functions that enable Swift to use Alchemic. 
Storyteller.framework | [Story Teller](https://github.com/drekka/StoryTeller) is a alternative logging framework I designed along side Alchemic.
PEGKit.framework | Used by StoryTeller.

*Note: You will need to ensure that all of these frameworks are added to your project and copied to the __Frameworks__ directory in your app using the* `carthage copy-frameworks` *command.*


