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
-(void) testNSNumberTo ## testName { \
ALCValue *toValue = [self mapValue:fromTestValue toEncoding:@encode(toTestType)]; \
toTestType result; \
[(NSValue *) toValue.value getValue:&result]; \
XCTAssertEqual(expectedValue, result); \
}

#define testDecimalNSNumberMapping(testName, fromTestValue, toTestType, expectedValue, accuracy) \
-(void) testNSNumberTo ## testName { \
ALCValue *toValue = [self mapValue:fromTestValue toEncoding:@encode(toTestType)]; \
toTestType result; \
[toValue.value getValue:&result]; \
XCTAssertEqualWithAccuracy(expectedValue, result, accuracy); \
}

testNSNumberMapping(Bool, [NSNumber numberWithBool:YES], BOOL, YES)
testNSNumberMapping(Int, @5, int, 5)
testNSNumberMapping(Long, @5, long, 5)
testNSNumberMapping(LongLong, @5, long long, 5)
testNSNumberMapping(UnsignedInt, @5, unsigned int, 5u)
testNSNumberMapping(UnsignedLong, @5, unsigned long, 5u)
testNSNumberMapping(UnsignedLongLong, @5, unsigned long long, 5u)
testNSNumberMapping(Short, @5, short, 5)
testNSNumberMapping(UnsignedShort, @5,unsigned short, 5u)
testDecimalNSNumberMapping(Double, @5.12345678, double, 5.12345678, 0.00000001)
testDecimalNSNumberMapping(Float, @5.1234, float, 5.1234, 0.0001)

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

#define testScalarToObjectMapping(fromName, fromScalarType, scalarValue) \
-(void) test ## fromName ## ToObject { \
fromScalarType value = scalarValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(fromScalarType)]; \
ALCValue *fromValue = [ALCValue withValue:nsValue completion:NULL]; \
ALCValue *toValue = [self map:fromValue toType:[ALCType typeWithClass:[NSNumber class]]]; \
NSNumber *number = toValue.value; \
XCTAssertEqualObjects(@(scalarValue), number); \
}

#define testScalarToArrayMapping(fromName, fromScalarType, scalarValue) \
-(void) test ## fromName ## ToArray { \
fromScalarType value = scalarValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(fromScalarType)]; \
ALCValue *fromValue = [ALCValue withValue:nsValue completion:NULL]; \
ALCValue *toValue = [self map:fromValue toType:[ALCType typeWithClass:[NSArray class]]]; \
NSArray *results = toValue.value; \
XCTAssertEqual(1u, results.count); \
XCTAssertEqualObjects(@(scalarValue), results[0]); \
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
testScalarMappingFailure(Bool, BOOL, LongLong, long long, YES, @"Unable to convert a scalar BOOL to a scalar long long")
testScalarMappingFailure(Bool, BOOL, Float, float, YES, @"Unable to convert a scalar BOOL to a scalar float")
testScalarMappingFailure(Bool, BOOL, Double, double, YES, @"Unable to convert a scalar BOOL to a scalar double")
testScalarMappingFailure(Bool, BOOL, Short, short, YES, @"Unable to convert a scalar BOOL to a scalar short")
testScalarMappingFailure(Bool, BOOL, Char, signed char, YES, @"Unable to convert a scalar BOOL to a scalar char")
testScalarMappingFailure(Bool, BOOL, UnsignedInt, unsigned int, YES, @"Unable to convert a scalar BOOL to a scalar unsigned int")
testScalarMappingFailure(Bool, BOOL, UnsignedLong, unsigned long, YES, @"Unable to convert a scalar BOOL to a scalar unsigned long long")
testScalarMappingFailure(Bool, BOOL, UnsignedLongLong, unsigned long long, YES, @"Unable to convert a scalar BOOL to a scalar unsigned long long")
testScalarMappingFailure(Bool, BOOL, UnsignedShort, unsigned short, YES, @"Unable to convert a scalar BOOL to a scalar unsigned short")
testScalarMappingFailure(Bool, BOOL, CGSize, CGSize, YES, @"Unable to convert a scalar BOOL to a struct CGSize")
testScalarMappingFailure(Bool, BOOL, CGPoint, CGPoint, YES, @"Unable to convert a scalar BOOL to a struct CGPoint")
testScalarMappingFailure(Bool, BOOL, CGRect, CGRect, YES, @"Unable to convert a scalar BOOL to a struct CGRect")

