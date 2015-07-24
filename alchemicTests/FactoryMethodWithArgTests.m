//
//  FactoryTests.m
//  alchemic
//
//  Created by Derek Clarkson on 14/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>

#import "Component.h"
#import "ALCTestCase.h"
#import "FactoryMethods.h"
#import "Component.h"
#import <StoryTeller/StoryTeller.h>

@interface FactoryMethodWithArgTests : ALCTestCase
@end

@implementation FactoryMethodWithArgTests {
    NSString *string3;
    NSString *string4;
}

AcInject(string3, AcName(@"buildAComponentString"))
AcInject(string4, AcName(@"buildAComponentString"))

-(void) setUp {
    [super setUp];
    STStartLogging(@"is [FactoryMethodWithArgTests]");
    STStartLogging(ALCHEMIC_LOG);
    [self setupRealContext];
    [self addClassesToContext:@[[self class], [FactoryMethods class], [Component class]]];
    AcInjectDependencies(self);
}

-(void) testFactoryMethodWithComponentArgument {
    XCTAssertTrue([string3 hasPrefix:@"Component Factory string"]);
    XCTAssertTrue([string4 hasPrefix:@"Component Factory string"]);
    XCTAssertNotEqualObjects(string3, string4);
}

@end
