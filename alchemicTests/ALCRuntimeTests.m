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
    Class iVarClass = [ALCRuntime classForIVar:var];
    XCTAssertEqual([NSString class], iVarClass);
}

-(void) testIVarClassId {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aIdProperty"];
    Class iVarClass = [ALCRuntime classForIVar:var];
    XCTAssertEqual([NSObject class], iVarClass);
}

-(void) testIVarClassProtocol {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aProtocolProperty"];
    Class iVarClass = [ALCRuntime classForIVar:var];
    XCTAssertEqual([NSObject class], iVarClass);
}

-(void) testIVarClassNSStringProtocol {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aClassProtocolProperty"];
    Class iVarClass = [ALCRuntime classForIVar:var];
    XCTAssertEqual([NSString class], iVarClass);
}

-(void) testIVarClassInt {
    Ivar var = [ALCRuntime aClass:[self class] variableForInjectionPoint:@"aIntProperty"];
    Class iVarClass = [ALCRuntime classForIVar:var];
    XCTAssertNil(iVarClass);
}

@end
