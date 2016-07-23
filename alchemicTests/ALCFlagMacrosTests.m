//
//  AbstractSingletonMacroTests.m
//  alchemic
//
//  Created by Derek Clarkson on 20/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;

@interface ALCFlagMacrosTests : XCTestCase
@end

@implementation ALCFlagMacrosTests

-(void) testWeakMacro {
    XCTAssertNotNil([ALCIsWeak macro]);
    XCTAssertEqual([ALCIsWeak macro],[ALCIsWeak macro]);
}

-(void) testReferenceMacro {
    XCTAssertNotNil([ALCIsReference macro]);
    XCTAssertEqual([ALCIsReference macro],[ALCIsReference macro]);
}

-(void) testPrimaryMacro {
    XCTAssertNotNil([ALCIsPrimary macro]);
    XCTAssertEqual([ALCIsPrimary macro],[ALCIsPrimary macro]);
}

-(void) testTemplateMacro {
    XCTAssertNotNil([ALCIsTemplate macro]);
    XCTAssertEqual([ALCIsTemplate macro],[ALCIsTemplate macro]);
}

-(void) testNillableMacro {
    XCTAssertNotNil([ALCIsNillable macro]);
    XCTAssertEqual([ALCIsNillable macro],[ALCIsNillable macro]);
}

-(void) testTransientMacro {
    XCTAssertNotNil([ALCIsTransient macro]);
    XCTAssertEqual([ALCIsTransient macro],[ALCIsTransient macro]);
}

-(void) testMacrosAllDifferent {
    NSUInteger hashWeak = [ALCIsWeak macro].hash;
    NSUInteger hashReference = [ALCIsReference macro].hash;
    NSUInteger hashPrimary = [ALCIsPrimary macro].hash;
    NSUInteger hashTemplate = [ALCIsTemplate macro].hash;
    NSUInteger hashNillable = [ALCIsNillable macro].hash;
    NSUInteger hashTransient = [ALCIsTransient macro].hash;
    XCTAssertNotEqual(hashWeak, hashReference);
    XCTAssertNotEqual(hashWeak, hashPrimary);
    XCTAssertNotEqual(hashWeak, hashTemplate);
    XCTAssertNotEqual(hashWeak, hashNillable);
    XCTAssertNotEqual(hashWeak, hashTransient);
}

@end
