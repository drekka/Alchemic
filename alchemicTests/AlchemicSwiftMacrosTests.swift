//
//  AlchemicSwiftMacrosTests.swift
//  alchemic
//
//  Created by Derek Clarkson on 23/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Alchemic
import StoryTeller

class AlchemicSwiftMacrosTests: ALCTestCase {

    // MARK: - Argument macros

    func testAcName() {
        let value = AcName("abc") as! ALCName
        XCTAssertEqual("abc", value.aName)
    }

    func testAcClass() {
        let value = AcClass(NSString.self) as! ALCClass
        XCTAssertTrue(value.aClass == NSString.self)
    }

    func testAcValue() {
        let value = AcValue("hello") as! ALCConstantValue
        XCTAssertEqual("hello", value.value as? String)
    }

    func testAcWithName() {
        let value = AcWithName("hello") as! ALCWithName
        XCTAssertEqual("hello", value.asName)
    }

    // MARK: - Top level macros

    func testAcRegister() {

        class TestClass : NSObject {
            @objc static func alchemic(cb: ALCBuilder) {
                AcRegister(cb, settings:AcWithName("abc"))
            }
        }

        super.setupRealContext()
        super.startContextWithClasses([TestClass.self])

        let context = ALCAlchemic.mainContext()
        let cb = context.classBuilderForClass(TestClass.self)

        XCTAssertEqual("abc", cb?.name)
    }

    func testAcInject() {

        class NestedClass: NSObject {
            @objc static func alchemic(cb: ALCBuilder) {
                AcRegister(cb, settings:AcWithName("nestedObj"))
            }
        }

        class TestClass : NSObject {
            var nestedObj:AnyObject?
            @objc static func alchemic(cb: ALCBuilder) {
                AcRegister(cb, settings:AcWithName("abc"))
                AcInject(cb, variableName: "nestedObj", settings:AcName("nestedObj"))
            }
        }

        super.setupRealContext()
        super.startContextWithClasses([TestClass.self, NestedClass.self])

        let context = ALCAlchemic.mainContext()
        let cbTestClass = context.classBuilderForClass(TestClass.self)
        let cbNestedClass = context.classBuilderForClass(NestedClass.self)

        XCTAssertEqual("abc", cbTestClass?.name)
        XCTAssertEqual("nestedObj", cbNestedClass?.name)

        let nestedObj = cbNestedClass?.value as! NestedClass
        let testObj = cbTestClass?.value as! TestClass

        XCTAssertEqual(nestedObj, testObj.nestedObj as? NestedClass)
    }
    
}
