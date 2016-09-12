//
//  ALCAbtractTypeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import ObjectiveC;

@interface ALCAbtractTypeTests : XCTestCase
@end

@implementation ALCAbtractTypeTests

-(void) testStructNameFromEncoding {
    ALCAbstractType *type = [[ALCAbstractType alloc] init];
    const char *structEncoding = @encode(CGRect);
    XCTAssertEqualObjects(@"CGRect", [type structNameFromEncoding:structEncoding]);
}

-(void) testStructNameFromEncodingWhenNotAStruct {
    ALCAbstractType *type = [[ALCAbstractType alloc] init];
    XCTAssertNil([type structNameFromEncoding:"xxx"]);
}

#pragma mark - Method name fragments

#define testMethodNameFragment(methodName, withType, expectedDescription) \
-(void) testMethodNameFragment_ ## methodName { \
ALCAbstractType *type = [[ALCAbstractType alloc] init]; \
type.type = withType; \
XCTAssertEqualObjects(expectedDescription, type.methodNameFragment); \
}

-(void) testMethodNameFragment_Unknown {
    ALCAbstractType *type = [[ALCAbstractType alloc] init];
    XCTAssertThrowsSpecific(type.methodNameFragment, AlchemicIllegalArgumentException);
}

testMethodNameFragment(Bool, ALCValueTypeBool, @"Bool")
testMethodNameFragment(Char, ALCValueTypeChar, @"Char")
testMethodNameFragment(CharPointer, ALCValueTypeCharPointer, @"CharPointer")
testMethodNameFragment(Double, ALCValueTypeDouble, @"Double")
testMethodNameFragment(Float, ALCValueTypeFloat, @"Float")
testMethodNameFragment(Int, ALCValueTypeInt, @"Int")
testMethodNameFragment(Long, ALCValueTypeLong, @"Long") // in 64Bit, shows as a long long
testMethodNameFragment(LongLong, ALCValueTypeLongLong, @"LongLong")
testMethodNameFragment(Short, ALCValueTypeShort, @"Short")
testMethodNameFragment(UnsignedChar, ALCValueTypeUnsignedChar, @"UnsignedChar")
testMethodNameFragment(UnsignedInt, ALCValueTypeUnsignedInt, @"UnsignedInt")
testMethodNameFragment(UnsignedLong, ALCValueTypeUnsignedLong, @"UnsignedLong") // in 64Bit, shows as a long long
testMethodNameFragment(UnsignedLongLong, ALCValueTypeUnsignedLongLong, @"UnsignedLongLong")
testMethodNameFragment(UnsignedShort, ALCValueTypeUnsignedShort, @"UnsignedShort")

// Structs
testMethodNameFragment(Struct, ALCValueTypeStruct, @"Struct")

// Classes
testMethodNameFragment(Object, ALCValueTypeObject, @"Object")
testMethodNameFragment(Array, ALCValueTypeArray, @"Array")

#pragma mark - Descriptions

#define testDescription(methodName, withType, expectedDescription) \
-(void) testDescription_ ## methodName { \
ALCAbstractType *type = [[ALCAbstractType alloc] init]; \
type.type = withType; \
XCTAssertEqualObjects(expectedDescription, type.description); \
}

testDescription(Unknown, ALCValueTypeUnknown, @"[unknown type]")

testDescription(Bool, ALCValueTypeBool, @"scalar BOOL")
testDescription(Char, ALCValueTypeChar, @"scalar char")
testDescription(CharPointer, ALCValueTypeCharPointer, @"scalar char *")
testDescription(Double, ALCValueTypeDouble, @"scalar double")
testDescription(Float, ALCValueTypeFloat, @"scalar float")
testDescription(Int, ALCValueTypeInt, @"scalar int")
testDescription(Long, ALCValueTypeLong, @"scalar long") // in 64Bit, shows as a long long
testDescription(LongLong, ALCValueTypeLongLong, @"scalar long long")
testDescription(Short, ALCValueTypeShort, @"scalar short")
testDescription(UnsignedChar, ALCValueTypeUnsignedChar, @"scalar unsigned char")
testDescription(UnsignedInt, ALCValueTypeUnsignedInt, @"scalar unsigned int")
testDescription(UnsignedLong, ALCValueTypeUnsignedLong, @"scalar unsigned long") // in 64Bit, shows as a long long
testDescription(UnsignedLongLong, ALCValueTypeUnsignedLongLong, @"scalar unsigned long long")
testDescription(UnsignedShort, ALCValueTypeUnsignedShort, @"scalar unsigned short")

// Structs
testDescription(Struct, ALCValueTypeStruct, @"struct")

// Classes
testDescription(Object, ALCValueTypeObject, @"class NSObject *")
testDescription(Array, ALCValueTypeArray, @"class NSArray *")

@end
