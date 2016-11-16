//
//  ALCTypeExtensionTests.swift
//  alchemic
//
//  Created by Derek Clarkson on 11/11/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

import XCTest
@testable import Alchemic

class ALCTypeExtensionTests: XCTestCase {

    func testBool() {
        let type:ALCType = ALCType.bool;
        XCTAssertEqual(.bool, type.type)
    }

    func testChar() {
        let type:ALCType = ALCType.char;
        XCTAssertEqual(.char, type.type)
    }

    func testCharPointer() {
        let type:ALCType = ALCType.charPointer;
        XCTAssertEqual(.charPointer, type.type)
    }

    func testInt() {
        let type:ALCType = ALCType.int;
        XCTAssertEqual(.int, type.type)
    }

    func testFloat() {
        let type:ALCType = ALCType.float;
        XCTAssertEqual(.float, type.type)
    }

    func testDouble() {
        let type:ALCType = ALCType.double;
        XCTAssertEqual(.double, type.type)
    }

    func testLong() {
        let type:ALCType = ALCType.long;
        XCTAssertEqual(.long, type.type)
    }

    func testLongLong() {
        let type:ALCType = ALCType.longLong;
        XCTAssertEqual(.longLong, type.type)
    }

    func testShort() {
        let type:ALCType = ALCType.short;
        XCTAssertEqual(.short, type.type)
    }

    func testUnsignedChar() {
        let type:ALCType = ALCType.unsignedChar;
        XCTAssertEqual(.unsignedChar, type.type)
    }

    func testUnsignedShort() {
        let type:ALCType = ALCType.unsignedShort;
        XCTAssertEqual(.unsignedShort, type.type)
    }

    func testUnsignedInt() {
        let type:ALCType = ALCType.unsignedInt;
        XCTAssertEqual(.unsignedInt, type.type)
    }

    func testUnsignedLong() {
        let type:ALCType = ALCType.unsignedLong;
        XCTAssertEqual(.unsignedLong, type.type)
    }

    func testUnsignedLongLong() {
        let type:ALCType = ALCType.unsignedLongLong;
        XCTAssertEqual(.unsignedLongLong, type.type)
    }

    func testCGPoint() {
        let type:ALCType = ALCType.cgPoint;
        XCTAssertEqual(.cgPoint, type.type)
    }

    func testCGSize() {
        let type:ALCType = ALCType.cgSize;
        XCTAssertEqual(.cgSize, type.type)
    }

    func testCGRect() {
        let type:ALCType = ALCType.cgRect;
        XCTAssertEqual(.cgRect, type.type)
    }

}
