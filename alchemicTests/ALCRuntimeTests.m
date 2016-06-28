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
    [self executeBlockWithException:[AlchemicInjectionNotFoundException class] block:^{
        __unused Ivar var = [ALCRuntime class:[self class] variableForInjectionPoint:@"_X_"];
    }];
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

#pragma mark - Empty implementations

+(void) classMethod {}
-(void) instanceMethod {}
-(void) methodWithString:(NSString *) aString andInt:(int) aInt {}

@end
