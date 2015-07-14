# Macro Reference

x*?* - Optional macros, x* - Zero or more declarations, x*+* - One or more declarations.

### Registering

Title | Macro | Comments
--- | --- | ---
Class registration | `AcRegister (`<br />`ACWithName(...),`*?*,<br />`ACIsFactory,`*?*<br />`ACIsPrimary,`*?*<br />`ACInitializer(...)`*?*<br />`)` | 
Specify a selector to use | `ACSelector(...)` | When used inside `ACRegister(...)`, indicates that a factory method is being declared.
Search for a class | `ACWithClass(class-name)` | 