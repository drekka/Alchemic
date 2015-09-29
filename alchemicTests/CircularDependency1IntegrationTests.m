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

@interface CD1Object : NSObject
@end

@implementation CD1Object
@end

/**
 This test is based around a variable injection which sources an object from a method on the class that is being injected.
 This should work because the variable injection should trigger after the class is instantiated.
 */
@interface CircularDependency1IntegrationTests : ALCTestCase
@end

@implementation CircularDependency1IntegrationTests {
    CD1Object *_obj;
}

AcInject(_obj, AcName(@"obj"))

AcMethod(CD1Object, newObject, AcWithName(@"obj"))
-(CD1Object *) newObject {
    return [[CD1Object alloc] init];
}

-(void) testIntegrationCircularDependencyWithMethod {
    STStartLogging(ALCHEMIC_LOG);
    STStartLogging(@"is [CircularDependency1IntegrationTests]");
    [self setupRealContext];
    [self startContextWithClasses:@[[CircularDependency1IntegrationTests class]]];
    AcInjectDependencies(self);
    XCTAssertNotNil(_obj);
}

@end
