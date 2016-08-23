//
//  ALCRuntimeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;
@import OCMock;

@import Alchemic;
@import Alchemic.Private;

#import "XCTestCase+Alchemic.h"

@interface ALCRuntimeTests : XCTestCase
@property(nonatomic, strong, readonly) NSString *aStringProperty; // Readonly for properties test.
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
    Ivar var = [ALCRuntime forClass:[self class] variableForInjectionPoint:@"aStringProperty"];
    XCTAssertEqual(expectedIvar, var);
}

-(void) testVariableForInjectionPointPrivateVariable {
    Ivar expectedIvar = class_getInstanceVariable([self class], "_privateVariable");
    Ivar var = [ALCRuntime forClass:[self class] variableForInjectionPoint:@"_privateVariable"];
    XCTAssertEqual(expectedIvar, var);
}

-(void) testVariableForInjectionPointNotFound {
    XCTAssertThrowsSpecific([ALCRuntime forClass:[self class] variableForInjectionPoint:@"_X_"], AlchemicInjectionNotFoundException);
}

#pragma mark - TypeDataForIVar:

-(void) testTypeDataForIVarString {
    Ivar var = [ALCRuntime forClass:[self class] variableForInjectionPoint:@"aStringProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];
    XCTAssertEqual([NSString class], ivarData.objcClass);
}

-(void) testTypeDataForIVarId {

    Ivar var = [ALCRuntime forClass:[self class] variableForInjectionPoint:@"aIdProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertEqual([NSObject class], ivarData.objcClass);
    XCTAssertNil(ivarData.objcProtocols);
    XCTAssertEqual(NULL, ivarData.scalarType);
}

-(void) testTypeDataForIVarProtocol {

    Ivar var = [ALCRuntime forClass:[self class] variableForInjectionPoint:@"aProtocolProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertEqual([NSObject class], ivarData.objcClass);
    XCTAssertTrue([ivarData.objcProtocols containsObject:@protocol(NSCopying)]);
    XCTAssertEqual(NULL, ivarData.scalarType);
}

-(void) testTypeDataForIVarClassNSStringProtocol {

    Ivar var = [ALCRuntime forClass:[self class] variableForInjectionPoint:@"aClassProtocolProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertEqual([NSString class], ivarData.objcClass);
    XCTAssertTrue([ivarData.objcProtocols containsObject:@protocol(NSFastEnumeration)]);
    XCTAssertEqual(NULL, ivarData.scalarType);
}

-(void) testTypeDataForIVarInt {

    Ivar var = [ALCRuntime forClass:[self class] variableForInjectionPoint:@"aIntProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertNil(ivarData.objcClass);
    XCTAssertNil(ivarData.objcProtocols);
    XCTAssertEqual(0, strcmp("i", ivarData.scalarType));
}

-(void) testTypeDataForIVarCGRect {

    Ivar var = [ALCRuntime forClass:[self class] variableForInjectionPoint:@"_aRect"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];

    XCTAssertNil(ivarData.objcClass);
    XCTAssertNil(ivarData.objcProtocols);
    XCTAssertEqual(0, strcmp("{CGRect=\"origin\"{CGPoint=\"x\"d\"y\"d}\"size\"{CGSize=\"width\"d\"height\"d}}", ivarData.scalarType));
}

#pragma mark - Porperty list

-(void) testPropertiesForClass {
    NSArray *props = [ALCRuntime writeablePropertiesForClass:[self class]];
    XCTAssertEqual(4u, props.count);
    //XCTAssertTrue([props containsObject:@"aStringProperty"]); Readonly.
    XCTAssertTrue([props containsObject:@"aIdProperty"]);
    XCTAssertTrue([props containsObject:@"aIntProperty"]);
    XCTAssertTrue([props containsObject:@"aProtocolProperty"]);
    XCTAssertTrue([props containsObject:@"aClassProtocolProperty"]);
}

#pragma mark - Mapping values

-(void) testMapValueToTypeObjectToArray {
    NSError *error;
    id result = [ALCRuntime mapValue:@"abc" allowNils:NO type:[NSArray class] error:&error];
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(@"abc", result[0]);
    XCTAssertNil(error);
}

-(void) testMapValueToTypeArrayToArray {
    NSError *error;
    id result = [ALCRuntime mapValue:@[@"abc"] allowNils:NO type:[NSArray class] error:&error];
    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertEqual(@"abc", result[0]);
    XCTAssertNil(error);
}

-(void) testMapValueToTypeArrayOfOneToObject {
    NSError *error;
    id result = [ALCRuntime mapValue:@[@"abc"] allowNils:NO type:[NSString class] error:&error];
    XCTAssertEqual(@"abc", result);
    XCTAssertNil(error);
}

-(void) testMapValueToTypeArrayOfManyToObjectThrows {
    NSError *error;
    id result = [ALCRuntime mapValue:@[@"abc", @"def"] allowNils:NO type:[NSString class] error:&error];
    XCTAssertNil(result);
    XCTAssertEqualObjects(@"Expected 1 value, got 2", error.localizedDescription);
}

-(void) testMapValueToTypeTypeMissMatch {
    NSError *error;
    id result = [ALCRuntime mapValue:@[@"abc"] allowNils:NO type:[NSNumber class] error:&error];
    XCTAssertNil(result);
    XCTAssertEqualObjects(@"Value of type __NSCFConstantString cannot be cast to a NSNumber", error.localizedDescription);
}

-(void) testMapValueToTypeUpCast {
    NSError *error;
    id value = [ALCRuntime mapValue:[@"abc" mutableCopy] allowNils:NO type:[NSString class] error:&error];
    XCTAssertEqualObjects(@"abc", value);
    XCTAssertNil(error);
}

-(void) testMapValueToTypeDownCastThrows {
    NSError *error;
    id result = [ALCRuntime mapValue:@{} allowNils:NO type:[NSMutableDictionary class] error:&error];
    XCTAssertNil(result);
    XCTAssertEqualObjects(@"Value of type __NSDictionary0 cannot be cast to a NSMutableDictionary", error.localizedDescription);
}

#pragma mark - Setting values

-(void) testSetInvocationArgIndexWithValueOfClass {
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(methodWithString:andInt:)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    NSError *error;
    [inv setArgIndex:0
              ofType:[NSString class]
           allowNils:NO
               value:@"abc"
               error:&error];
    NSString *storedArg;
    [inv getArgument:&storedArg atIndex:2];
    XCTAssertEqualObjects(@"abc", storedArg);
    XCTAssertNil(error);
}

-(void) testSetObjectVariableWithValue {
    Ivar ivar = class_getInstanceVariable([self class], "_privateVariable");
    NSError *error;
    [self setVariable:ivar ofType:[NSString class] allowNils:NO value:@"abc" error:&error];
    XCTAssertEqualObjects(@"abc", _privateVariable);
    XCTAssertNil(error);
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
    XCTAssertThrowsSpecificNamed(([ALCRuntime validateClass:[self class] selector:@selector(methodWithString:andInt:) arguments:@[arg1]]), AlchemicIncorrectNumberOfArgumentsException, @"AlchemicIncorrectNumberOfArgumentsException");
}

-(void) testValidateClassSelectorArgumentsSelectorNotFound {
    AcIgnoreSelectorWarnings(
                             XCTAssertThrowsSpecificNamed(([ALCRuntime validateClass:[self class] selector:@selector(xxxx) arguments:nil]), AlchemicSelectorNotFoundException, @"AlchemicSelectorNotFoundException");
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
    NSString *desc = [ALCRuntime forClass:[NSString class] selectorDescription:@selector(stringWithFormat:)];
    XCTAssertEqualObjects(@"+[NSString stringWithFormat:]", desc);
}

-(void) testSelectorDescriptionForInstanceMethod {
    NSString *desc = [ALCRuntime forClass:[NSString class] selectorDescription:@selector(initWithCharacters:length:)];
    XCTAssertEqualObjects(@"-[NSString initWithCharacters:length:]", desc);
}

-(void) testSelectorDescriptionForInit {
    NSString *desc = [ALCRuntime forClass:[NSObject class] selectorDescription:@selector(init)];
    // Note classes have a +init method according to the runtime.
    XCTAssertEqualObjects(@"+[NSObject init]", desc);
}

-(void) testPropertyDescription {
    NSString *desc = [ALCRuntime forClass:[self class] propertyDescription:@"aStringProperty"];
    XCTAssertEqualObjects(@"ALCRuntimeTests.aStringProperty", desc);
}

-(void) testVariableDescription {
    Ivar pv = class_getInstanceVariable([self class], "_privateVariable");
    NSString *desc = [ALCRuntime forClass:[self class] variableDescription:pv];
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

#pragma mark - Empty test implementations

+(void) classMethod {}
-(void) instanceMethod {}
-(void) methodWithString:(NSString *) aString andInt:(int) aInt {}

@end