testScalarMapping(Int, int, Int, int, 5, XCTAssertEqual(5, resultValue))
testScalarMapping(Int, int, Long, long, 5, XCTAssertEqual(5l, resultValue))
testScalarMapping(Int, int, LongLong, long long, 5, XCTAssertEqual(5ll, resultValue))
testScalarMapping(Int, int, Float, float, 5, XCTAssertEqual(5.0f, resultValue))
testScalarMapping(Int, int, Double, double, 5, XCTAssertEqual(5.0, resultValue))
testScalarMapping(Int, int, Short, short, 5, XCTAssertEqual(5, resultValue))
testScalarMappingFailure(Int, int, Char, signed char, 5, @"Unable to convert a scalar int to a scalar char")
testScalarMapping(Int, int, UnsignedInt, unsigned int, 5, XCTAssertEqual(5u, resultValue))
testScalarMapping(Int, int, UnsignedLong, unsigned long, 5, XCTAssertEqual(5lu, resultValue))
testScalarMapping(Int, int, UnsignedLongLong, unsigned long long, 5, XCTAssertEqual(5llu, resultValue))
testScalarMapping(Int, int, UnsignedShort, unsigned short, 5, XCTAssertEqual(5, resultValue))
testScalarMappingFailure(Int, int, CGSize, CGSize, 5, @"Unable to convert a scalar int to a struct CGSize")
testScalarMappingFailure(Int, int, CGPoint, CGPoint, 5, @"Unable to convert a scalar int to a struct CGPoint")
testScalarMappingFailure(Int, int, CGRect, CGRect, 5, @"Unable to convert a scalar int to a struct CGRect")
testScalarToObjectMapping(Int, int, 5)
testScalarToArrayMapping(Int, int, 5)

testScalarMapping(Double, double, Int, int, 4.5, XCTAssertEqual(5, resultValue))
testScalarMapping(Double, double, Long, long, 4.5, XCTAssertEqual(5l, resultValue))
testScalarMapping(Double, double, LongLong, long long, 4.5, XCTAssertEqual(5ll, resultValue))
testScalarMapping(Double, double, Float, float, 4.5, XCTAssertEqual(4.5f, resultValue))
testScalarMapping(Double, double, Double, double, 4.5, XCTAssertEqual(4.5, resultValue))
testScalarMapping(Double, double, Short, short, 4.5, XCTAssertEqual(5, resultValue))
testScalarMappingFailure(Double, double, Char, signed char, 4.5, @"Unable to convert a scalar double to a scalar char")
testScalarMapping(Double, double, UnsignedInt, unsigned int, 4.5, XCTAssertEqual(5u, resultValue))
testScalarMapping(Double, double, UnsignedLong, unsigned long, 4.5, XCTAssertEqual(5lu, resultValue))
testScalarMapping(Double, double, UnsignedLongLong, unsigned long long, 4.5, XCTAssertEqual(5llu, resultValue))
testScalarMapping(Double, double, UnsignedShort, unsigned short, 4.5, XCTAssertEqual(5, resultValue))
testScalarMappingFailure(Double, double, CGSize, CGSize, 4.5, @"Unable to convert a scalar double to a struct CGSize")
testScalarMappingFailure(Double, double, CGPoint, CGPoint, 4.5, @"Unable to convert a scalar double to a struct CGPoint")
testScalarMappingFailure(Double, double, CGRect, CGRect, 4.5, @"Unable to convert a scalar double to a struct CGRect")
testScalarToObjectMapping(Double, double, 4.5)
testScalarToArrayMapping(Double, double, 4.5)

