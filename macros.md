# Macro Reference

X*?* - Optional macros, X* - Zero or more declarations, X*+* - One or more declarations.

### Registering

Macro & arguments | Comments
--- | ---
AcRegister (<br />ACWithName(...),*?*,<br />ACIsFactory*?*,<br />ACIsPrimary*?*,<br />ACInitializer(...)*?*<br />) | Registers a class as an object. If ACIsFactory is usd then each time the class is injected a new one will be generated.
ACMethod(<br />return-type,<br />selector,<br />ACIsFactory*?*,<br />ACIsPrimary*?*,<br />ACArg(...)\*,<br />) | Registers a method as the source of an object. ACArg(...) macros (if present) must match the type and order of the selectors arguments. If ACIsFactory is usd then each time the method is called for an object, a new one will be generated.
ACArg(type, value-macro\*) | Used when defining selector arguments for ACInitializer(...) or ACMethod(...). Type is the object type that will be returned. Value-macro is one or more of ACClass(...), ACProtocol(...), ACName(...), or a single occurance of ACValue(...).
ACInject(variable-name, value-macro*) | Defines a variable injection. Variable-name can be the public name of a property or it's internal name or the name of an private variable. Value-macro is one or more of ACClass(...), ACProtocol(...), ACName(...), or a single occurance of ACValue(...).
ACClass(class-name) | Matches against the model and finds classes and factory methods where the resulting object is of this type. 
ACProtocol(protocol-name) | Matches against the model and finds classes and factory methods where the resulting object conforms to the protocol. 
ACName(alchemic-name) | Matches against the model and finds classes and factory methods which have the assigned name.
ACValue(value) | Specifies a hard coded value to be used.  