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

#pragma mark - Validating

-(void) testValidateClassSelectorArgumentsInheritedMethod {
    [ALCRuntime validateClass:[self class] selector:@selector(copy) numberOfArguments:0];
}

-(void) testValidateClassSelectorArgumentsInheritedProperty {
    [ALCRuntime validateClass:[self class] selector:@selector(description) numberOfArguments:0];
}

-(void) testValidateClassSelectorArgumentsClassMethod {
    [ALCRuntime validateClass:[self class] selector:@selector(classMethod) numberOfArguments:0];
}

-(void) testValidateClassSelectorArgumentsInstanceMethod {
    [ALCRuntime validateClass:[self class] selector:@selector(instanceMethod) numberOfArguments:0];
}

-(void) testValidateClassSelectorArgumentsWithArgs {
    [ALCRuntime validateClass:[self class] selector:@selector(methodWithString:andInt:) numberOfArguments:2];
}

-(void) testValidateClassSelectorArgumentsIncorrectNumberArguments {
    XCTAssertThrowsSpecificNamed(([ALCRuntime validateClass:[self class] selector:@selector(methodWithString:andInt:) numberOfArguments:1]), AlchemicIncorrectNumberOfArgumentsException, @"AlchemicIncorrectNumberOfArgumentsException");
}

-(void) testValidateClassSelectorArgumentsSelectorNotFound {
    AcIgnoreSelectorWarnings(
                             XCTAssertThrowsSpecificNamed(([ALCRuntime validateClass:[self class] selector:@selector(xxxx) numberOfArguments:0]), AlchemicSelectorNotFoundException, @"AlchemicSelectorNotFoundException");
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
