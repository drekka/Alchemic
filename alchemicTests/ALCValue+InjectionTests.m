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
@property (nonatomic, strong) NSArray<NSNumber *> *arrayOfNumbers;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGRect rect;


@end

@implementation ALCValue_InjectionTests

#pragma mark - Variable injections

#define  testScalarVariableInjection(ivarName, ivarType, expectedValue) \
-(void) testVariableInjection ## ivarName { \
ivarType value = expectedValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(ivarType)]; \
ALCValue *alcValue = [ALCValue withValue:nsValue completion:NULL]; \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
ALCType *alcType = [ALCType typeForIvar:ivar]; \
ALCVariableInjectorBlock inj = [alcValue variableInjectorForType:alcType]; \
NSError *error; \
BOOL success = inj(self, alcType, ivar, &error); \
XCTAssertTrue(success); \
XCTAssertNil(error); \
XCTAssertEqual(ivarName, expectedValue); \
}

testScalarVariableInjection(_aBool, BOOL, YES)
testScalarVariableInjection(_aChar, signed char, 'x')
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
    ALCValue *alcValue = [ALCValue withValue:nsValue completion:NULL];
    ALCType *alcType = [ALCType typeForIvar:ivar];
    ALCVariableInjectorBlock inj = [alcValue variableInjectorForType:alcType];
    NSError *error;
    XCTAssertTrue(inj(self, alcType, ivar, &error));
    XCTAssertNil(error);
    XCTAssertTrue(strcmp("abc", _aCharPointer) == 0);
}

#define testScalarStructVariableInjection(ivarName, ivarType, expectedValue, compareFunction) \
-(void) testVariableInjection ## ivarName { \
Ivar ivar = class_getInstanceVariable([self class], alc_toCString(ivarName)); \
const char *encoding = ivar_getTypeEncoding(ivar); \
ivarType value = expectedValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:encoding]; \
ALCValue *alcValue = [ALCValue withValue:nsValue completion:NULL]; \
ALCType *alcType = [ALCType typeForIvar:ivar]; \
ALCVariableInjectorBlock inj = [alcValue variableInjectorForType:alcType]; \
NSError *error; \
XCTAssertTrue(inj(self, alcType, ivar, &error)); \
XCTAssertNil(error); \
XCTAssertTrue(compareFunction(ivarName, expectedValue)); \
}

testScalarStructVariableInjection(_size, CGSize, CGSizeMake(1.0f, 2.0f), CGSizeEqualToSize)
testScalarStructVariableInjection(_point, CGPoint, CGPointMake(1.0f, 2.0f), CGPointEqualToPoint)
testScalarStructVariableInjection(_rect, CGRect, CGRectMake(1.0f, 2.0f, 3.0f, 4.0f), CGRectEqualToRect)

-(void) testVariableInjection_Object {
    ALCValue *alcValue = [ALCValue withValue:@5 completion:NULL];
    ALCType *alcType = [ALCType typeWithClass:[NSNumber class]];
    ALCVariableInjectorBlock inj = [alcValue variableInjectorForType:alcType];
    Ivar ivar = class_getInstanceVariable([self class], "_aNumber");
    NSError *error;
    XCTAssertTrue(inj(self, alcType, ivar, &error));
    XCTAssertNil(error);
    XCTAssertEqualObjects(@5, _aNumber);
}

-(void) testVariableInjection_ObjectWhenNilAllowed {
    ALCValue *alcValue = [ALCValue withValue:[NSNull null] completion:NULL];
    ALCType *alcType = [ALCType typeWithClass:[NSNumber class]];
    alcType.nillable = YES;
    ALCVariableInjectorBlock inj = [alcValue variableInjectorForType:alcType];
    Ivar ivar = class_getInstanceVariable([self class], "_aNumber");
    NSError *error;
    XCTAssertTrue(inj(self, alcType, ivar, &error));
    XCTAssertNil(error);
    XCTAssertNil(_aNumber);
}

-(void) testVariableInjection_ObjectWhenNilNotAllowed {
    ALCValue *alcValue = [ALCValue withValue:[NSNull null] completion:NULL];
    ALCType *alcType = [ALCType typeWithClass:[NSNumber class]];
    ALCVariableInjectorBlock inj = [alcValue variableInjectorForType:alcType];
    Ivar ivar = class_getInstanceVariable([self class], "_aNumber");
    NSError *error;
    XCTAssertFalse(inj(self, alcType, ivar, &error));
    XCTAssertEqualObjects(@"Nil value not allowed in this injection", error.localizedDescription);
    XCTAssertNil(_aNumber);
}

-(void) testVariableInjection_Array {
    ALCValue *alcValue = [ALCValue withValue:@[@5] completion:NULL];
    ALCType *alcType = [ALCType typeWithClass:[NSArray class]];
    ALCVariableInjectorBlock inj = [alcValue variableInjectorForType:alcType];
    Ivar ivar = class_getInstanceVariable([self class], "_arrayOfNumbers");
    NSError *error;
    XCTAssertTrue(inj(self, alcType, ivar, &error));
    XCTAssertNil(error);
    XCTAssertEqual(1u, _arrayOfNumbers.count);
    XCTAssertEqualObjects(@5, _arrayOfNumbers[0]);
}

