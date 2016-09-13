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
ALCValue *toValue = [self mapValue:fromTestValue toEncoding:@encode(toTestType)]; \
toTestType result; \
[(NSValue *) toValue.value getValue:&result]; \
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
ALCValue *toValue = [self mapValue:fromTestValue toEncoding:@encode(toTestType)]; \
toTestType result; \
[toValue.value getValue:&result]; \
XCTAssertEqualWithAccuracy(expectedValue, result, accuracy); \
}

testDecimalNSNumberMapping(NSNumberToDouble, @5.12345678, double, 5.12345678, 0.00000001)
testDecimalNSNumberMapping(NSNumberToFloat, @5.1234, float, 5.1234, 0.0001)

#pragma mark - From scalars

#define testScalarMapping(fromName, fromType, toName, toType, scalarValue, assertion) \
-(void) test ## fromName ## To ## toName { \
    fromType value = scalarValue; \
    NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(fromType)]; \
    ALCValue *toValue = [self mapValue:nsValue toEncoding:@encode(toType)]; \
    toType resultValue; \
    [(NSValue *) toValue.value getValue:&resultValue]; \
    assertion; \
}

#define testScalarMappingFailure(fromName, fromType, toName, toType, scalarValue, msg) \
-(void) test ## fromName ## To ## toName { \
fromType value = scalarValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(fromType)]; \
[self mapValue:nsValue toEncoding:@encode(toType) withError:msg]; \
}

testScalarMapping(Bool, BOOL, Bool, BOOL, YES, XCTAssertTrue(resultValue))
testScalarMappingFailure(Bool, BOOL, Int, int, YES, @"Unable to convert a scalar BOOL to a scalar int")
testScalarMappingFailure(Bool, BOOL, Long, long, YES, @"Unable to convert a scalar BOOL to a scalar long long")

testScalarMapping(Int, int, Int, int, 5, XCTAssertEqual(5, resultValue))
testScalarMapping(Int, int, Long, long, 5, XCTAssertEqual(5l, resultValue))
testScalarMapping(Int, int, LongLong, long long, 5, XCTAssertEqual(5ll, resultValue))
testScalarMapping(Int, int, Float, float, 5, XCTAssertEqual(5.0f, resultValue))
testScalarMapping(Int, int, Double, double, 5, XCTAssertEqual(5.0, resultValue))
testScalarMapping(Int, int, Short, short, 5, XCTAssertEqual(5, resultValue))
testScalarMappingFailure(Int, int, Char, char, 5, @"Unable to convert a scalar int to a scalar char")
testScalarMapping(Int, int, UnsignedInt, unsigned int, 5, XCTAssertEqual(5u, resultValue))
testScalarMapping(Int, int, UnsignedLong, unsigned long, 5, XCTAssertEqual(5lu, resultValue))
testScalarMapping(Int, int, UnsignedLongLong, unsigned long long, 5, XCTAssertEqual(5llu, resultValue))
testScalarMapping(Int, int, UnsignedShort, unsigned short, 5, XCTAssertEqual(5, resultValue))

#pragma mark - From arrays

-(void) testArrayToObjectWithoutClass {
    ALCValue *fromValue = [ALCValue withValue:@[@"abc"] completion:NULL];
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeWithEncoding:@encode(NSString *)] error:&error];
    XCTAssertEqualObjects(@"abc", toValue.value);
}

-(void) testArrayToObjectWithClass {
    ALCValue *fromValue = [ALCValue withValue:@[@"abc"] completion:NULL];
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeWithClass:[NSString class]] error:&error];
    XCTAssertEqualObjects(@"abc", toValue.value);
}

-(void) testArrayToObjectWhenZeroValues {
    ALCValue *fromValue = [ALCValue withValue:@[] completion:NULL];
    ALCValue *toValue = [self map:fromValue toType:[ALCType typeWithClass:[NSString class]]];
    XCTAssertEqual([NSNull null], toValue.value);
}

-(void) testArrayToObjectWhenTooManyValuesError {
    ALCValue *fromValue = [ALCValue withValue:@[@"abc", @"def", @"ghi"] completion:NULL];
    NSError *error;
    ALCValue *toValue = [fromValue mapTo:[ALCType typeWithClass:[NSString class]] error:&error];
    XCTAssertNil(toValue);
    XCTAssertEqualObjects(@"Too many values. Expected 1 NSString value.", error.localizedDescription);
}

#pragma mark - Object -> Object

-(void) testObjectToObjectWhenSameType {
    ALCValue *fromValue = [ALCValue withValue:@5 completion:NULL];
    ALCValue *value = [self map:fromValue toType:[ALCType typeWithClass:[NSNumber class]]];
    XCTAssertEqual(fromValue, value);
}

-(void) testObjectToObjectWhenMappingToSubclassIfActuallySameClass {
    ALCValue *fromValue = [ALCValue withValue:[@"abc" mutableCopy] completion:NULL];
    ALCValue *value = [self map:fromValue toType:[ALCType typeWithClass:[NSMutableString class]]];
    XCTAssertEqualObjects(@"abc", value.value);
}

-(void) testObjectToObjectWhenMappingToSubclass {
    ALCType *toType = [ALCType typeWithClass:[NSMutableString class]];
    NSString *abc = [NSString stringWithCString:"abc" encoding:NSUTF8StringEncoding]; // Constants are decended from mutables. So use this instead.
    ALCValue *fromValue = [ALCValue withValue:abc completion:NULL];
    [self map:fromValue toType:toType withError:@"Cannot convert a NSTaggedPointerString to a NSMutableString"];
}

#pragma mark - Internal

-(ALCValue *) mapValue:(id) value toEncoding:(const char *) toEncoding {
    ALCValue *fromValue = [ALCValue withValue:value completion:NULL];
    ALCType *toType = [ALCType typeWithEncoding:toEncoding];
    return [self map:fromValue toType:toType];
}

-(void) mapValue:(id) value toEncoding:(const char *) toEncoding withError:(NSString *) errorMsg {
    ALCValue *fromValue = [ALCValue withValue:value completion:NULL];
    ALCType *toType = [ALCType typeWithEncoding:toEncoding];
    return [self map:fromValue toType:toType withError:errorMsg];
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
