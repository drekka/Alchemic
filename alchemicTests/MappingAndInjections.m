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

    Ivar intVar = class_getInstanceVariable([self class], "_aInt");

    ALCValue *fromValue = [ALCValue value:[NSValue valueWithNonretainedObject:@5] withEncoding:@encode(NSNumber *)];
    ALCValue *toValue = [ALCValue valueWithEncoding:ivar_getTypeEncoding(intVar)];

    NSError *error;
    XCTAssertTrue([fromValue mapInTo:toValue error:&error]);
    XCTAssertNil(error);

    [toValue variableInjector](self, intVar);

    XCTAssertEqual(5, _aInt);
}

@end
