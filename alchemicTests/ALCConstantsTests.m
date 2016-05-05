//
//  ALCConstantsTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <Alchemic/Alchemic.h>

@interface ALCConstantsTests : XCTestCase
@property (nonatomic, assign) int anInt;
@property (nonatomic, strong) NSString *aString;
@property (nonatomic, assign) CGRect aCGRect;
@end

@implementation ALCConstantsTests {
    int _anInternalInt;
    NSString *_anInternalString;
    CGRect _anInternalCGRect;
}

#pragma mark - ACInt

-(void) testInjectionInternalUsingALCInt {
    [self injectVariable:@"_anInternalInt" usingDependency:AcInt(5)];
    XCTAssertEqual(5, _anInternalInt);
}

-(void) testInjectionPropertyUsingALCInt {
    [self injectVariable:@"anInt" usingDependency:AcInt(5)];
    XCTAssertEqual(5, self.anInt);
}

-(void) testInjectionPropertyInternalUsingALCInt {
    [self injectVariable:@"_anInt" usingDependency:AcInt(5)];
    XCTAssertEqual(5, self.anInt);
}

-(void) testMethodArgUsingALCInt {
    id<ALCDependency> arg = AcInt(5);
    [self invokeSelector:@selector(setAnInt:) arguments:@[arg]];
    XCTAssertEqual(5, self.anInt);
}

#pragma mark - ALCString

-(void) testInjectionInternalUsingALCString {
    [self injectVariable:@"_anInternalString" usingDependency:AcString(@"abc")];
    XCTAssertEqualObjects(@"abc", _anInternalString);
}

-(void) testInjectionPropertyUsingALCString {
    [self injectVariable:@"aString" usingDependency:AcString(@"abc")];
    XCTAssertEqualObjects(@"abc", self.aString);
}

-(void) testInjectionPropertyInternalUsingALCString {
    [self injectVariable:@"_aString" usingDependency:AcString(@"abc")];
    XCTAssertEqualObjects(@"abc", self.aString);
}

-(void) testMethodArgUsingALCString {
    id<ALCDependency> arg = AcString(@"abc");
    [self invokeSelector:@selector(setAString:) arguments:@[arg]];
    XCTAssertEqual(@"abc", self.aString);
}

#pragma mark - ALCCGRect

-(void) testInjectionInternalUsingALCCGRect {
    [self injectVariable:@"_anInternalCGRect" usingDependency:AcCGRect(CGRectMake(0.0, 0.0, 100.0, 100.0))];
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0.0, 0.0, 100.0, 100.0), _anInternalCGRect));
}

-(void) testInjectionPropertyUsingALCCGRect {
    [self injectVariable:@"aCGRect" usingDependency:AcCGRect(CGRectMake(0.0, 0.0, 100.0, 100.0))];
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0.0, 0.0, 100.0, 100.0), self.aCGRect));
}

-(void) testInjectionPropertyInternalUsingALCCGRect {
    [self injectVariable:@"_aCGRect" usingDependency:AcCGRect(CGRectMake(0.0, 0.0, 100.0, 100.0))];
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0.0, 0.0, 100.0, 100.0), self.aCGRect));
}

-(void) testMethodArgUsingALCCGRect {
    id<ALCDependency> arg = AcCGRect(CGRectMake(0.0, 0.0, 100.0, 100.0));
    [self invokeSelector:@selector(setACGRect:) arguments:@[arg]];
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0.0, 0.0, 100.0, 100.0), self.aCGRect));
}

#pragma mark - Internal

-(void) injectVariable:(NSString *) variable usingDependency:(id<ALCDependency>) dependency {
    Ivar ivar = [ALCRuntime aClass:[self class] variableForInjectionPoint:variable];
    [dependency setObject:self variable:ivar];
}

@end
