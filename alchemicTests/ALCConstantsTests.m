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

@interface ALCConstantsTests : XCTestCase
@property (nonatomic, assign) int anInt;
@property (nonatomic, strong) NSString *aString;
@property (nonatomic, assign) CGRect aCGRect;
-(NSNumber *) doWithInt:(int) aInt;
@end

@implementation ALCConstantsTests {
    int _anInternalInt;
    NSString *_anInternalString;
    CGRect _anInternalCGRect;
}

-(NSNumber *) doWithInt:(int) aInt {
    _anInt = aInt;
    return @(aInt);
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
    id<ALCInjector> arg = AcInt(5);
    id<ALCDependency> dep = [ALCMethodArgument argumentWithClass:[NSObject class] criteria:arg, nil];
    id result = [self invokeSelector:@selector(doWithInt:) arguments:@[dep]];
    XCTAssertEqual(5, self.anInt);
    XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
    XCTAssertEqual(5, ((NSNumber *)result).intValue);
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

//-(void) testMethodArgUsingALCString {
//    id<ALCInjector> arg = AcString(@"abc");
//    id<ALCDependency> dep = [ALCMethodArgument argumentWithClass:[NSObject class] criteria:arg, nil];
//    [self invokeSelector:@selector(setAString:) arguments:@[dep]];
//    XCTAssertEqual(@"abc", self.aString);
//}

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

//-(void) testMethodArgUsingALCCGRect {
//    id<ALCInjector> arg = AcCGRect(CGRectMake(0.0, 0.0, 100.0, 100.0));
//    id<ALCDependency> dep = [ALCMethodArgument argumentWithClass:[NSObject class] criteria:arg, nil];
//    [self invokeSelector:@selector(setACGRect:) arguments:@[dep]];
//    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0.0, 0.0, 100.0, 100.0), self.aCGRect));
//}

#pragma mark - Internal

-(void) injectVariable:(NSString *) variable usingDependency:(id<ALCInjector>) dependency {
    Ivar ivar = [ALCRuntime aClass:[self class] variableForInjectionPoint:variable];
    [dependency setObject:self variable:ivar];
}

@end
