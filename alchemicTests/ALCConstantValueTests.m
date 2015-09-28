//
//  ALCConstantValueTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCConstantValue.h"

@import XCTest;

@interface ALCConstantValueTests : XCTestCase

@end

@implementation ALCConstantValueTests

-(void) testFactoryMethod {
	ALCConstantValue *value = [ALCConstantValue constantValue:@5];
	XCTAssertEqualObjects(@5, value.value);
}

-(void) testWithNil {
    ALCConstantValue *value = [ALCConstantValue constantValue:nil];
    XCTAssertEqualObjects([NSNull null], value.value);
}

-(void) testDescriptionWithString {
    ALCConstantValue *value = [ALCConstantValue constantValue:@"abc"];
    XCTAssertEqualObjects(@"AcValue:abc", [value description]);
}

-(void) testDescriptionWithNumber {
    ALCConstantValue *value = [ALCConstantValue constantValue:@12];
    XCTAssertEqualObjects(@"AcValue:12", [value description]);
}
@end
