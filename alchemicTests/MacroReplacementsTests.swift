//
//  MacroTests.swift
//  AlchemicSwift
//
//  Created by Derek Clarkson on 24/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import AlchemicSwift
import ObjectiveC

class MacroReplementsTests: XCTestCase {

    override func setUp() {

        // Ensure Alchemic is up
        let startedExpectation = self.expectation(description: "alchemic up")
        AcWhenReady({ () in
            startedExpectation.fulfill()
        })

        self.waitForExpectations(timeout: 2.0, handler: nil)

    }

    // MARK:- Registration

    func testAcRegister() {
        let singleton:Singleton = AcGet()!
        XCTAssertNotNil(singleton)
    }

    func testAcInitializer() {
        let singleton:SingletonWithInit = AcGet()!
        XCTAssertNotNil(singleton)
        XCTAssertEqual("abc", singleton.aString)
    }

    func testAcMethod() {
        let singleton:ClassWithString = AcGet(AcName("acMethod"))!
        XCTAssertNotNil(singleton)
        XCTAssertEqual("abc", singleton.aString)
    }

    // MARK:- Injecting

    func testAcInject() {
        let singleton:SingletonWithInjection = AcGet()!
        XCTAssertNotNil(singleton.singleton)
    }

    // MARK:- Configuring

    func testAcFactoryName() {
        let singleton:SingletonWithName = AcGet(AcName("singleton"))!
        XCTAssertNotNil(singleton)
        XCTAssertTrue(singleton.isKind(of: SingletonWithName.self))
    }

    func testAcTemplate() {
        let t1:Template = AcGet()!
        let t2:Template = AcGet()!
        XCTAssertEqual(1, t1.counter)
        XCTAssertEqual(2, t2.counter)
    }

    func testAcPrimary() {
        let singleton:NSObject = AcGet(AcProtocol(PrimaryProtocol.self))!
        XCTAssertNotNil(singleton)
        XCTAssertTrue(singleton.isKind(of: PrimarySingleton.self))
    }

    func testAcReference() {
        let reference = Reference()
        AcSet(reference, AcClass(Reference.self))
        let returnedReference:Reference = AcGet()!
        XCTAssertNotNil(returnedReference)
        XCTAssertTrue(returnedReference.isKind(of: Reference.self))
    }

    func testAcReferenceThrows() {
        XCTAssertThrowsError(
            try ExceptionCatcher.catchException({ () in
                let _:Reference = AcGet()!
            }),
            "Error not thrown",
            { (error:Error) in
                XCTAssertEqual("Reference is a reference factory which has not had a value set.", error.localizedDescription)
            }
        )
    }

    func testAcNillable() {
        let returnedReference:NillableReference? = AcGet()
        XCTAssertNil(returnedReference)
    }

    func testAcWeak() {
        // Create and set inside an autorelease pool so it can be released.
        autoreleasepool {
            let newRef = WeakReference()
            AcSet(newRef, AcClass(WeakReference.self))
            let returnedRef:WeakReference? = AcGet()
            XCTAssertNotNil(returnedRef)
        }

        // Once the pool has exited, the refernece factory should be nil.
        let nilRef:WeakReference? = AcGet()
        XCTAssertNil(nilRef)
    }

    func testAcTransient() {

        // Initially dependency will be nil
        let singleton:SingletonWithTransient = AcGet()!
        var ref:TransientReference? = singleton.transientDep
        XCTAssertNil(ref)

        // After setting reference
        let newRef = TransientReference()
        AcSet(newRef, AcClass(TransientReference.self))

        // Injection should be updated.
        ref = singleton.transientDep
        XCTAssertNotNil(ref)
        XCTAssertEqual(newRef, ref)

        // And update again just to be sure.
        let newRef2 = TransientReference()
        AcSet(newRef2, AcClass(TransientReference.self))

        // Injection should be updated.
        ref = singleton.transientDep
        XCTAssertNotNil(ref)
        XCTAssertEqual(newRef2, ref)
    }

