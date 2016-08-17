//
//  ALCConstantsTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface ALCConstantInjectorsTests : XCTestCase

@property (nonatomic, assign) int xInt;
@property (nonatomic, assign) BOOL xBool;
@property (nonatomic, assign) long xLong;
@property (nonatomic, assign) float xFloat;
@property (nonatomic, assign) double xDouble;

@property (nonatomic, assign) CGFloat xCGFloat;
@property (nonatomic, assign) CGSize xCGSize;
@property (nonatomic, assign) CGRect xCGRect;

@end

@implementation ALCConstantInjectorsTests

#pragma mark - ACInt

#define testScalar(name, macro, setter, assert) \
-(void) testALC ## name ## VariableInjection { \
    id<ALCInjector> inj = macro; \
    Ivar ivar = [ALCRuntime class:[self class] variableForInjectionPoint:alc_toNSString(x ## name)]; \
    NSError *error; \
    [inj setObject:self variable:ivar error:&error]; \
    XCTAssertNil(error); \
    XCTAssertTrue(assert); \
} \
-(void) testMethodArgUsingALC ## name { \
    id<ALCInjector> constant = macro; \
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(setter)]; \
    NSInvocation  *inv = [NSInvocation invocationWithMethodSignature:sig]; \
    inv.selector = @selector(setter); \
    NSError *error; \
    [constant setInvocation:inv argumentIndex:0 error:&error]; \
    [inv invokeWithTarget:self]; \
    XCTAssertNil(error); \
    XCTAssertTrue(assert); \
}

testScalar(Int, AcInt(5), setXInt:, self.xInt == 5)
testScalar(Bool, AcBool(YES), setXBool:, self.xBool)
testScalar(Long, AcLong(5), setXLong:, self.xLong == 5)
testScalar(Float, AcFloat(1.2f), setXFloat:, self.xFloat == 1.2f)
testScalar(Double, AcDouble(1.23456), setXDouble:, self.xDouble == 1.23456)

testScalar(CGFloat, AcCGFloat(1.23456), setXCGFloat:, self.xCGFloat == 1.23456)
testScalar(CGSize, AcCGSize(CGSizeMake(5.0, 10.0)), setXCGSize:, CGSizeEqualToSize(self.xCGSize, CGSizeMake(5.0, 10.0)))
testScalar(CGRect, AcCGRect(CGRectMake(1.0, 2.0, 3.0, 4.0)), setXCGRect:, CGRectEqualToRect(self.xCGRect, CGRectMake(1.0, 2.0, 3.0, 4.0)))



@end
