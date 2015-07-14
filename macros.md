# Macro Reference

x? - Optional macros, x^(*) - Zero or more declarations, x^(+) - One or more declarations.

Macro | Description
--- | --- | ---
`AcRegister(`<br />`ACWithName(...)`<br />``)` | Registers a class or method as a source of objects.
`ACSelector(...)` | When used inside `ACRegister(...)`, indicates that a factory method is being declared and specifies the method to use.<br />When used inside a `ACInitializer(...)`, specifies the initializer to use. 
`ACWithClass(class-name)` | When used in `ACInject(...)`, indicates that the dependency will be injected with an object matching the class.