    func testAcArg() {
        let singleton:ClassWithString = AcGet(AcName("acMethodWithAcArg"))!
        XCTAssertNotNil(singleton)
        XCTAssertEqual("def", singleton.aString)
    }

    // MARK:- Accessing

    func testAcGet() {
        let singleton:Singleton = AcGet()!
        XCTAssertNotNil(singleton)
    }

    func testAcSet() {
        let reference = Reference()
        AcSet(reference, AcClass(Reference.self))
        let returnedReference:Reference = AcGet()!
        XCTAssertNotNil(returnedReference)
        XCTAssertTrue(returnedReference.isKind(of:Reference.self))
    }

    // MARK:- Dependencies

    func testAcInjectDependencies() {
        let singleton = SingletonWithInjection()
        AcInjectDependencies(singleton)
        XCTAssertNotNil(singleton.singleton)
        XCTAssertEqual(5, singleton.aInt)
    }

    // MARK:- Lifecycle

    func testAcWhenReady() {
        var blockExcuted = false
        AcWhenReady { // Should execute immediately.
            blockExcuted = true
        }
        XCTAssertTrue(blockExcuted)
    }

    // MARK:- Searching

    func testAcClass() {
        let singletons:NSArray = AcGet(AcClass(ClassWithString.self))!
        XCTAssertNotNil(singletons)
        XCTAssertEqual(2, singletons.count)
    }

    func testAcProtocol() {
        let singleton:NSObject = AcGet(AcProtocol(PrimaryProtocol.self))!
        XCTAssertNotNil(singleton)
        XCTAssertTrue(singleton.isKind(of: PrimarySingleton.self))
    }

    func testAcName() {
        let singleton:ClassWithString = AcGet(AcName("acMethod"))!
        XCTAssertNotNil(singleton)
        XCTAssertEqual("abc", singleton.aString)
    }

    // MARK:- Features

    func testAcEnableUserDefaults() {
        let userDefaults:ALCUserDefaults = AcGet()!
        XCTAssertNotNil(userDefaults)
    }

    func testAcEnabledCloudKeyValueStore() {
        let cloudStore:ALCCloudKeyValueStore = AcGet()!
        XCTAssertNotNil(cloudStore)
    }

    // MARK:- Blocks

    func testAcWeakSelf() {
        // No easy way to test this. Assume works because rest of code works.
    }

    func testAcStrongSelf() {
        // No easy way to test this. Assume works because rest of code works.
    }

    // Swift variable injections

    func testInjectionString() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual("abc", singleton.aString)
    }
    
    // MARK:- C scalar variable injections

    func testInjectionBool() {
        let singleton:Injections = AcGet()!
        XCTAssertTrue(singleton.aBool)
    }

    func testInjectionChar() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aChar)
    }

    func testInjectionDouble() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(1.2345, singleton.aDouble)
    }

    func testInjectionFloat() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(1.2345, singleton.aFloat)
    }

    func testInjectionInt() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aInt)
    }

    func testInjectionLong() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aLong)
    }

    func testInjectionLongLong() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aLongLong)
    }

    func testInjectionShort() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aShort)
    }
    
    func testInjectionUnsignedChar() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aUChar)
    }

    func testInjectionUnsignedInt() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aUInt)
    }

    func testInjectionUnsignedLong() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aULong)
    }
    
    func testInjectionUnsignedLongLong() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aULongLong)
    }

    func testInjectionUnsignedShort() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(5, singleton.aUShort)
    }
    
    // MARK:- C struct injections

    func testInjectionSize() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(CGSize(width: 1.0, height: 2.0), singleton.size)
    }

    func testInjectionPoint() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(CGPoint(x: 1.0, y: 2.0), singleton.point)
    }

    func testInjectionRect() {
        let singleton:Injections = AcGet()!
        XCTAssertEqual(CGRect(x: 1.0, y: 2.0, width:3.0, height:4.0), singleton.rect)
    }

    // MARK:- Test support
    
    fileprivate func mainContext() -> ALCContext {
        return Alchemic.mainContext()
    }
    
}
