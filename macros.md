# Macro Reference

X*?* - Optional macros, X* - Zero or more declarations, X*+* - One or more declarations.

### Registering

Macro & arguments | Comments
--- | ---
AcRegister(<br />AcWithName(...),*?*,<br />AcIsFactory*?*,<br />AcIsPrimary*?*<br />) | Registers a class as an object. If AcIsFactory is usd then each time the class is injected a new one will be generated.
AcInitializer(<br />initializer,<br />AcArg(...)\*<br />) | Delclares the initializer to used when creating an instance of a class.
AcMethod(<br />return-type,<br />selector,<br />AcIsFactory*?*,<br />AcIsPrimary*?*,<br />AcArg(...)\*,<br />) | Registers a method as the source of an object. AcArg(...) macros (if present) must match the type and order of the selectors arguments. If AcIsFactory is usd then each time the method is called for an object, a new one will be generated.
AcArg(type, value-macro\*) | Used when defining selector arguments for AcInitializer(...) or AcMethod(...). Type is the object type that will be returned. Value-macro is one or more of AcClass(...), AcProtocol(...), AcName(...), or a single occurance of AcValue(...).
AcInject(variable-name, value-macro*) | Defines a variable injection. Variable-name can be the public name of a property or it's internal name or the name of an private variable. Value-macro is one or more of AcClass(...), AcProtocol(...), AcName(...), or a single occurance of AcValue(...).
AcClass(class-name) | Matches against the model and finds classes and factory methods where the resulting object is of this type. 
AcProtocol(protocol-name) | Matches against the model and finds classes and factory methods where the resulting object conforms to the protocol. 
AcName(alchemic-name) | Matches against the model and finds classes and factory methods which have the assigned name.
AcValue(value) | Specifies a hard coded value to be used.  