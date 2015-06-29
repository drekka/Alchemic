# StoryTeller
A logging framework that promotes following data rather than functionality in logs.

### WTF - Another logging framework!!!

Yep. Another one. But with a difference ...

The idea that drives Story Teller is quite simple: ***To debug an application, developers need to see the threads of data as they weave their way through the code.***

Other logging frameworks use a very crass shotgun approach (IMHO) base on assuming that the *severity* of a log statement can be used to derive useful logging output. There is no way to target the logging and usually a huge amount of useless output is produced. The real problem with these frameworks is that they are based on old Java frameworks built for systems where CPU and storage are unlimited, and where people don't care about producing millions of lines of text that no-one will read. Even on servers these frameworks are wasteful and don't work that well for debugging. 

Story Teller takes a different approch - it combines the ability to base logging on dynamic data driven *Keys* with a simply query driven logging criteria to activate the logs. This enabled the developer to target their logging on the specific data. The result is very concise logs which only contain output related to the problem at hand.

# Installation

## Carthage

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

This project can be dynamically included using [Carthage](https://github.com/Carthage/Carthage). This is recommended if you are using iOS8+.

Simple create a  file called ***CartFile*** in the root of your project and add a line of text like this:

```
github "drekka/StoryTeller" >= 0.1
```
fire up a command line and execute from our projects root directory:

```
carthage bootstrap
```

This will download and compile Story Teller into a framework in *<project-root>/Carthage/Build/iOS/StoryTeller.framework*.

Then simply add this framework as you would any other.

## Cocoapods

At the moment I don't support [Cocoapods](https://cocoapods.org) because I regard it as as hacky poor quality solution. And I don't use it on my personal projects. I have created a posspec in the root of Story Teller, but so far it doesn't pass the pod lint tests and typically with any Ruby hack projects, is giving errors that make no sense. I'll get around to supporting it one day. But it's not something I use. Feel free to figure it out if you want.

## Submodules or Manual includes

Another fine way to include Story Teller is to use [Git Submodules](https://chrisjean.com/git-submodules-adding-using-removing-and-updating/). Whilst more technical in nature, it gves you the best control of the software. Use the following URL for your submodule or if you want to manually check Story Teller out:

[https://github.com/drekka/StoryTeller.git]()

# Adding logging to your code

Story Teller has one basic logging statement:

```objectivec
log(<key>, <message-template>, <args ...>); 
```
This looks very similar to other logging frameworks. Except that they would either having `key` replaced with a severity level, or have multiple statements such as `logDebug`, `logInfo`, etc. 

## Magic keys

Story Teller's ***Key*** is the important differentiator between it and these other logging frameworks. With Story Teller, *the key can be anything you want !"* An account number, a user id, a class, or any object you want to be able to base a search on when debugging and whatever makes sense in your app. Here are some examples:

```objectivec
log(user, "User %@ is logging", user.id);
log(@(EnumValueGUI), "GUI is doing %@ with %@", aGUIValue, anotherGUIVaue);
log(currentView, "GUI is doing something with %@", currentView);
log(@"abc", @"ABC, ha ha ha ha ha");
```

## What if I don't have an accessible key?

Often you might want to log based on something , but be in some method that doesn't have access to that data. Story Teller solves this with the concept of **Key Scopes**. You can tell it to make a specific key cover a range of log statements any log statements that are in that scope are regarded as being logged under the scope's key. Here's an example:

```objectivec
log(user.id, "User %@ is logging", user.id);
startScope(user.id);
/// ...  do stuff
log(account.id, "User %@'s account: %@", user.id, account.id); 
[self goDoSomethingWithAccount:account];
```

When reporting based on user, the second log statement ( `key:account.id` ) will also be printed because it's within the scope of user.

Scopes follow the normal Objective-C rules plus a few more: 

 * They will continue until the end of the current variable scope. Normally this is the end of the current method, loop or if statement. 
 * Story Teller's scopes also include any code called. So any logging within a method or API is also included with the scope. This enables logging across a wide range of classes to be accessed using one key without having to specifically pass that key around.  

 In the above example, any logging with in `goDoSomethingWithAccount:` will also be logged when logging for the user.

# Configuring logging

## On startup

Story Teller uses a set of options which it obtains via this process on startup:

1. A default setup is first created with no logging active.
2. Story Teller then searches all bundles in the app for a file called ***StoryTellerConfig.json***. If found this file is read and the base config is updated with any settings it contains.
3. Finally the process is checked and if any of the arguments set on the process match known keys in the config, then those values are updated.

The basic idea is that you can add a ***StoryTellerConfig.json*** file to your app to provide the general config you want to run with, and then during development you can override at will by setting arguments in XCode's scheme for your app.

Current the Json file has two settings and looks something like this:

```json
{
    "activeLogs": [
        "abc",                           /* A specific string key */
        12,                              /* A numeric (Enum?) key */
        "[User].account.balance > 500"   /* Any account over $500 */
    ],
    "loggerClass": "STConsoleLogger"  /* Optional */
}
```

### Settings

Key  | Value
------------- | -------------
activeLogs | A comma separated list of keys to activate. This is the main setting for turning on logging.
loggerClass | If you want to set a different class for the, use this setting to specify the class. The class must implement `STLogger` and have a no-arg constructor. You only need to put the class name in this setting. Story Teller will handle the rest. By default, Story Teller uses a simple console logger.

## Programmatically

You can also programmically enable and disable logging as well. To enable logging, use this statement:

```objectivec
startLogging(<key>);
```

# Smart Logging Criteria

The `activeLogs` configuration setting contains an comma seperated list of smart criteria which activate the log statements. The  `startLogging(<criteria>);` Objective C statement does the same thing, except you can only pass one criteria at a time. 

So what are these criteria? Here are the options


## General logging

First up there are two special logs you can activate:

```objectivec
startLogging(@"LogAll");
startLogging(@"LogRoots");
```

*** LogAll*** activates all log statements and disregards any other logging criteira. This is literally a turn everything on option so don't expect to use it often and it's not really what Story Teller is about.

***LogRoots*** is similar to *LogAll* except that it only logs when there are not scopes active. The idea is to get a log showing the highlevel activity in the system. So how well it works depends on how well you setup you log statements. LogRoots will also be overridden by LogAll if it is turned on.


## Simple value criteria

When Story Teller encounters a single value in a criteria, it makes the assumption that the same value has been used as a key. Simple values can be either strings or numbers. Using strings mades a good descriptive sense, whilst integers can be a good idea for matching enums. Notice that with strings, if you don't have any white space in the value, you can enter it without quotes. 

For example:

```objectivec
log("abc", @"Log some abc stuff");
log("GUI System", @"Log view @ %@", aRect);
log(@(EnumValueX), @"Log related to EnumValueX");
```

```objectivec
startLogging(@"abc");
startLogging(@"\"GUI System\"");
startLogging(@(EnumValueX)); 
```

## Classes and Protocols 

### Instances

You can log based on the type of the key used like this:

`[class-name] | <protocol-name>`

These will search for any logging where the key is an instance of the class (or is a subclass of it), or an instance that implements the specified protocol. Here's an example:

```objectivec
log(User, @"Log message for a user");
```

```objectivec
startLogging(@"[User]");
startLogging(@"<Person>");    /* Assuming User implements Person */
```

### Runtime keys

*Rarely used, but I needed it for another project.* If you add the **isa** prefix, then Story Teller will look for where the actual class or protocol has been used as a key, rather that an instance of one.

`isa [class-name] | <protocol-name>`

For example:

```objectivec
log([User class], @"Log message for class");
log(@protocol(NSCopying), @"Log message for NSCopying");
```

```objectivec
startLogging(@"isa [User]");
startLogging(@"isa <NSCopying>");
```

## KVC Property criteria

`[class-name].keypath op value`
`<protocol-name>.keypath op value`

This criteria looks for keys that matches the specified class or protocol, then examine the `keypath` on the object for the required value. Here are some examples

```objectivec
log(user, @"Log message for user");
```

```objectivec
startLogging(@"[User].account.name == \"derek's account\"");
startLogging(@"[User].account.balance > 500");
startLogging(@"<Banking>.active == YES");
startLogging(@"<Banking>.active == nil");
```
As you can see there is a lot of power here to decide what gets logged. 

Operators include all the standard comparison operators: **==** ,**!=** ,**<** ,**<=** ,**>** or **>=**.

Value can also be a nil. Which is handy for logging when information is missing.

# Execution blocks

Story Teller has another trick up it's sleeve. Often we want to run a set of statements to assemble some data before logging or even to log a number of statements at once. With other frameworks we have to manually add some boiler plate around the statements to make sure they are not always being executed. Story Teller has a statement built specifically for this purpose:

```objectivec
executeBlock(<key>, ^(id key) {
     // Statements go here.
});
``` 

The block will only be executed if they currently active logging matches the key. This makes it a perfect way to handle larger and more complex logging situations.

## Release vs Debug

Story Teller is very much a Debug orientated logger. Is is not designed to be put into production apps. To that effect, it has a strip mode. Simply add this macro to your **Release** macro declarations and all Story Teller loggin will be stripped out, leaving your Release version a lean mean speed machine.

Disable macro name: **`DISABLE_STORY_TELLER`**

## Performance

Generally speaking most loging frameworks optimize their logging decision making down to a set of booleans. This means they are fast, however it makes them relatively inflexible during the logging process. Hence the concept of log levels and class based criteria compromises but given you some basic control, but keeping this fast.

Story Teller makes every attempt to keep things as fast as possible. But because of the more intensive decision making it does, it's unlikely to be able to compete with other loggers when dealing with large volumes of logging. But all things considered, would you really want to log that much anyway?

Finally, given the performance of today's hardware, it's unlikely they Story Teller will slow down any software enough to cause a problem.


