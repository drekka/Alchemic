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

#pragma mark - NSNumber ->

#define testMapping(testName, fromTestType, fromTestValue, toTestType, toTestValue) \
-(void) test ## testName { \
ALCType *type = [ALCType typeWithEncoding:@encode(fromTestType)]; \
ALCValue *fromValue = [type withValue:fromTestValue completion:NULL]; \
ALCValue *toValue = [self map:fromValue toType:[ALCType typeWithEncoding:@encode(toTestType)]]; \
toTestType result; \
[toValue.value getValue:&result]; \
XCTAssertEqual(toTestValue, result); \
}

testMapping(NSNumberToBool, NSNumber *, [NSNumber numberWithBool:YES], BOOL, YES)
testMapping(NSNumberToInt, NSNumber *, @5, int, 5)
testMapping(NSNumberToLong, NSNumber *, @5, long, 5)
testMapping(NSNumberToLongLong, NSNumber *, @5, long long, 5)
testMapping(NSNumberToUnsignedInt, NSNumber *, @5, unsigned int, 5u)
testMapping(NSNumberToUnsignedLong, NSNumber *, @5, unsigned long, 5u)
testMapping(NSNumberToUnsignedLongLong, NSNumber *, @5, unsigned long long, 5u)
testMapping(NSNumberToShort, NSNumber *, @5, short, 5)
testMapping(NSNumberToUnsignedShort, NSNumber *, @5,unsigned short, 5u)

#define testDecimalMapping(testName, fromTestType, fromTestValue, toTestType, toTestValue, accuracy) \
-(void) test ## testName { \
ALCType *type = [ALCType typeWithEncoding:@encode(fromTestType)]; \
ALCValue *fromValue = [type withValue:fromTestValue completion:NULL]; \
ALCValue *toValue = [self map:fromValue toType:[ALCType typeWithEncoding:@encode(toTestType)]]; \
toTestType result; \
[toValue.value getValue:&result]; \
XCTAssertEqualWithAccuracy(toTestValue, result, accuracy); \
}

-(void) testArrayToObject {
    ALCType *arrayType = [ALCType typeWithClass:[NSArray class]];
    ALCValue *fromValue = [arrayType withValue:@[@"abc"] completion:NULL];
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeWithClass:[NSString class]] error:&error];
    XCTAssertEqualObjects(@"abc", toValue.value);
    XCTAssertNil(error);
}

-(void) testArrayToObjectWhenZeroValues {
    ALCType *arrayType = [ALCType typeWithClass:[NSArray class]];
    ALCValue *fromValue = [arrayType withValue:@[] completion:NULL];
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeWithClass:[NSString class]] error:&error];
    XCTAssertEqual([NSNull null], toValue.value);
    XCTAssertNil(error);
}

-(void) testArrayToObjectWhenTooManyValues {
    ALCType *arrayType = [ALCType typeWithClass:[NSArray class]];
    ALCValue *fromValue = [arrayType withValue:@[@"abc", @"def", @"ghi"] completion:NULL];
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeWithClass:[NSString class]] error:&error];
    XCTAssertNil(toValue);
    XCTAssertEqualObjects(@"Too many values. Expected 1 NSString value.", error.localizedDescription);
}

testDecimalMapping(NSNumberToDouble, NSNumber *, @5.12345678, double, 5.12345678, 0.00000001)
testDecimalMapping(NSNumberToFloat, NSNumber *, @5.1234, float, 5.1234, 0.0001)

#pragma mark - Internal

-(ALCValue *) map:(ALCValue *) fromValue toType:(ALCType *) toType {
    NSError *error;
    ALCValue *value = [fromValue mapTo:toType error:&error];
    XCTAssertNotNil(value);
    XCTAssertNil(error);
    return value;
}

@end
