//
//  Singleton.swift
//  AlchemicSwift
//
//  Created by Derek Clarkson on 1/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

import UIKit

@testable import Alchemic

class Singleton:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcRegister(of)
    }
}

class SingletonWithInit:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcInitializer(of, initializer: #selector(SingletonWithInit.init(withString:)), AcString("abc"))
    }
    var aString:String
    @objc init(withString:String) {
        aString = withString
    }
}

class ClassWithString:NSObject {
    var aString:String
    @objc init(withString:String) {
        aString = withString
    }
}

class SingletonWithAcMethod:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcMethod(of,
                 method: #selector(SingletonWithAcMethod.createSingleton(withString:)),
                 returnType:ClassWithString.self,
                 AcString("abc"),
                 AcFactoryName("acMethod"))
    }
    func createSingleton(_ withString:String) -> ClassWithString {
        return ClassWithString(withString: withString)
    }
}

class SingletonWithName:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcRegister(of, AcFactoryName("singleton"))
    }
}

class SingletonWithInjection:NSObject {
    var singleton:Singleton?
    var aInt:CInt = 0
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcInject(of, variable: "singleton", ofType: Singleton.self)
        AcInject(of, variable: "aInt", ofType:ALCType.int, AcInt(5))
    }
}

class Template:NSObject {
    static var counter:Int = 0
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcRegister(of, AcTemplate())
    }
    var counter:Int
    override init() {
        Template.counter += 1
        self.counter = Template.counter
    }
}

@objc protocol PrimaryProtocol {}

class HiddenSingleton:NSObject, PrimaryProtocol {
    static func alchemic(_ of: ALCClassObjectFactory) {}
}

class PrimarySingleton:NSObject, PrimaryProtocol {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcRegister(of, AcPrimary())
    }
}

class Reference:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcRegister(of, AcReference())
    }
}

class NillableReference:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcRegister(of, AcReference(), AcNillable())
    }
}

class WeakReference:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcRegister(of, AcReference(), AcNillable(), AcWeak())
    }
}

class TransientReference:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcRegister(of, AcNillable(), AcTransient())
    }
}

class SingletonWithTransient:NSObject {
    var transientDep:TransientReference?
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcInject(of, variable: "transientDep", ofType:TransientReference.self)
    }
}

class SingletonWithAcMethodAcArg:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcRegister(of)
        AcMethod(of,
                 method: #selector(SingletonWithAcMethodAcArg.createSingleton(withString:)),
                 returnType:ClassWithString.self,
                 AcArg(NSString.self, AcString("def")),
                 AcFactoryName("acMethodWithAcArg")
        )
    }
    func createSingleton(_ withString:String) -> ClassWithString {
        return ClassWithString(withString: withString)
    }
}

class EnableSpecialFeatures:NSObject {
    static func alchemic(_ of: ALCClassObjectFactory) {
        AcEnableUserDefaults()
        AcEnableCloudKeyValueStore()
    }
}

class Injections:NSObject {
    
    // C scalar types that work when optional
    var aBool:Bool!
    
    // C scalars types that cannot be optional
    var aChar:CSignedChar = 0
    var aDouble:CDouble = 0
    var aFloat:CFloat = 0
    var aInt:CInt = 0
    var aLong:CLong = 0
    var aLongLong:CLongLong = 0
    var aShort:CShort = 0
    var aUChar:CUnsignedChar = 0
    var aUInt:CUnsignedInt = 0
    var aULong:CUnsignedLong = 0
    var aULongLong:CUnsignedLongLong = 0
    var aUShort:CUnsignedShort = 0
    
    // This is how const char * is seen.
    // Currently there is no easy way to inject these.
    var aCharPointer:UnsafePointer<Int8>!
    
    // C structs
    var size:CGSize = CGSize.zero
    var point:CGPoint = CGPoint.zero
    var rect:CGRect = CGRect.zero
    
    // Obejctive-C types
    var aString:NSString? // Optional strings work!
    var aNumber:NSNumber?
    var aArray:NSArray?
    
    static func alchemic(_ of: ALCClassObjectFactory) {
        
        AcInject(of, variable: "aString", ofType:NSString.self, AcString("abc"))
        
        AcInject(of, variable: "aBool", ofType:ALCType.bool, AcBool(true))
        
        AcInject(of, variable: "aChar", ofType:ALCType.char, AcChar(CSignedChar(5)))
        
        //let chars = ("abc" as NSString).utf8String!
        //AcInject(of, variable: "aCharPointer", ofType:ALCType.charPointer, AcCString("abc"))
        
        AcInject(of, variable: "aFloat", ofType:ALCType.float, AcFloat(1.2345))
        AcInject(of, variable: "aDouble", ofType:ALCType.double, AcDouble(1.2345))
        
        AcInject(of, variable: "aInt", ofType:ALCType.int, AcInt(5))
        AcInject(of, variable: "aLong", ofType:ALCType.long, AcLong(5))
        AcInject(of, variable: "aLongLong", ofType:ALCType.longLong, AcLongLong(5))
        AcInject(of, variable: "aShort", ofType:ALCType.short, AcShort(5))
        AcInject(of, variable: "aUChar", ofType:ALCType.unsignedChar, AcUnsignedChar(5))
        AcInject(of, variable: "aUInt", ofType:ALCType.unsignedInt, AcUnsignedInt(5))
        AcInject(of, variable: "aULong", ofType:ALCType.unsignedLong, AcUnsignedLong(5))
        AcInject(of, variable: "aULongLong", ofType:ALCType.unsignedLongLong, AcUnsignedLongLong(5))
        AcInject(of, variable: "aUShort", ofType:ALCType.unsignedShort, AcUnsignedShort(5))
        
        AcInject(of, variable: "size", ofType:ALCType.cgSize, AcSize(1.0, 2.0))
        AcInject(of, variable: "point", ofType:ALCType.cgPoint, AcPoint(1.0, 2.0))
        AcInject(of, variable: "rect", ofType:ALCType.cgRect, AcRect(1.0, 2.0, 3.0, 4.0))
        
        AcInject(of, variable: "aNumber", ofType:NSNumber.self, AcObject(NSNumber(value:5)))
        AcInject(of, variable: "aArray", ofType:NSArray.self, AcString("abc"))
        
    }
}

