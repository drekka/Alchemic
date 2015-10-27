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

public func AcName(name: String!) -> ALCModelSearchExpression {
    return ALCName.withName(name)
}

public func AcClass(aClass: AnyObject.Type!) -> ALCModelSearchExpression {
    return ALCClass.withClass(aClass)
}

public func AcProtocol(aProtocol: Protocol!) -> ALCModelSearchExpression {
    return ALCProtocol.withProtocol(aProtocol)
}

public func AcValue(value: AnyObject!) -> ALCSourceMacro {
    return ALCConstantValue(value)
}

public func AcWithName(name: String!) -> ALCMacro {
    return ALCWithName(name)
}

public func AcFactory() -> ALCMacro {
    return ALCIsFactory()
}

public func AcPrimary() -> ALCMacro {
    return ALCIsPrimary()
}

public func AcExternal() -> ALCMacro {
    return ALCIsExternal()
}

public func AcArg(argType:AnyObject.Type!, source: ALCSourceMacro...) -> ALCMacro {
    return ALCArg(type: argType, properties: source)
}

// Functions which configure Alchemic

public func AcRegister(classBuilder:ALCBuilder!, settings: ALCMacro...) {
    let context = ALCAlchemic.mainContext();
    context.registerClassBuilder(classBuilder, withProperties: settings)
}

public func AcInitializer(classBuilder:ALCBuilder!, initializer:Selector!, args:ALCMacro...) {
    let context = ALCAlchemic.mainContext();
    context.registerClassBuilder(classBuilder, initializer:initializer, withProperties:args)
}

public func AcInject(classBuilder:ALCBuilder!, variableName: String!, type:AnyObject.Type!, source: ALCSourceMacro...) {
    let context = ALCAlchemic.mainContext();
    context.registerClassBuilder(classBuilder, variableDependency: variableName, type:type, withSourceMacros: source)
}

public func AcInjectDependencies(object: AnyObject!) {
    let context = ALCAlchemic.mainContext()
    context.injectDependencies(object)
}

// Accessing objects

public func AcGet(type:AnyObject.Type!, source:ALCSourceMacro...) -> AnyObject {
    let context = ALCAlchemic.mainContext()
    return context.getValueWithClass(type, withSourceMacros: source)
}

public func AcSet(object:AnyObject!, inBuilderWith:ALCModelSearchExpression...) {
    let context = ALCAlchemic.mainContext()
    context.setValue(object, inBuilderSearchCriteria:inBuilderWith)
}
