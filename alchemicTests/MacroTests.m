//
//  MacroTests.m
//  alchemic
//
//  Created by Derek Clarkson on 18/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <Alchemic/Alchemic.h>

@interface MacroTests : XCTestCase

@end

@implementation MacroTests

-(void) testAcValueWithValue {
    ALCConstantValue *value = AcValue(@12);
    XCTAssertEqualObjects(@12, value.value);
}

-(void) testAcValueWithNil {
    ALCConstantValue *value = AcValue(nil);
    XCTAssertEqualObjects([NSNull null], value.value);
}

@end
