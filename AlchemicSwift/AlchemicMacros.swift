//
//  AlchemicSwiftMacros.swift
//  alchemic
//
//  Created by Derek Clarkson on 20/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Foundation
import Alchemic

// MARK:- Macro replacements
// These are declared as global functions so that they are available where necessary.

public func AcName(name: String!) -> ALCModelSearchExpression {
    return ALCName.withName(name)
}

public func AcClass(aClass: AnyClass!) -> ALCModelSearchExpression {
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

public func AcArg(argType:AnyClass!, source: ALCSourceMacro...) -> ALCArg {
    return ALCArg(type: argType, properties: source)
}

// MARK:- Functions which configure Alchemic

public func AcRegister(classBuilder:ALCBuilder!, settings: ALCMacro...) {
    let context = ALCAlchemic.mainContext();
    context.registerClassBuilder(classBuilder, withProperties: settings)
}

public func AcInitializer(classBuilder:ALCBuilder!, initializer:Selector!, args:ALCArg...) {
    let context = ALCAlchemic.mainContext();
    context.registerClassBuilder(classBuilder, initializer:initializer, withArguments:args)
}

public func AcMethod(classBuilder:ALCBuilder!, method:Selector!, type:AnyClass!, args:ALCMacro...) {
    let context = ALCAlchemic.mainContext();
    context.registerClassBuilder(classBuilder, selector: method, returnType: type, withArguments: args)
}

public func AcInject(classBuilder:ALCBuilder!, variable: String!, type:AnyClass!, source: ALCSourceMacro...) {
    let context = ALCAlchemic.mainContext();
    context.registerClassBuilder(classBuilder, variableDependency: variable, type:type, withSource: source)
}

public func AcInjectDependencies(object: AnyObject!) {
    let context = ALCAlchemic.mainContext()
    context.injectDependencies(object)
}

// MARK:- Getters and setters

public func AcGet<T>(source:ALCSourceMacro...) -> T {
    let context = ALCAlchemic.mainContext()
    return context.getValueWithClass(T.self as! AnyClass, withSourceMacros: source) as! T
}

public func AcSet(object:AnyObject!, inBuilderWith:ALCModelSearchExpression...) {
    let context = ALCAlchemic.mainContext()
    context.setValue(object, inBuilderSearchCriteria:inBuilderWith)
}

// MARK:- Calling methods

public func AcInvoke(methodLocator:ALCModelSearchExpression!, args:AnyObject...) -> Array<AnyObject> {
    let context = ALCAlchemic.mainContext()
    return context.invokeMethodBuilders(methodLocator, withArguments: args) as! Array<AnyObject>
}

// MARK:- Lifecycle

public func AcExecuteWhenStarted(block:() -> Void) {
    let context = ALCAlchemic.mainContext()
    context.executeWhenStarted(block)
}

// MARK:- Internal

public func objcBox(value:Any!) -> NSObject {
    if value is NSObject {
        return value as! NSObject
    } else if value is String {
        return value as! NSString
    } else if value is Int {
        return value as! NSNumber
    } else {
        return value as! NSObject
    }
    
}
