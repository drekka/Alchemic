---
title: Tag reference
---

# Alchemic reference

## Core
	
{{ site.data.macros.register }}(...) | Declares a class factory. Optional arguments can be used to further configure it.
{{ site.data.macros.initialiser }}(selector, ...) | Specifies an initializer to be used when instantiating a class. Option arguments specify where to get the values from for any initializer arguments. 
{{ site.data.macros.method }}(return-type, selector, ...) | Registers a method as an object factory. If the method is an instance method, then Alchemic will make sure the class is instantiated first. If the method is a class method then it is called directly. Also takes the same configuration arguments as `{{site.data.macros.register}}`. Optional arguments specify where to get the values from for any method arguments.
{{ site.data.macros.inject }}(variable, ...) | Declares an injection. If no arguments are specified, Alchemic will interrogate the runtime for the variables type data and build some model search criteria based on that.
{{ site.data.macros.factoryName }}(name) | Configuration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Specifies a custom name to store the object factory under in the model.
{{ site.data.macros.template }} | Configuration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Indicates that the object factory is to behave like a template, creating new instances of the class every time an object is requested. `{{site.data.macros.set}}` cannot be used with a template because the object factory will never store a value.
{{ site.data.macros.primary }} | Configuration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Indicates that the object factory is considered more important that other object factories when considering possible candidates for injection. If primary object factories are returned in a model search, all other object factories will be ignored.
{{ site.data.macros.reference }} | Configuration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Puts the object factory into reference mode. In this mode the object factory will not generate any objects. Instead it will wait to be given an object to be stored for injection. Attempting to inject an object from a reference object factory which no value has been stored will throw an exception unless the factory is also configured with the `{{site.data.macros.nillable}}` option.
{{ site.data.macros.nillable }} | Configuaration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Indicates that the object factory is allowed to have a nil value. This is often teamed with the `{{site.data.macros.weak}}` tag.
{{ site.data.macros.weak }} | Configuration option for `{{site.data.macros.register}}` and `{{site.data.macros.method}}` tags. Weak object factories store weak references to the objects they have created or stored.  This stops the object factory from creating memory leaks when dealing with objects (such as `UIViewController` instances) which are not always present. 
{{ site.data.macros.transient }} | Configuration option for  `{{site.data.macros.inject}}`. Specifies that the variable injection is regarded as transient. Effectively this means that Alchemic will watch the object factories that supplied objects for the injection and if any change their stored references, Alchemic will re-inject the dependency automatically.
{{ site.data.macros.arg }}(arg-type, ...) | Used to declare arguments for `{{site.data.macros.initializer}}` and `{{site.data.macros.method}}` tag. The arg type is the expected type of the method argument. Optional arguments can then be added to define where the value for the argument comes from. `{{ site.data.macros.arg }}` is most useful where the search criteria for a value is a different type to the argument.
{{ site.data.macros.get }} |
{{ site.data.macros.set }} |
{{ site.data.macros.class }} |
{{ site.data.macros.protocol }} |
{{ site.data.macros.name }} |

## Utility

{{ site.data.macros.weakSelf }} |
{{ site.data.macros.strongSelf }} |
{{ site.data.macros.ignoreSelector }} |

## Constants

{{ site.data.macros.bool }} |
{{ site.data.macros.int }} |
{{ site.data.macros.float }} |
{{ site.data.macros.double }} |
{{ site.data.macros.cgFloat }} |
{{ site.data.macros.cgSize }} |
{{ site.data.macros.cgRect }} |
{{ site.data.macros.string }} |
{{ site.data.macros.nil }} |



