//
//  AlchemicSwiftMacros.swift
//  alchemic
//
//  Created by Derek Clarkson on 20/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Foundation


// Macro replacements
// These are declared as global functions so that they are available where necessary.

public func AcName(name: String) -> ALCMacro {
    return ALCName.withName(name)
}

public func AcClass(aClass: AnyObject.Type) -> ALCMacro {
    return ALCClass.withClass(aClass)
}

public func AcValue(value: AnyObject) -> ALCMacro {
    return ALCConstantValue(value)
}

public func AcWithName(name: String) -> ALCMacro {
    return ALCWithName(name)
}

// Functions which configure Alchemic

public func AcRegister(classBuilder:ALCBuilder, settings: ALCMacro...) {
    let context = ALCAlchemic.mainContext();
    context.registerClassBuilder(classBuilder, withProperties: settings)
}

public func AcInject(classBuilder:ALCBuilder, variableName: String, settings: ALCMacro...) {
    let context = ALCAlchemic.mainContext();
    context.registerClassBuilder(classBuilder, variableDependency: variableName, withProperties: settings)
}

