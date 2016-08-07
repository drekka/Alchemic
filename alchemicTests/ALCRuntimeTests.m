//
//  ALCRuntimeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;

@import Alchemic;
@import Alchemic.Private;

#import "XCTestCase+Alchemic.h"

@interface ALCRuntimeTests : XCTestCase
@property(nonatomic, strong) NSString *aStringProperty;
@property(nonatomic, strong) id aIdProperty;
@property(nonatomic, assign) int aIntProperty;
@property(nonatomic, strong) id<NSCopying> aProtocolProperty;
@property(nonatomic, strong) NSString<NSFastEnumeration> *aClassProtocolProperty;

+(void) classMethod;
-(void) instanceMethod;
-(void) methodWithString:(NSString *) aString andInt:(int) aInt;

@end

@implementation ALCRuntimeTests {
    NSString *_privateVariable;
    CGRect _aRect;
}

@synthesize aStringProperty = __weirdInternalPropertyVariable;

#pragma mark - VariableForInjectionPoint:

-(void) testVariableForInjectionPointProperty {
    Ivar expectedIvar = class_getInstanceVariable([self class], "__weirdInternalPropertyVariable");
    Ivar var = [ALCRuntime class:[self class] variableForInjectionPoint:@"aStringProperty"];
    XCTAssertEqual(expectedIvar, var);
}

-(void) testVariableForInjectionPointPrivateVariable {
    Ivar expectedIvar = class_getInstanceVariable([self class], "_privateVariable");
    Ivar var = [ALCRuntime class:[self class] variableForInjectionPoint:@"_privateVariable"];
    XCTAssertEqual(expectedIvar, var);
}

-(void) testVariableForInjectionPointNotFound {
    XCTAssertThrowsSpecific([ALCRuntime class:[self class] variableForInjectionPoint:@"_X_"], AlchemicInjectionNotFoundException);
}

#pragma mark - TypeDataForIVar:

