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

#pragma mark - NSNumber -> scalars

#define testNSNumberMapping(testName, fromTestValue, toTestType, expectedValue) \
-(void) test ## testName { \
ALCValue *toValue = [self valueFromValueOfType:ALCValueTypeObject value:fromTestValue encoding:@encode(toTestType)]; \
toTestType result; \
[toValue.value getValue:&result]; \
XCTAssertEqual(expectedValue, result); \
}

testNSNumberMapping(NSNumberToBool, [NSNumber numberWithBool:YES], BOOL, YES)
testNSNumberMapping(NSNumberToInt, @5, int, 5)
testNSNumberMapping(NSNumberToLong, @5, long, 5)
testNSNumberMapping(NSNumberToLongLong, @5, long long, 5)
testNSNumberMapping(NSNumberToUnsignedInt, @5, unsigned int, 5u)
testNSNumberMapping(NSNumberToUnsignedLong, @5, unsigned long, 5u)
testNSNumberMapping(NSNumberToUnsignedLongLong, @5, unsigned long long, 5u)
testNSNumberMapping(NSNumberToShort, @5, short, 5)
testNSNumberMapping(NSNumberToUnsignedShort, @5,unsigned short, 5u)

#define testDecimalNSNumberMapping(testName, fromTestValue, toTestType, expectedValue, accuracy) \
-(void) test ## testName { \
ALCValue *toValue = [self valueFromValueOfType:ALCValueTypeObject value:fromTestValue encoding:@encode(toTestType)]; \
toTestType result; \
[toValue.value getValue:&result]; \
XCTAssertEqualWithAccuracy(expectedValue, result, accuracy); \
}

testDecimalNSNumberMapping(NSNumberToDouble, @5.12345678, double, 5.12345678, 0.00000001)
testDecimalNSNumberMapping(NSNumberToFloat, @5.1234, float, 5.1234, 0.0001)

#pragma mark - From scalars

-(void) testBoolToBool {
    BOOL value = YES;
    NSValue *nsValue = [NSValue value:&value withObjCType:@encode(BOOL)];
    ALCValue *toValue = [self mapValue:nsValue encoding:@encode(BOOL) toEncoding:@encode(BOOL)];
    BOOL resultValue;
    [(NSValue *) toValue.value getValue:&resultValue];
    XCTAssertTrue(resultValue);
}

-(void) testIntToInt {
    int value = 5;
    NSValue *nsValue = [NSValue value:&value withObjCType:@encode(int)];
    ALCValue *toValue = [self mapValue:nsValue encoding:@encode(int) toEncoding:@encode(int)];
    int resultValue;
    [(NSValue *) toValue.value getValue:&resultValue];
    XCTAssertEqual(resultValue, 5);
}

#pragma mark - From arrays

-(void) testArrayToObjectWithoutClass {
    ALCType *arrayType = [ALCType typeWithClass:[NSArray class]];
    ALCValue *fromValue = [ALCValue withType:arrayType value:@[@"abc"] completion:NULL];
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeWithEncoding:@encode(NSString *)] error:&error];
    XCTAssertEqualObjects(@"abc", toValue.value);
}

-(void) testArrayToObjectWithClass {
    ALCType *arrayType = [ALCType typeWithClass:[NSArray class]];
    ALCValue *fromValue = [ALCValue withType:arrayType value:@[@"abc"] completion:NULL];
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeWithClass:[NSString class]] error:&error];
    XCTAssertEqualObjects(@"abc", toValue.value);
}

-(void) testArrayToObjectWhenZeroValues {
    ALCType *arrayType = [ALCType typeWithClass:[NSArray class]];
    ALCValue *fromValue = [ALCValue withType:arrayType value:@[] completion:NULL];
    ALCValue *toValue = [self map:fromValue toType:[ALCType typeWithClass:[NSString class]]];
    XCTAssertEqual([NSNull null], toValue.value);
}

-(void) testArrayToObjectWhenTooManyValuesError {
    ALCType *arrayType = [ALCType typeWithClass:[NSArray class]];
    ALCValue *fromValue = [ALCValue withType:arrayType value:@[@"abc", @"def", @"ghi"] completion:NULL];
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeWithClass:[NSString class]] error:&error];
    XCTAssertNil(toValue);
    XCTAssertEqualObjects(@"Too many values. Expected 1 NSString value.", error.localizedDescription);
}

#pragma mark - Object -> Object

-(void) testObjectToObjectWhenSameType {
    ALCType *toType = [ALCType typeWithClass:[NSNumber class]];
    ALCValue *fromValue = [ALCValue withValueType:ALCValueTypeObject value:@5 completion:NULL];
    ALCValue *value = [self map:fromValue toType:toType];
    XCTAssertEqual(fromValue, value);
}

-(void) testObjectToObjectWhenMappingToSubclassIfActuallySameClass {
    ALCType *toType = [ALCType typeWithClass:[NSMutableString class]];
    ALCValue *fromValue = [ALCValue withValueType:ALCValueTypeObject value:[@"abc" mutableCopy] completion:NULL];
    ALCValue *value = [self map:fromValue toType:toType];
    XCTAssertEqualObjects(@"abc", value.value);
}

-(void) testObjectToObjectWhenMappingToSubclass {
    ALCType *toType = [ALCType typeWithClass:[NSMutableString class]];
    NSString *abc = [NSString stringWithCString:"abc" encoding:NSUTF8StringEncoding]; // Constants are decended from mutables. So use this instead.
    ALCValue *fromValue = [ALCValue withValueType:ALCValueTypeObject value:abc completion:NULL];
    [self map:fromValue toType:toType withError:@"Cannot convert a NSTaggedPointerString to a NSMutableString"];
}

#pragma mark - Internal

-(ALCValue *) mapValue:(id) value encoding:(const char *) fromEncoding toEncoding:(const char *) toEncoding {
    ALCType *fromType = [ALCType typeWithEncoding:fromEncoding];
    ALCValue *fromValue = [ALCValue withType:fromType value:value completion:NULL];
    ALCType *toType = [ALCType typeWithEncoding:toEncoding];
    return [self map:fromValue toType:toType];
}

-(ALCValue *) valueFromValueOfType:(ALCValueType) type value:(id) value encoding:(const char *) encoding {
    ALCValue *fromValue = [ALCValue withValueType:type value:value completion:NULL];
    return [self map:fromValue toType:[ALCType typeWithEncoding:encoding]];
}

-(ALCValue *) map:(ALCValue *) fromValue toType:(ALCType *) toType {
    NSError *error;
    ALCValue *value = [fromValue mapTo:toType error:&error];
    XCTAssertNotNil(value);
    XCTAssertNil(error);
    return value;
}

-(void) map:(ALCValue *) fromValue toType:(ALCType *) toType withError:(NSString *) errorMsg {
    NSError *error;
    ALCValue *value = [fromValue mapTo:toType error:&error];
    XCTAssertNil(value);
    XCTAssertEqualObjects(errorMsg, error.localizedDescription);
}

@end
