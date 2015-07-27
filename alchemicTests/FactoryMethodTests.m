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

@interface FactoryMethodTests : ALCTestCase
@end

@implementation FactoryMethodTests {
    NSString *string1;
    NSString *string2;
}

AcInject(string1, AcName(@"buildAString"))
AcInject(string2, AcName(@"buildAString"))

-(void) setUp {
    [super setUp];
    STStartLogging(@"is [FactoryMethods]");
    [self setupRealContext];
    [self addClassesToContext:@[[self class], [FactoryMethods class], [Component class]]];
    AcInjectDependencies(self);
}

- (void) testSimpleFactoryMethod {
    XCTAssertTrue([string1 hasPrefix:@"Factory string"]);
    XCTAssertTrue([string2 hasPrefix:@"Factory string"]);
    XCTAssertNotEqualObjects(string1, string2);
}

@end