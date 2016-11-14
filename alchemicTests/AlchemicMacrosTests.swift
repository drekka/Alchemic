//
//  AlchemicMacrosTests.swift
//  alchemic
//
//  Created by Derek Clarkson on 13/11/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Alchemic

class AlchemicMacrosTests: XCTestCase {

    override func setUp() {
        let model = ALCModelImpl()
        (Alchemic.mainContext() as! ALCContextImpl).setValue(model, forKey:"_model")
    }

    func testAcRegister() {
    }

    
}
