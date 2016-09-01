//
//  ALCTypeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 1/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import ObjectiveC;

@interface ALCTypeTests : XCTestCase
@end

@implementation ALCTypeTests {
    BOOL aBool;
    signed char aChar;
    char * aCharPointer;
    double aDouble;
    float aFloat;
    signed int aInt;
    signed long aLong;
    signed long long aLongLong;
    signed short aShort;
    unsigned char aUChar;
    unsigned int aUInt;
    unsigned long aULong;
    unsigned long long aULongLong;
    unsigned short aUShort;
    
    NSNumber *aNumber;
    NSArray<NSNumber *> *aArray;
    
    id idOnly;
    id<NSCopying> idWithProtocol;
    NSNumber<AlchemicAware> *classAndProtocol;
    
    CGSize size;
    CGPoint point;
    CGRect rect;
    
}

#pragma mark - Type with class

-(void) testTypeWithClass {
    ALCType *type = [ALCType typeWithClass:[NSNumber class]];
    XCTAssertEqual(ALCValueTypeObject, type.type);
    XCTAssertEqual([NSNumber class], type.objcClass);
}

#pragma mark - Type with encoding

#define testScalarTypeWithEncoding(ivarName, encoding, valueType, methodName) \
-(void) testTypeWithEncoding_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
const char *ivarEncoding = ivar_getTypeEncoding(ivar); \
ALCType *type = [ALCType typeWithEncoding:ivarEncoding]; \
XCTAssertEqual(valueType, type.type, @"Types don't match"); \
XCTAssertTrue(strcmp(encoding, type.scalarType.UTF8String) == 0, @"Expected %s != %@", encoding, type.scalarType); \
}

// Scalars
testScalarTypeWithEncoding(aBool, "B", ALCValueTypeBool, Bool)
testScalarTypeWithEncoding(aChar, "c", ALCValueTypeChar, Char)
testScalarTypeWithEncoding(aCharPointer, "*", ALCValueTypeCharPointer, CharPointer)
testScalarTypeWithEncoding(aDouble, "d", ALCValueTypeDouble, Double)
testScalarTypeWithEncoding(aFloat, "f", ALCValueTypeFloat, Float)
testScalarTypeWithEncoding(aInt, "i", ALCValueTypeInt, Int)
testScalarTypeWithEncoding(aLong, "q", ALCValueTypeLongLong, Long) // in 64Bit, shows as a long long
testScalarTypeWithEncoding(aLongLong, "q", ALCValueTypeLongLong, LongLong)
testScalarTypeWithEncoding(aShort, "s", ALCValueTypeShort, Short)
testScalarTypeWithEncoding(aUChar, "C", ALCValueTypeUnsignedChar, UChar)
testScalarTypeWithEncoding(aUInt, "I", ALCValueTypeUnsignedInt, UInt)
testScalarTypeWithEncoding(aULong, "Q", ALCValueTypeUnsignedLongLong, ULong) // in 64Bit, shows as a long long
testScalarTypeWithEncoding(aULongLong, "Q", ALCValueTypeUnsignedLongLong, ULongLong)
testScalarTypeWithEncoding(aUShort, "S", ALCValueTypeUnsignedShort, UShort)


// Structs
testScalarTypeWithEncoding(size, "CGSize", ALCValueTypeStruct, CGSize)
testScalarTypeWithEncoding(point, "CGPoint", ALCValueTypeStruct, CGPoint)
testScalarTypeWithEncoding(rect, "CGRect", ALCValueTypeStruct, CGRect)

#define testObjectTypeWithEncoding(ivarName, className, protocolArray, valueType, methodName) \
-(void) testTypeWithEncoding_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
const char *ivarEncoding = ivar_getTypeEncoding(ivar); \
ALCType *type = [ALCType typeWithEncoding:ivarEncoding]; \
XCTAssertEqual(valueType, type.type, @"Types don't match"); \
XCTAssertEqual([className class], type.objcClass, @"Expected %@ != %@", NSStringFromClass([className class]), NSStringFromClass(type.objcClass)); \
XCTAssertEqual(protocolArray.count, type.objcProtocols.count, @"Exepcted %lu protocols, found %lu", protocolArray.count, type.objcProtocols.count); \
for (NSString *protocolName in protocolArray) { \
XCTAssertTrue([type.objcProtocols containsObject:NSProtocolFromString(protocolName)], @"Protocol not in type data: %@", protocolName); \
} \
}

