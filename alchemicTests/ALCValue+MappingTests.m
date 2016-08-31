//
//  ALCValue+MappingTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface ALCValue_MappingTests : XCTestCase

@end

@implementation ALCValue_MappingTests

-(void) testNSNumberToInt {
    
    ALCType *type = [ALCType typeWithEncoding:@encode(NSNumber *)];
    ALCValue *fromValue = [type withValue:[NSValue valueWithNonretainedObject:@5] completion:NULL];
    
    ALCValue *toValue = [self map:fromValue toType:[ALCType typeWithEncoding:"i"]];
    XCTAssertNotNil(toValue);
    
    int result;
    [toValue.value getValue:&result];
    XCTAssertEqual(5, result);
}

-(ALCValue *) map:(ALCValue *) fromValue toType:(ALCType *) toType {
    NSError *error;
    ALCValue *value = [fromValue mapTo:toType error:&error];
    XCTAssertNil(error);
    return value;
}


@end
