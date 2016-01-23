//
//  SwiftNSObject.swift
//  alchemic
//
//  Created by Derek Clarkson on 20/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Foundation
import AlchemicSwift

public class SwiftNSObject: NSObject {

    public static func alchemic(cb:ALCBuilder) {
        AcRegister(cb, settings:AcWithName("abc"))
    }

}
