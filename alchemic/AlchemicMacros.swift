//
//  AlchemicSwiftMacros.swift
//  alchemic
//
//  Created by Derek Clarkson on 20/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Foundation
import Alchemic.Private

// MARK:- Functions which configure Alchemic

public func AcRegister(_ classObjectFactory:ALCClassObjectFactory, _ config: AnyObject...) {
    var configuration = [AnyObject]()
    for configItem in config {
        configuration.append(configItem)
    }
    mainContext().objectFactoryConfig(classObjectFactory, config:config)
}

public func AcInitializer(_ classObjectFactory:ALCClassObjectFactory, initializer:Selector, _ args:AnyObject...) {
    var arguments = [AnyObject]()
    for arg in args {
        arguments.append(arg)
    }
    mainContext().objectFactory(classObjectFactory, initializer: initializer, args: arguments)
}

public func AcMethod(_ classObjectFactory:ALCClassObjectFactory, method:Selector, returnType:AnyClass, _ configOrArgs:AnyObject...) {
    var configAndArgs = [AnyObject]()
    for configItemOrArg in configOrArgs {
        configAndArgs.append(configItemOrArg)
    }
    mainContext().objectFactory(classObjectFactory, registerFactoryMethod:method, returnType:returnType, configAndArgs:configOrArgs)
}

public func AcInject(_ classObjectFactory:ALCClassObjectFactory, variable:String, ofType:AnyObject, _ config:AnyObject...) {

    var configuration = [AnyObject]()
    for configItem in config {
        configuration.append(configItem)
    }

    // Handle where we are passed a ALCType, usually when dealing with scalars.
    var type:ALCType
    if let ofType = ofType as? ALCType {
        type = ofType
    } else {
        type = ALCType(with: ofType as! AnyClass)
    }

    let ivar = ALCRuntime.forClass(classObjectFactory.type.objcClass!, variableForInjectionPoint:variable)
    mainContext().objectFactory(classObjectFactory, registerInjection:ivar, withName:variable, of:type, config:config)
}

// MARK:- Configuration

public func AcFactoryName(_ name: String) -> ALCFactoryName {
    return ALCFactoryName.withName(name)
}

// MARK:- Lifecycle

func AcWhenReady(_ whenReady:@escaping () -> Swift.Void) {
    mainContext().execute(whenStarted: whenReady)
}

// MARK:- Searching

public func AcClass(_ aClass: AnyClass) -> ALCModelSearchCriteria {
    return ALCModelSearchCriteria.init(for: aClass)
}

public func AcProtocol(_ aProtocol: Protocol) -> ALCModelSearchCriteria {
    return ALCModelSearchCriteria.init(for:aProtocol)
}

public func AcName(_ name: String) -> ALCModelSearchCriteria {
    return ALCModelSearchCriteria.init(forName:name)
}

// MARK:- Configuration

public func AcTemplate() -> ALCIsTemplate {
    return ALCIsTemplate.macro()
}

public func AcPrimary() -> ALCIsPrimary {
    return ALCIsPrimary.macro()
}

public func AcReference() -> ALCIsReference {
    return ALCIsReference.macro()
}

public func AcNillable() -> ALCIsNillable {
    return ALCIsNillable.macro()
}

public func AcWeak() -> ALCIsWeak {
    return ALCIsWeak.macro()
}

public func AcTransient() -> ALCIsTransient {
    return ALCIsTransient.macro()
}

public func AcArg(_ argType:AnyClass, _ searchCriteria:AnyObject...) -> ALCMethodArgumentDependency {
    let type = ALCType(with: argType)
    return ALCMethodArgumentDependency.methodArgument(with:type, argumentCriteria:searchCriteria)
}

// MARK:- Getters and setters

public func AcGet<T>(_ searchCriteria:AnyObject...) -> T? {
    return mainContext().object(with: T.self as! AnyClass, searchCriteria:searchCriteria) as? T
}

public func AcSet(_ object:AnyObject, _ searchCriteria:AnyObject...) {
    mainContext().setObject(object, searchCriteria:searchCriteria)
}

public func AcInjectDependencies(_ object:AnyObject, _ searchCriteria:AnyObject...) {
    mainContext().injectDependencies(object, searchCriteria:searchCriteria)
}

// MARK:- Special features

public func AcEnableUserDefaults() {
    ALCUserDefaultsAspect.enabled = true
}

public func AcEnableCloudKeyValueStore() {
    ALCCloudKeyValueStoreAspect.enabled = true
}

// MARK:- Internal

private func mainContext() -> ALCContextImpl {
    return Alchemic.mainContext() as! ALCContextImpl
}

