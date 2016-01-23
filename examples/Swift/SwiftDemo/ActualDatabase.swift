//
//  File.swift
//  SwiftDemo
//
//  Created by Derek Clarkson on 7/11/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Foundation
import AlchemicSwift

@objc class ActualDatabase: NSObject, DataSource {

    @objc static func alchemic(cb:ALCBuilder) {
        AcRegister(cb)
    }

    func start() {
        print("Starting database ...")
    }
}
