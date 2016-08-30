//
//  Injections.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import ObjectiveC;

@interface MappingAndInjections : XCTestCase

@end

@implementation MappingAndInjections {
    int _aInt;
}

-(void) testNSNumberToInt {

    ALCType *type = [ALCType typeWithEncoding:@encode(NSNumber *)];
    ALCValue *fromValue = [ALCValue valueWithType:type
                                            value:[NSValue valueWithNonretainedObject:@5]
                                       completion:NULL];

    Ivar intVar = class_getInstanceVariable([self class], "_aInt");
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeForIvar:intVar] error:&error];
    XCTAssertNotNil(toValue);
    XCTAssertNil(error);

    [toValue variableInjector](self, intVar);
    XCTAssertEqual(5, _aInt);
}

@end
