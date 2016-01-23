//
//  SwiftObjectWithDep.swift
//  alchemic
//
//  Created by Derek Clarkson on 22/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Foundation
import AlchemicSwift

public class SwiftObjectWithDep: NSObject {

    var property: AnyObject?

    public static func alchemic(cb:ALCBuilder) {
        AcRegister(cb)
        AcInject(cb, variable:"property", type:NSObject.self, source:AcClass(SwiftNSObject.self))
    }
    
}
