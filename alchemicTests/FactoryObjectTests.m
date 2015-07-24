//
//  FactoryObjectTests.m
//  alchemic
//
//  Created by Derek Clarkson on 17/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "FactoryObject.h"
#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

@interface FactoryObjectTests : ALCTestCase
@end

@implementation FactoryObjectTests {
    FactoryObject *_of1;
    FactoryObject *_of2;
}

AcInject(_of1)
AcInject(_of2, AcClass(FactoryObject))

-(void) setUp {
    [super setUp];
    STStartLogging(@"is [FactoryObject]");
    [self setupRealContext];
    [self addClassesToContext:@[[self class],[FactoryObject class]]];
    AcInjectDependencies(self);
}

-(void) testFactoryClass {
    XCTAssertNotNil(_of1);
    XCTAssertNotNil(_of2);
    XCTAssertNotEqual(_of1, _of2);
}

@end
