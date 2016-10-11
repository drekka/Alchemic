---
title: Tag reference
---

# Alchemic reference

## Core

Function/Macro | Description
--- | ---
{{ site.data.macros.register }}(...) | Declares a class factory. Optional arguments can be used to further configure it.
{{ site.data.macros.initialiser }}(*selector*, ...) | Specifies an initializer to be used when instantiating a class. Option arguments specify where to get the values from for any initializer arguments. 
{{ site.data.macros.method }}(*return-type*, *selector*, ...) | Registers a method as an object factory. If the method is an instance method, then Alchemic will make sure the class is instantiated first. If the method is a class method then it is called directly. Also takes the same configuration arguments as `{{site.data.macros.register}}`. Optional arguments specify where to get the values from for any method arguments.
{{ site.data.macros.inject }}(*variable*, ...) | Declares an injection. If no arguments are specified, Alchemic will interrogate the runtime for the variables type data and build some model search criteria based on that.
{{ site.data.macros.factoryName }}(*name*) | Configuration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Specifies a custom name to store the object factory under in the model.
{{ site.data.macros.template }} | Configuration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Indicates that the object factory is to behave like a template, creating new instances of the class every time an object is requested. `{{site.data.macros.set}}` cannot be used with a template because the object factory will never store a value.
{{ site.data.macros.primary }} | Configuration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Indicates that the object factory is considered more important that other object factories when considering possible candidates for injection. If primary object factories are returned in a model search, all other object factories will be ignored.
{{ site.data.macros.reference }} | Configuration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Puts the object factory into reference mode. In this mode the object factory will not generate any objects. Instead it will wait to be given an object to be stored for injection. Attempting to inject an object from a reference object factory which no value has been stored will throw an exception unless the factory is also configured with the `{{ site.data.macros.nillable }}` option.
{{ site.data.macros.nillable }} | Configuaration option for `{{ site.data.macros.register }}` and `{{ site.data.macros.method }}` tags. Indicates that the object factory is allowed to have a nil value. This is often teamed with the `{{site.data.macros.weak}}` tag.
{{ site.data.macros.weak }} | Configuration option for `{{ site.data.macros.register }}` and `{{ site.data.macros.method }}` tags. Weak object factories store weak references to the objects they have created or stored.  This stops the object factory from creating memory leaks when dealing with objects (such as `UIViewController` instances) which are not always present. 
{{ site.data.macros.transient }} | Configuration option for  `{{ site.data.macros.inject }}`. Specifies that the variable injection is regarded as transient. Effectively this means that Alchemic will watch the object factories that supplied objects for the injection and if any change their stored references, Alchemic will re-inject the dependency automatically.
{{ site.data.macros.arg }}(*arg-type*, ...) | Used to declare arguments for `{{ site.data.macros.initialiser }}` and `{{ site.data.macros.method }}` tags. The arg type is the expected type of the method argument. Optional arguments can then be added to define where the value for the argument comes from. `{{ site.data.macros.arg }}` is most useful where the search criteria for a value is a different type to the argument.
{{ site.data.macros.get }}(*return-type*, ...) | Can be used inline with your code to retrieve a value from Alchemic. The retunr type is the type that Alchemic is expected to return. This will be used for any autoboxing required. If there are no search criteria after the return type, then it will be examined to deduce a matching search criteria.
{{ site.data.macros.set }}(*value*, ...) | Can be used inline with your code to set a value in an Alchemic object factory. After the value to be set, you can specify search criteria to be used to find the obejct factory to be set. If not specified the type of the value will be used as a search critieria.
{{ site.data.macros.class }}(*class-name*) | Used when you need to search for one or more object factories in the model. Searches the model for object factories that manage objects of the specified class. There can only be a single instance of `{{ site.data.macros.class }}` in any search criteria.
{{ site.data.macros.protocol }}(*protocol-name*) | Used when you need to search for one or more object factories in the model. Searches the model for object factories that manage objects which conform to the specified protocol. You can used as many of these as you see fit in a search criteria.
{{ site.data.macros.name }}(*object-factory-name*) | Used when you need to search for one or more object factories in the model. USed when you know the name of the object factory you want to retrieve. Cannot be used with {{ site.data.macros.class }} and {{ site.data.macros.protocol }}. 

## Utility

Function/Macro | Description
--- | ---
{{ site.data.macros.weakSelf }} | Useful macro for declaring a weak reference to `self`. Functionally equivalent to<br />```__weak __typeof(self) weakSelf = self```<br />Use before creting a block that will be executed outside of the current routine. Helps to stop circular retain cycles.
{{ site.data.macros.strongSelf }} | Use within a block that will be executed out side the current scope. Declares a local strong reference to a previously declared weak reference. Use in tandom with `{{ site.data.macros.weakSelf }}` for best effect. Functionally equivalent to<br />```__typeof(self) strongSelf = weakSelf```
{{ site.data.macros.ignoreSelector }}(*code*) | Mainly used when declaring selectors from other classes and selector warnings are turned on. Pushes a new clang diagnostic scope, turns off selector warnings, includes the passed code then pops the scope.  

## Constants

Constants are for setting contant values for method arguments, injections, etc.

Constant example | Swift ACLType | Type
--- | ---
{{ site.data.macros.bool }}(*YES*) | ALCType.bool | BOOL
{{ site.data.macros.char }}(*'x'*) || char
{{ site.data.macros.cString }}(*"abc"*) || char *
{{ site.data.macros.double }}(*1.23456*) || double
{{ site.data.macros.float }}(*1.2f*) || float
{{ site.data.macros.int }}(*5*) || int
{{ site.data.macros.long }}(*5*) || long
{{ site.data.macros.longLong }}(*5*) || long long
{{ site.data.macros.short }}(*5*) || short
{{ site.data.macros.uChar }}(*'x'*) || unsigned char
{{ site.data.macros.uInt }}(*5*) || unsigned int
{{ site.data.macros.uLong }}(*5*) || unsigned long
{{ site.data.macros.uLongLong }}(*5*) || unsigned long long
{{ site.data.macros.uShort }}(*5*) || unsigned short
{{ site.data.macros.cgFloat }}(*1.23456f*) || CGFloat
{{ site.data.macros.cgSize }}(*CGSizeMake(1.0f, 2.0f)*) || CGSize
{{ site.data.macros.cgPoint }}(*1.0f, 2.0f*) || CGPoint
{{ site.data.macros.cgRect }}(*1.0f, 2.0f, 3.0f, 4.0f*)  || CGRect
{{ site.data.macros.string }}(*@"abc"*) || NSString *
{{ site.data.macros.nil }} || nil