-(void) testTypeDataForIVarString {
    Ivar var = [ALCRuntime class:[self class] variableForInjectionPoint:@"aStringProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];
    XCTAssertEqual([NSString class], ivarData.objcClass);
}

-(void) testTypeDataForIVarId {

    Ivar var = [ALCRuntime class:[self class] variableForInjectionPoint:@"aIdProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertEqual([NSObject class], ivarData.objcClass);
    XCTAssertNil(ivarData.objcProtocols);
    XCTAssertEqual(NULL, ivarData.scalarType);
}

-(void) testTypeDataForIVarProtocol {

    Ivar var = [ALCRuntime class:[self class] variableForInjectionPoint:@"aProtocolProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertEqual([NSObject class], ivarData.objcClass);
    XCTAssertTrue([ivarData.objcProtocols containsObject:@protocol(NSCopying)]);
    XCTAssertEqual(NULL, ivarData.scalarType);
}

-(void) testTypeDataForIVarClassNSStringProtocol {

    Ivar var = [ALCRuntime class:[self class] variableForInjectionPoint:@"aClassProtocolProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertEqual([NSString class], ivarData.objcClass);
    XCTAssertTrue([ivarData.objcProtocols containsObject:@protocol(NSFastEnumeration)]);
    XCTAssertEqual(NULL, ivarData.scalarType);
}

-(void) testTypeDataForIVarInt {

    Ivar var = [ALCRuntime class:[self class] variableForInjectionPoint:@"aIntProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertNil(ivarData.objcClass);
    XCTAssertNil(ivarData.objcProtocols);
    XCTAssertEqual(0, strcmp("i", ivarData.scalarType));
}

-(void) testTypeDataForIVarCGRect {

    Ivar var = [ALCRuntime class:[self class] variableForInjectionPoint:@"_aRect"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertNil(ivarData.objcClass);
    XCTAssertNil(ivarData.objcProtocols);
    XCTAssertEqual(0, strcmp("{CGRect=\"origin\"{CGPoint=\"x\"d\"y\"d}\"size\"{CGSize=\"width\"d\"height\"d}}", ivarData.scalarType));
}

#pragma mark - Mapping values

-(void) testMapValueToTypeObjectToArray {
    id result = [ALCRuntime mapValue:@"abc" allowNils:NO type:[NSArray class]];
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(@"abc", result[0]);
}

-(void) testMapValueToTypeArrayToArray {
    id result = [ALCRuntime mapValue:@[@"abc"] allowNils:NO type:[NSArray class]];
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(@"abc", result[0]);
}

-(void) testMapValueToTypeArrayOfOneToObject {
    id result = [ALCRuntime mapValue:@[@"abc"] allowNils:NO type:[NSString class]];
    XCTAssertEqual(@"abc", result);
}

-(void) testMapValueToTypeArrayOfManyToObjectThrows {
    XCTAssertThrowsSpecificNamed(([ALCRuntime mapValue:@[@"abc", @"def"] allowNils:NO type:[NSString class]]), AlchemicIncorrectNumberOfValuesException, @"IncorrectNumberOfValues");
}

-(void) testMapValueToTypeTypeMissMatch {
    XCTAssertThrowsSpecificNamed(([ALCRuntime mapValue:@[@"abc"] allowNils:NO type:[NSNumber class]]), AlchemicTypeMissMatchException, @"TypeMissMatch");
}

-(void) testMapValueToTypeUpCast {
    id value = [ALCRuntime mapValue:[@"abc" mutableCopy] allowNils:NO type:[NSString class]];
    XCTAssertEqualObjects(@"abc", value);
}

-(void) testMapValueToTypeDownCastThrows {
    XCTAssertThrowsSpecificNamed(([ALCRuntime mapValue:@{} allowNils:NO type:[NSMutableDictionary class]]), AlchemicTypeMissMatchException, @"TypeMissMatch");
}

#pragma mark - Setting values

-(void) testSetInvocationArgIndexWithValueOfClass {
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(methodWithString:andInt:)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [ALCRuntime setInvocation:inv
                     argIndex:0
                       ofType:[NSString class]
                    allowNils:NO
                        value:@"abc"];
    NSString *storedArg;
    [inv getArgument:&storedArg atIndex:2];
    XCTAssertEqualObjects(@"abc", storedArg);
}

-(void) testSetObjectVariableWithValue {
    Ivar ivar = class_getInstanceVariable([self class], "_privateVariable");
    [ALCRuntime setObject:self variable:ivar ofType:[NSString class] allowNils:NO value:@"abc"];
    XCTAssertEqualObjects(@"abc", _privateVariable);
}

#pragma mark - Validating

-(void) testValidateClassSelectorArgumentsInheritedMethod {
    [ALCRuntime validateClass:[self class] selector:@selector(copy) arguments:nil];
}

-(void) testValidateClassSelectorArgumentsInheritedProperty {
    [ALCRuntime validateClass:[self class] selector:@selector(description) arguments:nil];
}

-(void) testValidateClassSelectorArgumentsClassMethod {
    [ALCRuntime validateClass:[self class] selector:@selector(classMethod) arguments:nil];
}

-(void) testValidateClassSelectorArgumentsInstanceMethod {
    [ALCRuntime validateClass:[self class] selector:@selector(instanceMethod) arguments:nil];
}

-(void) testValidateClassSelectorArgumentsWithArgs {
    id<ALCDependency> arg1 = AcArg(NSString, AcString(@"abc"));
    id<ALCDependency> arg2 = AcArg(NSNumber, AcInt(5));
    [ALCRuntime validateClass:[self class] selector:@selector(methodWithString:andInt:) arguments:@[arg1, arg2]];
}

-(void) testValidateClassSelectorArgumentsIncorrectNumberArguments {
    id<ALCDependency> arg1 = AcArg(NSString, AcString(@"abc"));
    XCTAssertThrowsSpecificNamed(([ALCRuntime validateClass:[self class] selector:@selector(methodWithString:andInt:) arguments:@[arg1]]), AlchemicIncorrectNumberOfArgumentsException, @"IncorrectNumberOfArguments");
}

-(void) testValidateClassSelectorArgumentsSelectorNotFound {
    AcIgnoreSelectorWarnings(
                             XCTAssertThrowsSpecificNamed(([ALCRuntime validateClass:[self class] selector:@selector(xxxx) arguments:nil]), AlchemicSelectorNotFoundException, @"SelectorNotFound");
                             );
}

#pragma mark - general runtime tests

-(void) testAccessingMethods {

    XCTAssertFalse([[self class] instancesRespondToSelector:@selector(classMethod)]);
    XCTAssertTrue([[self class] instancesRespondToSelector:@selector(instanceMethod)]);

    XCTAssertTrue([[self class] respondsToSelector:@selector(classMethod)]);
    XCTAssertFalse([self respondsToSelector:@selector(classMethod)]);

    XCTAssertTrue([self respondsToSelector:@selector(instanceMethod)]);
    XCTAssertFalse([[self class] respondsToSelector:@selector(instanceMethod)]);
}

-(void) testMethodSignature {

    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(methodWithString:andInt:)];

    const char *arg2 = [sig getArgumentTypeAtIndex:2];
    const char *arg3 = [sig getArgumentTypeAtIndex:3];
    XCTAssertTrue(strcmp("@", arg2) == 0);
    XCTAssertTrue(strcmp("i", arg3) == 0);
}

#pragma mark - Descriptions

-(void) testSelectorDescriptionForClassMethod {
    NSString *desc = [ALCRuntime class:[NSString class] selectorDescription:@selector(stringWithFormat:)];
    XCTAssertEqualObjects(@"+[NSString stringWithFormat:]", desc);
}

-(void) testSelectorDescriptionForInstanceMethod {
    NSString *desc = [ALCRuntime class:[NSString class] selectorDescription:@selector(initWithCharacters:length:)];
    XCTAssertEqualObjects(@"-[NSString initWithCharacters:length:]", desc);
}

-(void) testSelectorDescriptionForInit {
    NSString *desc = [ALCRuntime class:[NSObject class] selectorDescription:@selector(init)];
    // Note classes have a +init method according to the runtime.
    XCTAssertEqualObjects(@"+[NSObject init]", desc);
}

-(void) testPropertyDescription {
    NSString *desc = [ALCRuntime class:[self class] propertyDescription:@"aStringProperty"];
    XCTAssertEqualObjects(@"ALCRuntimeTests.aStringProperty", desc);
}

-(void) testVariableDescription {
    Ivar pv = class_getInstanceVariable([self class], "_privateVariable");
    NSString *desc = [ALCRuntime class:[self class] variableDescription:pv];
    XCTAssertEqualObjects(@"ALCRuntimeTests._privateVariable", desc);
}

#pragma mark - Block executions

-(void) testExecuteSimpleBlock {
    __block BOOL set = NO;
    [ALCRuntime executeSimpleBlock:^{
        set = YES;
    }];
    XCTAssertTrue(set);
}

-(void) testExecuteSimpleBlockNull {
    // Literally nothing to do here.
    [ALCRuntime executeSimpleBlock:NULL];
}

-(void) testExecuteBlockWithObject {

    __block BOOL set = NO;
    ALCBlockWithObject completion = ^(ALCBlockWithObjectArgs){
        XCTAssertEqualObjects(@"abc", object);
        set = YES;
    };

    [ALCRuntime executeBlock:completion withObject:@"abc"];

    XCTAssertTrue(set);
}

-(void) testExecuteBlockWithObjectNullBlock {
    // Literally nothing to do here.
    [ALCRuntime executeBlock:NULL withObject:@"abc"];
}

#pragma mark - Empty implementations

+(void) classMethod {}
-(void) instanceMethod {}
-(void) methodWithString:(NSString *) aString andInt:(int) aInt {}

@end
