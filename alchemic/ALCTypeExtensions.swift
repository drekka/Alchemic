//
//  ALCTypeExtensions.swift
//  AlchemicSwift
//
//  Created by Derek Clarkson on 2/10/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

import Foundation

public extension ALCType {

    public static var bool:ALCType {
        return ALCType(valueType:.bool)
    }

    public static var char:ALCType {
        return ALCType(valueType:.char)
    }

    public static var charPointer:ALCType {
        return ALCType(valueType:.charPointer)
    }

    public static var int:ALCType {
        return ALCType(valueType:.int)
    }

    public static var float:ALCType {
        return ALCType(valueType:.float)
    }

    public static var double:ALCType {
        return ALCType(valueType:.double)
    }

    public static var long:ALCType {
        return ALCType(valueType:.long)
    }

    public static var longLong:ALCType {
        return ALCType(valueType:.longLong)
    }

    public static var short:ALCType {
        return ALCType(valueType:.short)
    }

    public static var unsignedChar:ALCType {
        return ALCType(valueType:.unsignedChar)
    }

    public static var unsignedShort:ALCType {
        return ALCType(valueType:.unsignedShort)
    }

    public static var unsignedInt:ALCType {
        return ALCType(valueType:.unsignedInt)
    }

    public static var unsignedLong:ALCType {
        return ALCType(valueType:.unsignedLong)
    }

    public static var unsignedLongLong:ALCType {
        return ALCType(valueType:.unsignedLongLong)
    }

    public static var cgPoint:ALCType {
        return ALCType(valueType:.cgPoint)
    }

    public static var cgSize:ALCType {
        return ALCType(valueType:.cgSize)
    }

    public static var cgRect:ALCType {
        return ALCType(valueType:.cgRect)
    }

}
