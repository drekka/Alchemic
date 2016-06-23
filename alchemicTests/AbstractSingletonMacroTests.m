//
//  AbstractSingletonMacroTests.m
//  alchemic
//
//  Created by Derek Clarkson on 20/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;

@interface AbstractSingletonMacroTests : XCTestCase

@end

@implementation AbstractSingletonMacroTests

-(void) testUniqueMacrosDontUseSameSingleton {
    id weakMacro = [ALCIsWeak macro];
    id referenceMacro = [ALCIsReference macro];
    XCTAssertNotNil(weakMacro);
    XCTAssertNotNil(referenceMacro);
    XCTAssertNotEqual(weakMacro, referenceMacro);
}
@end
