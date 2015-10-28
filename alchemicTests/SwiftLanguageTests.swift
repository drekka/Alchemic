//
//  SwiftLanguageTests.swift
//  alchemic
//
//  Created by Derek Clarkson on 28/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

// Tests related to understanding the Swift language.

import XCTest

class SwiftLanguageTests: XCTestCase {

    class TestClass {
        var xyz:String?
    }

    func createTestClass() -> TestClass {
        let obj = TestClass()
        obj.xyz = "abc"
        return obj
    }

    func testUsingAGenericTypeDerivedFromAClassArgument() {

        func getObj<T>(arg:T.Type) -> T {
            return createTestClass()  as! T
        }

        let unknownTypeObj = getObj(TestClass.self)

        let theName = unknownTypeObj.xyz
        XCTAssertEqual("abc", theName)
    }

    func testUsingAGenericTypeDerivedFromTheReturnType() {

        func getObj<T>() -> T {
            return createTestClass() as! T
        }

        let unknownTypeObj:TestClass = getObj()

        let theName = unknownTypeObj.xyz
        XCTAssertEqual("abc", theName)
    }


}