#define testIdTypeWithEncoding(ivarName, protocolArray, valueType, methodName) \
-(void) testTypeWithEncoding_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
const char *ivarEncoding = ivar_getTypeEncoding(ivar); \
ALCType *type = [ALCType typeWithEncoding:ivarEncoding]; \
XCTAssertEqual(valueType, type.type, @"Types don't match"); \
XCTAssertNil(type.objcClass, @"Expected a nil class, found %@", NSStringFromClass(type.objcClass)); \
XCTAssertEqual(protocolArray.count, type.objcProtocols.count, @"Exepcted %lu protocols, found %lu", protocolArray.count, type.objcProtocols.count); \
for (NSString *protocolName in protocolArray) { \
XCTAssertTrue([type.objcProtocols containsObject:NSProtocolFromString(protocolName)], @"Protocol not in type data: %@", protocolName); \
} \
}


// Object types.
testObjectTypeWithEncoding(aNumber, NSNumber, @[], ALCValueTypeObject, NSNumber)
testObjectTypeWithEncoding(aArray, NSArray, (@[]), ALCValueTypeArray, NSArray)
testIdTypeWithEncoding(idOnly, @[], ALCValueTypeObject, IdOnly)
testIdTypeWithEncoding(idWithProtocol, @[@"NSCopying"], ALCValueTypeObject, IdWithProtocol)
testObjectTypeWithEncoding(classAndProtocol, NSNumber, @[@"AlchemicAware"], ALCValueTypeObject, ClassAndProtocol)


-(void) testTypeWithEncodingWhenUnknownType {
    const char *ivarEncoding = "j832h2i f2o 2o f2 hof e2o";
    XCTAssertThrowsSpecific([ALCType typeWithEncoding:ivarEncoding], AlchemicTypeMissMatchException);
}

#pragma mark - Fragment names

#define testMethodNameFragment(ivarName, expectedName) \
-(void) testMethodNameFragment_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
XCTAssertEqualObjects(alc_toNSString(expectedName), [[ALCType typeForIvar:ivar] methodNameFragment]); \
}

testMethodNameFragment(aBool, Bool)
testMethodNameFragment(aChar, Char)
testMethodNameFragment(aCharPointer, CharPointer)
testMethodNameFragment(aDouble, Double)
testMethodNameFragment(aFloat, Float)
testMethodNameFragment(aInt, Int)
testMethodNameFragment(aLong, LongLong) // in 64Bit, shows as a long long
testMethodNameFragment(aLongLong, LongLong)
testMethodNameFragment(aShort, Short)
testMethodNameFragment(aUChar, UnsignedChar)
testMethodNameFragment(aUInt, UnsignedInt)
testMethodNameFragment(aULong, UnsignedLongLong) // in 64Bit, shows as a long long
testMethodNameFragment(aULongLong, UnsignedLongLong)
testMethodNameFragment(aUShort, UnsignedShort)

// Structs
testMethodNameFragment(size, Struct)
testMethodNameFragment(point, Struct)
testMethodNameFragment(rect, Struct)

// Classes
testMethodNameFragment(aNumber, Object)
testMethodNameFragment(aArray, Array)

#pragma mark - Type descriptions

#define testDescription(ivarName, expectedDescription) \
-(void) testDescription_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
XCTAssertEqualObjects(expectedDescription, [ALCType typeForIvar:ivar].description); \
}

testDescription(aBool, @"scalar BOOL")
testDescription(aChar, @"scalar char")
testDescription(aCharPointer, @"scalar char *")
testDescription(aDouble, @"scalar double")
testDescription(aFloat, @"scalar float")
testDescription(aInt, @"scalar int")
testDescription(aLong, @"scalar long long") // in 64Bit, shows as a long long
testDescription(aLongLong, @"scalar long long")
testDescription(aShort, @"scalar short")
testDescription(aUChar, @"scalar unsigned char")
testDescription(aUInt, @"scalar unsigned int")
testDescription(aULong, @"scalar unsigned long long") // in 64Bit, shows as a long long
testDescription(aULongLong, @"scalar unsigned long long")
testDescription(aUShort, @"scalar unsigned short")

// Structs
testDescription(size, @"scalar CGSize")
testDescription(point, @"scalar CGPoint")
testDescription(rect, @"scalar CGRect")

// Classes
testDescription(aNumber, @"class NSNumber *")
testDescription(aArray, @"class NSArray *")
testDescription(idOnly, @"id")
testDescription(idWithProtocol, @"id<NSCopying>")
testDescription(classAndProtocol, @"class NSNumber<AlchemicAware> *")

#pragma mark - Generating ALCValue instances

-(void) testWithValueCompletion {
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    __block BOOL completionCalled;
    ALCValue *value = [type withValue:@"abc" completion:^{
        completionCalled = YES;
    }];
    XCTAssertEqualObjects(@"abc", value.value);
    value.completion();
    XCTAssertTrue(completionCalled);
}

@end
