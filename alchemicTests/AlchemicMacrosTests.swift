//
//  AlchemicSwiftMacrosTests.swift
//  alchemic
//
//  Created by Derek Clarkson on 23/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import Foundation
@testable import Alchemic
import StoryTeller

class AlchemicMacrosTests: ALCTestCase {

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
        let arg = AcArg(NSNumber.self, source:AcValue(5)) 
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

        STStoryTeller().startLogging("LogAll")

        class TestClass: NSObject {
            var name: NSString?
            @objc func objectFactory(arg:String) -> TestClass {
                let x = TestClass()
                x.name = arg
                return x
            }
            @objc static func alchemic(cb:ALCBuilder) {
                AcRegister(cb)
                AcMethod(cb, method: "objectFactory:",
                    type: NSString.self,
                    args: AcArg(NSString.self, source: AcValue("abc")), AcWithName("def"), AcFactory())
            }
        }

        super.setupRealContext()
        super.startContextWithClasses([TestClass.self])

        let obj:TestClass = AcGet(AcName("def")) //as! TestClass
        XCTAssertNotNil(obj)

        let name = obj.name
        XCTAssertEqual("abc", name)

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
        XCTAssertGreaterThan(builders.count, 0)
        if (builders.count > 0) {
            let builder:ALCBuilder = builders.first!

            // This should return a TestClass with the constant string.
            XCTAssertEqual("abc", (builder.value as! TestClass).string)
        }

    }

    // MARK:- Properties

    func testAcInjectAString() {

        class TestClass : NSObject {
            var stringProperty: NSString?
            @objc static func alchemic(cb: ALCBuilder) {
                AcRegister(cb, settings:AcWithName("abc"))
                AcInject(cb, variableName: "stringProperty", type:NSObject.self, source:AcValue("the string"))
            }
        }

        super.setupRealContext()
        super.startContextWithClasses([TestClass.self])

        let obj:TestClass = AcGet(AcName("abc")) 
        let injectedString = obj.stringProperty
        XCTAssertEqual("the string", injectedString)
    }

    func testAcInjectObject() {

        class NestedClass: NSObject {
            @objc static func alchemic(cb: ALCBuilder) {
                AcRegister(cb, settings:AcWithName("nestedObj"))
            }
        }

        class TestClass : NSObject {
            var nestedObj: AnyObject?
            @objc static func alchemic(cb: ALCBuilder) {
                AcRegister(cb, settings:AcWithName("abc"))
                AcInject(cb, variableName: "nestedObj", type:NSObject.self, source:AcName("nestedObj"))
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

        STStoryTeller().startLogging("LogAll")

        class TestClass : NSObject {
            var name:NSString?
            @objc static func alchemic(cb: ALCBuilder) {
                AcInject(cb, variableName: "name", type:NSString.self, source:AcValue("abc"))
            }
        }

        super.setupRealContext()
        super.startContextWithClasses([TestClass.self])

        let obj = TestClass()
        AcInjectDependencies(obj)
        XCTAssertEqual("abc", obj.name)

    }
    
    // MARK:- Object accessors
    
    func testAcGet() {

        class TestClass : NSObject {
            @objc static func alchemic(cb: ALCBuilder) {
                AcRegister(cb)
            }
        }

        super.setupRealContext()
        super.startContextWithClasses([TestClass.self])

        let obj:TestClass = AcGet(AcClass(TestClass.self))
        XCTAssertNotNil(obj)
    }
    
    func testAcSet() {

        STStoryTeller().startLogging("LogAll")
        class TestClass : NSObject {
            @objc static func alchemic(cb: ALCBuilder) {
                AcRegister(cb, settings:AcWithName("abc"), AcExternal())
            }
        }

        super.setupRealContext()
        super.startContextWithClasses([TestClass.self])

        let obj = TestClass()

        AcSet(obj, inBuilderWith:AcName("abc"))

        let returnedObj:TestClass = AcGet(AcName("abc"))
        XCTAssertNotNil(returnedObj)
        XCTAssertEqual(obj, returnedObj)

    }
    
    func testAcInvoke() {

        class TestClass:NSObject {
            @objc func aFunc(aString:String, aNumber:NSNumber) -> String {
                XCTAssertEqual("abc", aString)
                XCTAssertEqual(12, aNumber)
                return "def"
            }
            @objc static func alchemic(cb:ALCBuilder) {
                AcRegister(cb)
                AcMethod(cb, method: "aFunc:aNumber:",
                    type: NSString.self,
                    args: AcWithName("xyz"), AcFactory(),
                AcArg(NSString.self, source: AcValue("")),
                AcArg(NSString.self, source: AcValue(""))
                )
            }
        }

        super.setupRealContext()
        super.startContextWithClasses([TestClass.self])

        let results:Array<AnyObject> = AcInvoke(AcName("xyz"), args:"abc", 12)
        XCTAssertEqual(1, results.count)
        let obj = results[0]
        XCTAssertEqual("def", obj as? String)
    }
    
    // MARK:- Startup
    
    func testAcExecuteWhenStarted() {

        let callback = self.expectationWithDescription("startUpBlockCalled")

        super.setupRealContext()

        AcExecuteWhenStarted {() -> Void in
            callback.fulfill()
        }

        super.startContextWithClasses([])

        self.waitForExpectationsWithTimeout(1.0 as NSTimeInterval, handler: nil)
    }
    
    // MARK:- Boxing
    
    func testObjcBoxString() {
        let s = objcBox("abc")
        XCTAssertTrue(s is NSString)
    }
    
    
}
