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
        // Note that in Swift, String is not a class.
        let value = AcClass(NSString.self) as! ALCClass
        XCTAssertTrue(value.aClass == NSString.self)
    }

    func testAcProtocol() {
        let value = AcProtocol(NSCopying.self) as! ALCProtocol
        let nscopying = NSCopying.self as Protocol
        let valueProtocol = value.aProtocol
        XCTAssertTrue(nscopying === valueProtocol)
    }

    func testAcArg() {
        let arg = AcArg(NSNumber.self, source:AcValue(5)) as! ALCArg
        XCTAssertNotNil(arg)
        XCTAssertTrue(arg.valueType == NSNumber.self)
        XCTAssertEqual(5, arg.valueSource.value as? Int)
    }

    func testAcValue() {
        let value = AcValue("hello") as! ALCConstantValue
        XCTAssertEqual("hello", value.value as? String)
    }

    func testAcWithName() {
        let value = AcWithName("hello") as! ALCWithName
        XCTAssertEqual("hello", value.asName)
    }

    func testAcFactory() {
        let value = AcFactory()
        XCTAssertNotNil(value)
        XCTAssertTrue(value is ALCIsFactory)
    }

    func testAcPrimary() {
        let value = AcPrimary()
        XCTAssertNotNil(value)
        XCTAssertTrue(value is ALCIsPrimary)
    }

    func testAcExternal() {
        let value = AcExternal()
        XCTAssertNotNil(value)
        XCTAssertTrue(value is ALCIsExternal)
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

    func testAcMethod() {


    }

    func testAcInitializer() {

        STStoryTeller().startLogging("LogAll")

        class TestClass : NSObject {
            var string: String
            @objc init(string:String) {
                self.string = string
            }
            @objc static func alchemic(cb: ALCBuilder) {
                // Need to update code to copy values to initializer builder if this is used.
                AcRegister(cb, settings: AcWithName("testClass"))
                AcInitializer(cb, initializer: "initWithString:", args:AcArg(NSString.self, source:AcValue("abc")))
            }
        }

        super.setupRealContext()
        super.startContextWithClasses([TestClass.self])

        let context = ALCAlchemic.mainContext()
        let searchExpressions: NSSet = [AcName("testClass")]
        let builders = context.findBuildersWithSearchExpressions(searchExpressions as Set)

        let builder = builders.first
        XCTAssertEqual("abc", (builder?.value as! TestClass).string)

    }

    // MARK:- Properties

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

    // MARK:- Injections

    func testAcInjectDependencies() {
        
    }
    
    // MARK:- Object accessors
    
    func testAcGet() {
        
    }
    
    func testAcSet() {
        
    }
    
    func testAcInvoke() {
        
    }
    
    // MARK:- Startup
    
    func testAcExecuteWhenStarted() {
        
    }
    
    
}
