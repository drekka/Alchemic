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
ALCType *type = [ALCType typeForIvar:ivar]; \
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
ALCType *type = [ALCType typeForIvar:ivar]; \
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

#pragma mark - Description

-(void) testDescriptionWithStruct {
    Ivar ivar = class_getInstanceVariable([self class], "size");
    ALCType *type = [ALCType typeForIvar:ivar];
    XCTAssertEqualObjects(@"struct CGSize", type.description);
}

-(void) testDescriptionWithClass {
    Ivar ivar = class_getInstanceVariable([self class], "aNumber");
    ALCType *type = [ALCType typeForIvar:ivar];
    XCTAssertEqualObjects(@"class NSNumber *", type.description);
}

-(void) testDescriptionWithIdOnly {
    Ivar ivar = class_getInstanceVariable([self class], "idOnly");
    ALCType *type = [ALCType typeForIvar:ivar];
    XCTAssertEqualObjects(@"id", type.description);
}

-(void) testDescriptionWithProtocols {
    Ivar ivar = class_getInstanceVariable([self class], "idWithProtocol");
    ALCType *type = [ALCType typeForIvar:ivar];
    XCTAssertEqualObjects(@"id<NSCopying>", type.description);
}

-(void) testDescriptionWithClassAndProtocols {
    Ivar ivar = class_getInstanceVariable([self class], "classAndProtocol");
    ALCType *type = [ALCType typeForIvar:ivar];
    XCTAssertEqualObjects(@"class NSNumber<AlchemicAware> *", type.description);
}

#pragma mark - Method name fragment

-(void) testMethodNameFragmentReturnsStructName {
    Ivar ivar = class_getInstanceVariable([self class], "size");
    ALCType *type = [ALCType typeForIvar:ivar];
    XCTAssertEqualObjects(@"CGSize", type.methodNameFragment);
}

#pragma mark - Generating ALCValue instances

-(void) testWithValueCompletion {
    __block BOOL completionCalled;
    ALCValue *value = [ALCValue withValueType:ALCValueTypeObject value:@"abc" completion:^{
        completionCalled = YES;
    }];
    XCTAssertEqualObjects(@"abc", value.value);
    value.completion();
    XCTAssertTrue(completionCalled);
}

@end