#pragma mark - Invocation injections

#define testScalarInvocationInjectionTest(varName, ivarType, methodSelector, expectedValue) \
-(void) testInvocationInjection_ ## varName { \
NSInvocation *inv = [self invForSelector:@selector(methodSelector)]; \
ivarType value = expectedValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(ivarType)]; \
ALCValue *alcValue = [ALCValue withValue:nsValue completion:NULL]; \
ALCType *alcType = [ALCType typeWithEncoding:@encode(ivarType)]; \
ALCInvocationInjectorBlock inj = [alcValue invocationInjectorForType:alcType]; \
NSError *error; \
XCTAssertTrue(inj(inv, alcType, 0, &error)); \
XCTAssertNil(error); \
[inv invokeWithTarget:self]; \
XCTAssertEqual(_ ## varName, expectedValue); \
}

testScalarInvocationInjectionTest(aBool, BOOL, setABool:, YES)
testScalarInvocationInjectionTest(aChar, signed char, setAChar:, 'x')
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

#define testScalarStructInvocationInjectionTest(varName, ivarType, methodSelector, expectedValue, compareFunction) \
-(void) testInvocationInjection_ ## varName { \
NSInvocation *inv = [self invForSelector:@selector(methodSelector)]; \
ivarType value = expectedValue; \
NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(ivarType)]; \
ALCValue *alcValue = [ALCValue withValue:nsValue completion:NULL]; \
ALCType *alcType = [ALCType typeWithEncoding:@encode(ivarType)]; \
ALCInvocationInjectorBlock inj = [alcValue invocationInjectorForType:alcType]; \
NSError *error; \
XCTAssertTrue(inj(inv, alcType, 0, &error)); \
XCTAssertNil(error); \
[inv invokeWithTarget:self]; \
XCTAssertTrue(compareFunction(varName, expectedValue)); \
}

testScalarStructInvocationInjectionTest(_size, CGSize, setSize:, CGSizeMake(1.0f, 2.0f), CGSizeEqualToSize)
testScalarStructInvocationInjectionTest(_point, CGPoint, setPoint:, CGPointMake(1.0f, 2.0f), CGPointEqualToPoint)
testScalarStructInvocationInjectionTest(_rect, CGRect, setRect:, CGRectMake(1.0f, 2.0f, 3.0f, 4.0f), CGRectEqualToRect)

-(void) testInvocationInjection_aCharPointer {
    NSInvocation *inv = [self invForSelector:@selector(setACharPointer:)];
    char *value = "abc";
    NSValue *nsValue = [NSValue valueWithBytes:&value objCType:"*"];
    ALCValue *alcValue = [ALCValue withValue:nsValue completion:NULL];
    ALCType *alcType = [ALCType typeWithEncoding:@encode(char *)];
    ALCInvocationInjectorBlock inj = [alcValue invocationInjectorForType:alcType];
    NSError *error;
    XCTAssertTrue(inj(inv, alcType, 0, &error));
    XCTAssertNil(error);
    [inv invokeWithTarget:self];
    XCTAssertTrue(strcmp(_aCharPointer, "abc") == 0);
}

-(void) testInvocationInjection_Object {
    NSInvocation *inv = [self invForSelector:@selector(setANumber:)];
    ALCValue *alcValue = [ALCValue withValue:@5 completion:NULL];
    ALCType *alcType = [ALCType typeWithClass:[NSNumber class]];
    ALCInvocationInjectorBlock inj = [alcValue invocationInjectorForType:alcType];
    NSError *error;
    XCTAssertTrue(inj(inv, alcType, 0, &error));
    XCTAssertNil(error);
    [inv invokeWithTarget:self];
    XCTAssertEqualObjects(@5, _aNumber);
}

-(void) testInvocationInjection_Array {
    NSInvocation *inv = [self invForSelector:@selector(setArrayOfNumbers:)];
    ALCValue *alcValue = [ALCValue withValue:@[@5] completion:NULL];
    ALCType *alcType = [ALCType typeWithClass:[NSArray class]];
    ALCInvocationInjectorBlock inj = [alcValue invocationInjectorForType:alcType];
    NSError *error;
    XCTAssertTrue(inj(inv, alcType, 0, &error));
    XCTAssertNil(error);
    [inv invokeWithTarget:self];
    XCTAssertEqual(1u, _arrayOfNumbers.count);
    XCTAssertEqualObjects(@5, _arrayOfNumbers[0]);
}

#pragma mark - Internal

-(NSInvocation *) invForSelector:(SEL) selector {
    Method method = class_getInstanceMethod([self class], selector);
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv retainArguments];
    inv.selector = selector;
    return inv;

}

@end