testScalarMapping(Long, long, Int, int, 5, XCTAssertEqual(5, resultValue))
testScalarMapping(Long, long, Long, long, 5, XCTAssertEqual(5l, resultValue))
testScalarMapping(Long, long, LongLong, long long, 5, XCTAssertEqual(5ll, resultValue))
testScalarMapping(Long, long, Float, float, 5, XCTAssertEqual(5.0f, resultValue))
testScalarMapping(Long, long, Double, double, 5, XCTAssertEqual(5.0, resultValue))
testScalarMapping(Long, long, Short, short, 5, XCTAssertEqual(5, resultValue))
testScalarMappingFailure(Long, long, Char, signed char, 5, @"Unable to convert a scalar long long to a scalar char")
testScalarMapping(Long, long, UnsignedInt, unsigned int, 5, XCTAssertEqual(5u, resultValue))
testScalarMapping(Long, long, UnsignedLong, unsigned long, 5, XCTAssertEqual(5lu, resultValue))
testScalarMapping(Long, long, UnsignedLongLong, unsigned long long, 5, XCTAssertEqual(5llu, resultValue))
testScalarMapping(Long, long, UnsignedShort, unsigned short, 5, XCTAssertEqual(5, resultValue))
testScalarMappingFailure(Long, long, CGSize, CGSize, 5, @"Unable to convert a scalar long long to a struct CGSize")
testScalarMappingFailure(Long, long, CGPoint, CGPoint, 5, @"Unable to convert a scalar long long to a struct CGPoint")
testScalarMappingFailure(Long, long, CGRect, CGRect, 5, @"Unable to convert a scalar long long to a struct CGRect")
testScalarToObjectMapping(Long, long, 5)
testScalarToArrayMapping(Long, long, 5)

testScalarMapping(LongLong, long long, Int, int, 5, XCTAssertEqual(5, resultValue))
testScalarMapping(LongLong, long long, Long, long, 5, XCTAssertEqual(5l, resultValue))
testScalarMapping(LongLong, long long, LongLong, long long, 5, XCTAssertEqual(5ll, resultValue))
testScalarMapping(LongLong, long long, Float, float, 5, XCTAssertEqual(5.0f, resultValue))
testScalarMapping(LongLong, long long, Double, double, 5, XCTAssertEqual(5.0, resultValue))
testScalarMapping(LongLong, long long, Short, short, 5, XCTAssertEqual(5, resultValue))
testScalarMappingFailure(LongLong, long long, Char, signed char, 5, @"Unable to convert a scalar long long to a scalar char")
testScalarMapping(LongLong, long long, UnsignedInt, unsigned int, 5, XCTAssertEqual(5u, resultValue))
testScalarMapping(LongLong, long long, UnsignedLong, unsigned long, 5, XCTAssertEqual(5lu, resultValue))
testScalarMapping(LongLong, long long, UnsignedLongLong, unsigned long long, 5, XCTAssertEqual(5llu, resultValue))
testScalarMapping(LongLong, long long, UnsignedShort, unsigned short, 5, XCTAssertEqual(5, resultValue))
testScalarMappingFailure(LongLong, long long, CGSize, CGSize, 5, @"Unable to convert a scalar long long to a struct CGSize")
testScalarMappingFailure(LongLong, long long, CGPoint, CGPoint, 5, @"Unable to convert a scalar long long to a struct CGPoint")
testScalarMappingFailure(LongLong, long long, CGRect, CGRect, 5, @"Unable to convert a scalar long long to a struct CGRect")
testScalarToObjectMapping(LongLong, long long, 5)
testScalarToArrayMapping(LongLong, long long, 5)

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
