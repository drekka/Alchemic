//
//  ALCConstantValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 3/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface ALCConstantValueSourceTests : XCTestCase

@end

@implementation ALCConstantValueSourceTests

-(void) testConstantInt {
    id<ALCValueSource> source = AcInt(5);
    NSError *error;
    ALCValue *alcValue = [source valueWithError:&error];
    XCTAssertNotNil(alcValue);
    XCTAssertNil(error);
    NSValue *result = alcValue.value;
    int finalValue;
    [result getValue:&finalValue];
    XCTAssertEqual(5, finalValue);
}

@end
