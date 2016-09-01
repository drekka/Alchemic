//
//  ALCValue+InjectionTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 1/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import ObjectiveC;

@interface ALCValue_InjectionTests : XCTestCase
@end

@implementation ALCValue_InjectionTests {
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

#define testScalarVariableInjectionTest(ivarName, ivarType, expectedValue) \
-(void) testVariableInjection_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
const char *encoding = ivar_getTypeEncoding(ivar); \
ivarType value = expectedValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:encoding]; \
ALCValue *alcValue = [[ALCType typeForIvar:ivar] withValue:nsValue completion:NULL]; \
ALCVariableInjectorBlock inj = [alcValue variableInjector]; \
inj(self, ivar); \
XCTAssertEqual(ivarName, expectedValue); \
}

testScalarVariableInjectionTest(aBool, BOOL, YES)
testScalarVariableInjectionTest(aDouble, double, 5.12345678)
testScalarVariableInjectionTest(aFloat, float, 1.2f)
testScalarVariableInjectionTest(aInt, int, 5)
testScalarVariableInjectionTest(aLong, long, 5)
testScalarVariableInjectionTest(aLongLong, long long, 5)
testScalarVariableInjectionTest(aShort, short, 5)
testScalarVariableInjectionTest(aUChar, unsigned char, 'c')
testScalarVariableInjectionTest(aUInt, unsigned int, 5u)
testScalarVariableInjectionTest(aULong, unsigned long, 5u)
testScalarVariableInjectionTest(aULongLong, unsigned long long, 5u)
testScalarVariableInjectionTest(aUShort, unsigned short, 5u)

-(void) testVariableInjection_aCharPointer {
    Ivar ivar = class_getInstanceVariable([self class], "aCharPointer");
    const char *encoding = ivar_getTypeEncoding(ivar);
    char *value = "abc";
    NSValue *nsValue = [NSValue valueWithBytes:&value objCType:encoding];
    ALCValue *alcValue = [[ALCType typeForIvar:ivar] withValue:nsValue completion:NULL];
    ALCVariableInjectorBlock inj = [alcValue variableInjector];
    inj(self, ivar);
    XCTAssertTrue(strcmp("abc", aCharPointer) == 0);
}

#define testScalarStructVariableInjectionTest(ivarName, ivarType, expectedValue, compareFunction) \
-(void) testVariableInjection_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
const char *encoding = ivar_getTypeEncoding(ivar); \
ivarType value = expectedValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:encoding]; \
ALCValue *alcValue = [[ALCType typeForIvar:ivar] withValue:nsValue completion:NULL]; \
ALCVariableInjectorBlock inj = [alcValue variableInjector]; \
inj(self, ivar); \
XCTAssertTrue(compareFunction(ivarName, expectedValue)); \
}

testScalarStructVariableInjectionTest(size, CGSize, CGSizeMake(1.0f, 2.0f), CGSizeEqualToSize)
testScalarStructVariableInjectionTest(point, CGPoint, CGPointMake(1.0f, 2.0f), CGPointEqualToPoint)
testScalarStructVariableInjectionTest(rect, CGRect, CGRectMake(1.0f, 2.0f, 3.0f, 4.0f), CGRectEqualToRect)

-(void) testVariableInjection_aNumber {
    Ivar ivar = class_getInstanceVariable([self class], "aNumber");
    ALCValue *alcValue = [[ALCType typeForIvar:ivar] withValue:@5 completion:NULL];
    ALCVariableInjectorBlock inj = [alcValue variableInjector];
    inj(self, ivar);
    XCTAssertEqualObjects(@5, aNumber);
}

@end
