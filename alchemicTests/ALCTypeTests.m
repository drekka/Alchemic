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

-(void) testTypeWithIvar {
    Ivar ivar = class_getInstanceVariable([self class], "aNumber");
    ALCType *type = [ALCType typeForIvar:ivar];
    XCTAssertEqual([NSNumber class], type.objcClass);
}

-(void) testTypeWithClass {
    ALCType *type = [ALCType typeWithClass:[NSNumber class]];
    XCTAssertEqual(ALCValueTypeObject, type.type);
    XCTAssertEqual([NSNumber class], type.objcClass);
}

#pragma mark - Type with encoding

#define testScalarTypeWithEncoding(ivarName, encoding, valueType, methodName) \
-(void) testTypeWithEncoding_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
ALCType *type = [ALCType typeForIvar:ivar]; \
XCTAssertEqual(valueType, type.type, @"Types don't match"); \
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

#define testStructTypeWithEncoding(ivarName, encoding, valueType, methodName) \
-(void) testTypeWithEncoding_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
ALCType *type = [ALCType typeForIvar:ivar]; \
XCTAssertEqual(valueType, type.type, @"Types don't match"); \
}

// Structs
testStructTypeWithEncoding(size, "CGSize", ALCValueTypeCGSize, CGSize)
testStructTypeWithEncoding(point, "CGPoint", ALCValueTypeCGPoint, CGPoint)
testStructTypeWithEncoding(rect, "CGRect", ALCValueTypeCGRect, CGRect)

#define testObjectTypeWithEncoding(ivarName, className, protocolArray, valueType, methodName) \
-(void) testTypeWithEncoding_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
ALCType *type = [ALCType typeForIvar:ivar]; \
XCTAssertEqual(valueType, type.type, @"Types don't match"); \
XCTAssertEqual([className class], type.objcClass, @"Expected %@ != %@", NSStringFromClass([className class]), NSStringFromClass(type.objcClass)); \
XCTAssertEqual(protocolArray.count, type.objcProtocols.count, @"Exepcted %lu protocols, found %lu",  (unsigned long) protocolArray.count, (unsigned long) type.objcProtocols.count); \
for (NSString *protocolName in protocolArray) { \
XCTAssertTrue([type.objcProtocols containsObject:NSProtocolFromString(protocolName)], @"Protocol not in type data: %@", protocolName); \
} \
}

#define testIdTypeWithEncoding(ivarName, protocolArray, valueType, methodName) \
-(void) testTypeWithEncoding_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
ALCType *type = [ALCType typeForIvar:ivar]; \
XCTAssertEqual(valueType, type.type, @"Types don't match"); \
XCTAssertNil(type.objcClass, @"Expected a nil class, found %@", NSStringFromClass(type.objcClass)); \
XCTAssertEqual(protocolArray.count, type.objcProtocols.count, @"Exepcted %lu protocols, found %lu", (unsigned long) protocolArray.count, (unsigned long) type.objcProtocols.count); \
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

#pragma mark - Descriptions

#define testDescription(ivarName, expectedDescription) \
-(void) testDescription_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
ALCType *type = [ALCType typeForIvar:ivar]; \
XCTAssertEqualObjects(expectedDescription, type.description); \
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
testDescription(size, @"struct CGSize")
testDescription(point, @"struct CGPoint")
testDescription(rect, @"struct CGRect")

// Classes
testDescription(aNumber, @"class NSNumber *")
testDescription(aArray, @"class NSArray *")
testDescription(idOnly, @"id")
testDescription(idWithProtocol, @"id<NSCopying>")
testDescription(classAndProtocol, @"class NSNumber<AlchemicAware> *")

#pragma mark - Generating ALCValue instances

-(void) testWithValueCompletion {
    __block BOOL completionCalled;
    ALCValue *value = [ALCValue withObject:@"abc" completion:^(id val){
        completionCalled = YES;
    }];
    XCTAssertEqualObjects(@"abc", value.object);
    [value complete];
    XCTAssertTrue(completionCalled);
}

@end
