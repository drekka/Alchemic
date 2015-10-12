//
//  ArraysIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>

/**
 This test is based around a variable injection which sources an object from a method on the class that is being injected.
 This should work because the variable injection should trigger after the class is instantiated.
 */
@interface CircularDependency1IntegrationTests : ALCTestCase
@end

@implementation CircularDependency1IntegrationTests {
    NSNumber *_obj;
}

AcRegister(AcExternal, AcWithName(@"self"))
AcInject(_obj, AcName(@"obj"))

AcMethod(NSNumber, newObject, AcWithName(@"obj"))
-(NSNumber *) newObject {
    return @12;
}

-(void) testIntegrationCircularDependencyWithMethod {
    STStartLogging(ALCHEMIC_LOG);
    STStartLogging(@"is [CircularDependency1IntegrationTests]");
    [self setupRealContext];
    [self startContextWithClasses:@[[CircularDependency1IntegrationTests class]]];
    AcSet(self, AcName(@"self"));
    AcInjectDependencies(self);
    XCTAssertEqualObjects(@12, _obj);
}

@end
