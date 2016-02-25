//
//  ALCConstantsTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCDependency.h"
#import "ALCConstants.h"
#import "ALCRuntime.h"
#import "NSObject+Alchemic.h"

@interface ALCConstantsTests : XCTestCase
@property (nonatomic, assign) int anInt;
@property (nonatomic, strong) NSString *aString;
@end

@implementation ALCConstantsTests {
    int _anInternalInt;
    NSString *_anInternalString;
}

#pragma mark - ACInt

-(void) testInjectionInternalUsingALCInt {
    [self injectVariable:@"_anInternalInt" usingDependency:ALCInt(5)];
    XCTAssertEqual(5, _anInternalInt);
}

-(void) testInjectionPropertyUsingALCInt {
    [self injectVariable:@"anInt" usingDependency:ALCInt(5)];
    XCTAssertEqual(5, self.anInt);
}

-(void) testInjectionPropertyInternalUsingALCInt {
    [self injectVariable:@"_anInt" usingDependency:ALCInt(5)];
    XCTAssertEqual(5, self.anInt);
}

-(void) testMethodArgUsingALCInt {
    id<ALCDependency> arg = ALCInt(5);
    [self invokeSelector:@selector(setAnInt:) arguments:@[arg]];
    XCTAssertEqual(5, self.anInt);
}

#pragma mark - ACString

-(void) testInjectionInternalUsingALCString {
    [self injectVariable:@"_anInternalString" usingDependency:ALCString(@"abc")];
    XCTAssertEqualObjects(@"abc", _anInternalString);
}

-(void) testInjectionPropertyUsingALCString {
    [self injectVariable:@"aString" usingDependency:ALCString(@"abc")];
    XCTAssertEqualObjects(@"abc", self.aString);
}

-(void) testInjectionPropertyInternalUsingALCString {
    [self injectVariable:@"_aString" usingDependency:ALCString(@"abc")];
    XCTAssertEqualObjects(@"abc", self.aString);
}

-(void) testMethodArgUsingALCString {
    id<ALCDependency> arg = ALCString(@"abc");
    [self invokeSelector:@selector(setAString:) arguments:@[arg]];
    XCTAssertEqual(@"abc", self.aString);
}

#pragma mark - Internal

-(void) injectVariable:(NSString *) variable usingDependency:(id<ALCDependency>) dependency {
    Ivar ivar = [ALCRuntime aClass:[self class] variableForInjectionPoint:variable];
    [dependency setObject:self variable:ivar];
}

@end
