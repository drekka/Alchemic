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

@implementation ALCRuntimeTests

-(void) testIVarClassNSString {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aStringProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];
    XCTAssertEqual([NSString class], ivarData.objcClass);
}

-(void) testIVarClassId {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aIdProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];
    XCTAssertEqual([NSObject class], ivarData.objcClass);
}

-(void) testIVarClassProtocol {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aProtocolProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];
    XCTAssertEqual([NSObject class], ivarData.objcClass);
}

-(void) testIVarClassNSStringProtocol {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aClassProtocolProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];
    XCTAssertEqual([NSString class], ivarData.objcClass);
}

-(void) testIVarClassInt {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aIntProperty"];
    ALCTypeData *ivarData = [ALCRuntime typeDataForIVar:var];
    XCTAssertNil(ivarData.objcClass);
}

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

+(void) classMethod {}
-(void) instanceMethod {}
-(void) methodWithString:(NSString *) aString andInt:(int) aInt {}

@end
