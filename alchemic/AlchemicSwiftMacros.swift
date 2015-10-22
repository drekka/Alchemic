//
//  AlchemicSwiftMacros.swift
//  alchemic
//
//  Created by Derek Clarkson on 20/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Foundation


// Macro replacements

public func AcValue(value: AnyObject) -> ALCConstantValue  {
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
//    let classBuilderType = ALCClassBuilderType(type: String.self as! AnyObject.Type)
//    let builder = ALCBuilder(builderType: classBuilderType);
//    let context = ALCAlchemic.mainContext();
//
//    context.registerClassBuilder(builder, withProperties: getVaList([1,2,3,4]))
}

