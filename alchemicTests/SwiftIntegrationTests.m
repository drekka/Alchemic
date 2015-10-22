//
//  SwiftIntegrationTests.m
//  alchemic
//
//  Created by Derek Clarkson on 22/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>
#import "ALCTestCase.h"
#import "Alchemic_tests-Swift.h"

@interface SwiftIntegrationTests : ALCTestCase

@end

@implementation SwiftIntegrationTests

-(void) testLoadsSwiftObject {

    STStartLogging(@"LogAll");
    STStartLogging(@"is [Alchemic_tests.SwiftObject]");

   	[self setupRealContext];
    [self startContextWithClasses:@[[SwiftObject class]]];

    id obj = AcGet(NSObject, AcClass(SwiftObject));
    XCTAssertNotNil(obj);

    obj = AcGet(NSObject, AcName(@"abc"));
    XCTAssertNotNil(obj);
}

@end
