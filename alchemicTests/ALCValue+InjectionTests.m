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

@property (nonatomic, assign) BOOL aBool;
@property (nonatomic, assign) signed char aChar;
@property (nonatomic, assign) char * aCharPointer;
@property (nonatomic, assign) double aDouble;
@property (nonatomic, assign) float aFloat;
@property (nonatomic, assign) signed int aInt;
@property (nonatomic, assign) signed long aLong;
@property (nonatomic, assign) signed long long aLongLong;
@property (nonatomic, assign) signed short aShort;
@property (nonatomic, assign) unsigned char aUChar;
@property (nonatomic, assign) unsigned int aUInt;
@property (nonatomic, assign) unsigned long aULong;
@property (nonatomic, assign) unsigned long long aULongLong;
@property (nonatomic, assign) unsigned short aUShort;

@property (nonatomic, strong) NSNumber *aNumber;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGRect rect;

@end

@implementation ALCValue_InjectionTests

#pragma mark - Variable injections

#define  testScalarVariableInjection(ivarName, ivarType, expectedValue) \
-(void) testVariableInjection_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
const char *encoding = ivar_getTypeEncoding(ivar); \
ivarType value = expectedValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:encoding]; \
ALCType *type = [ALCType typeForIvar:ivar]; \
ALCValue *alcValue = [ALCValue withType:type value:nsValue completion:NULL]; \
ALCVariableInjectorBlock inj = [alcValue variableInjector]; \
inj(self, ivar); \
XCTAssertEqual(ivarName, expectedValue); \
}

 testScalarVariableInjection(_aBool, BOOL, YES)
 testScalarVariableInjection(_aDouble, double, 5.12345678)
 testScalarVariableInjection(_aFloat, float, 1.2f)
 testScalarVariableInjection(_aInt, int, 5)
 testScalarVariableInjection(_aLong, long, 5)
 testScalarVariableInjection(_aLongLong, long long, 5)
 testScalarVariableInjection(_aShort, short, 5)
 testScalarVariableInjection(_aUChar, unsigned char, 'c')
 testScalarVariableInjection(_aUInt, unsigned int, 5u)
 testScalarVariableInjection(_aULong, unsigned long, 5u)
 testScalarVariableInjection(_aULongLong, unsigned long long, 5u)
 testScalarVariableInjection(_aUShort, unsigned short, 5u)

-(void) testVariableInjection_aCharPointer {
    Ivar ivar = class_getInstanceVariable([self class], "_aCharPointer");
    const char *encoding = ivar_getTypeEncoding(ivar);
    char *value = "abc";
    NSValue *nsValue = [NSValue valueWithBytes:&value objCType:encoding];
    ALCType *type = [ALCType typeForIvar:ivar];
    ALCValue *alcValue = [ALCValue withType:type value:nsValue completion:NULL];
    ALCVariableInjectorBlock inj = [alcValue variableInjector];
    inj(self, ivar);
    XCTAssertTrue(strcmp("abc", _aCharPointer) == 0);
}

#define testScalarStructVariableInjection(ivarName, ivarType, expectedValue, compareFunction) \
-(void) testVariableInjection_ ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
const char *encoding = ivar_getTypeEncoding(ivar); \
ivarType value = expectedValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:encoding]; \
ALCType *type = [ALCType typeForIvar:ivar]; \
ALCValue *alcValue = [ALCValue withType:type value:nsValue completion:NULL]; \
ALCVariableInjectorBlock inj = [alcValue variableInjector]; \
inj(self, ivar); \
XCTAssertTrue(compareFunction(ivarName, expectedValue)); \
}

testScalarStructVariableInjection(_size, CGSize, CGSizeMake(1.0f, 2.0f), CGSizeEqualToSize)
testScalarStructVariableInjection(_point, CGPoint, CGPointMake(1.0f, 2.0f), CGPointEqualToPoint)
testScalarStructVariableInjection(_rect, CGRect, CGRectMake(1.0f, 2.0f, 3.0f, 4.0f), CGRectEqualToRect)

-(void) testVariableInjection_aNumber {
    Ivar ivar = class_getInstanceVariable([self class], "_aNumber");
    ALCType *type = [ALCType typeForIvar:ivar];
    ALCValue *alcValue = [ALCValue withType:type value:@5 completion:NULL];
    ALCVariableInjectorBlock inj = [alcValue variableInjector];
    inj(self, ivar);
    XCTAssertEqualObjects(@5, _aNumber);
}

#pragma mark - Invocation injections

#define testScalarInvocationInjectionTest(varName, ivarType, methodSelector, expectedValue) \
-(void) testInvocationInjection_ ## varName { \
Method method = class_getInstanceMethod([self class], @selector(methodSelector)); \
NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)]; \
NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig]; \
inv.selector = @selector(methodSelector); \
ivarType value = expectedValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(ivarType)]; \
ALCType *type = [ALCType typeWithEncoding:@encode(ivarType)]; \
ALCValue *alcValue = [ALCValue withType:type value:nsValue completion:NULL]; \
ALCInvocationInjectorBlock inj = [alcValue invocationInjector]; \
inj(inv, 0); \
[inv invokeWithTarget:self]; \
XCTAssertEqual(_ ## varName, expectedValue); \
}

testScalarInvocationInjectionTest(aBool, BOOL, setABool:, YES)
testScalarInvocationInjectionTest(aDouble, double, setADouble:, 5.12345678)
testScalarInvocationInjectionTest(aFloat, float, setAFloat:, 1.2f)
testScalarInvocationInjectionTest(aInt, int, setAInt:, 5)
testScalarInvocationInjectionTest(aLong, long, setALong:, 5)
testScalarInvocationInjectionTest(aLongLong, long long, setALongLong:, 5)
testScalarInvocationInjectionTest(aShort, short, setAShort:, 5)
testScalarInvocationInjectionTest(aUChar, unsigned char, setAUChar:, 'c')
testScalarInvocationInjectionTest(aUInt, unsigned int, setAUInt:, 5u)
testScalarInvocationInjectionTest(aULong, unsigned long, setAULong:, 5u)
testScalarInvocationInjectionTest(aULongLong, unsigned long long, setAULongLong:, 5u)
testScalarInvocationInjectionTest(aUShort, unsigned short, setAUShort:, 5u)

-(void) testInvocationInjection_aCharPointer {
    Method method = class_getInstanceMethod([self class], @selector(setACharPointer:));
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = @selector(setACharPointer:);
    char *value = "abc";
    NSValue *nsValue = [NSValue valueWithBytes:&value objCType:"*"];
    ALCType *type = [ALCType typeWithEncoding:"*"];
    ALCValue *alcValue = [ALCValue withType:type value:nsValue completion:NULL];
    ALCInvocationInjectorBlock inj = [alcValue invocationInjector];
    inj(inv, 0);
    [inv invokeWithTarget:self];
    XCTAssertTrue(strcmp(_aCharPointer, "abc") == 0);
}

-(void) testInvocationInjection_aNumber {
    Method method = class_getInstanceMethod([self class], @selector(setANumber:));
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = @selector(setANumber:);
    ALCType *type = [ALCType typeWithClass:[NSNumber class]];
    ALCValue *alcValue = [ALCValue withType:type value:@5 completion:NULL];
    ALCInvocationInjectorBlock inj = [alcValue invocationInjector];
    inj(inv, 0);
    [inv invokeWithTarget:self];
    XCTAssertEqualObjects(@5, _aNumber);
}

@end
