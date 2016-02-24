//
//  ALCRuntimeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;

#import "ALCRuntime.h"

@interface ALCRuntimeTests : XCTestCase
@property(nonatomic, strong) NSString *aStringProperty;
@property(nonatomic, strong) id aIdProperty;
@property(nonatomic, assign) int aIntProperty;
@property(nonatomic, strong) id<NSCopying> aProtocolProperty;
@property(nonatomic, strong) NSString<NSFastEnumeration> *aClassProtocolProperty;
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

@end
