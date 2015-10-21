//
//  AlchemicSwiftMacros.swift
//  alchemic
//
//  Created by Derek Clarkson on 20/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Foundation

// Protocol to define the method which is called on swift classes.
public protocol Alchemic {
    func alchemicClassBuilderProperties() -> Array<ALCMacro>
}

// Macro replacements

public func AcValue(value: AnyObject) -> ALCConstantValue  {
    return ALCConstantValue(value)
}


public func AcWithName(name: String) -> ALCMacro {
    return ALCWithName(name)
}

// Functions which configure Alchemic

public func AcRegister(settings: ALCMacro...) {

}


public func AcInject(variableName: String) {
    let classBuilderType = ALCClassBuilderType(type: String.self as! AnyObject.Type)
    let builder = ALCBuilder(builderType: classBuilderType);
    let context = ALCAlchemic.mainContext();

    context.registerClassBuilder(builder, withProperties: getVaList([1,2,3,4]))
}

