//
//  ALCTypeExtensions.swift
//  AlchemicSwift
//
//  Created by Derek Clarkson on 2/10/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

import Foundation
import Alchemic.Private

public extension ALCType {

    public static var bool:ALCType {
        return ALCType(valueType:ALCValueType.bool)
    }

    public static var char:ALCType {
        return ALCType(valueType:ALCValueType.char)
    }

    public static var charPointer:ALCType {
        return ALCType(valueType:ALCValueType.charPointer)
    }

    public static var int:ALCType {
        return ALCType(valueType:ALCValueType.int)
    }

    public static var float:ALCType {
        return ALCType(valueType:ALCValueType.float)
    }

    public static var double:ALCType {
        return ALCType(valueType:ALCValueType.double)
    }

    public static var long:ALCType {
        return ALCType(valueType:ALCValueType.long)
    }

    public static var longLong:ALCType {
        return ALCType(valueType:ALCValueType.longLong)
    }

    public static var short:ALCType {
        return ALCType(valueType:ALCValueType.short)
    }

    public static var unsignedChar:ALCType {
        return ALCType(valueType:ALCValueType.unsignedChar)
    }

    public static var unsignedShort:ALCType {
        return ALCType(valueType:ALCValueType.unsignedShort)
    }

    public static var unsignedInt:ALCType {
        return ALCType(valueType:ALCValueType.unsignedInt)
    }

    public static var unsignedLong:ALCType {
        return ALCType(valueType:ALCValueType.unsignedLong)
    }

    public static var unsignedLongLong:ALCType {
        return ALCType(valueType:ALCValueType.unsignedLongLong)
    }

    public static var cgPoint:ALCType {
        return ALCType(valueType:ALCValueType.cgPoint)
    }

    public static var cgSize:ALCType {
        return ALCType(valueType:ALCValueType.cgSize)
    }

    public static var cgRect:ALCType {
        return ALCType(valueType:ALCValueType.cgRect)
    }

}
