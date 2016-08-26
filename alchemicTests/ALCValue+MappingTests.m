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
    ALCValue *number = [ALCValue value:[NSValue valueWithNonretainedObject:@5] withEncoding:"@"];
    ALCValue *toInt = [ALCValue valueWithEncoding:"i"];
    [self performMapping:number toValue:toInt];
    int result;
    [toInt.value getValue:&result];
    XCTAssertEqual(5, result);
}

-(void) performMapping:(ALCValue *) fromValue toValue:(ALCValue *) toValue {
    NSError *error;
    [fromValue mapInTo:toValue error:&error];
    XCTAssertNil(error);
}


@end
