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
@end

@implementation ALCConstantsTests

-(void) testInjectionUsingALCInt {
    [self injectVariable:@"anInt" usingDependency:ALCInt(5)];
    XCTAssertEqual(5, self.anInt);
}

-(void) testMethodArgUsingALCInt {
    id<ALCDependency> arg = ALCInt(5);
    [self invokeSelector:@selector(setAnInt:) arguments:@[arg]];
    XCTAssertEqual(5, self.anInt);
}

#pragma mark - Internal

-(void) injectVariable:(NSString *) variable usingDependency:(id<ALCDependency>) dependency {
    Ivar ivar = [ALCRuntime aClass:[self class] variableForInjectionPoint:variable];
    [dependency setObject:self variable:ivar];
}

@end
