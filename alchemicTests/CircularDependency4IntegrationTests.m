//
//  CircularDependency2IntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 2/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

@interface Chicken : NSObject
@end

@interface Egg : NSObject
@end

@implementation Chicken
AcInitializer(initWithEgg:, AcWithName(@"A chicken"), AcArg(Egg, AcClass(Egg)))
-(instancetype) initWithEgg:(Egg *) egg {
	return [[Chicken alloc] init];
}
@end

@implementation Egg
AcInitializer(initWithChicken:, AcArg(Chicken, AcClass(Chicken)))
-(instancetype) initWithChicken:(Chicken *) chicken {
	return [[Egg alloc] init];
}
@end

@interface CircularDependency4IntegrationTests : ALCTestCase
@end

@implementation CircularDependency4IntegrationTests {
	Chicken *_chicken;
}

AcInject(_chicken, AcName(@"A chicken"))

-(void) testCircularDep {
	[self setupRealContext];
	STStartLogging(ALCHEMIC_LOG);
	STStartLogging(@"is [Chicken]");
	STStartLogging(@"is [Egg]");
	STStartLogging(@"is [CircularDependency4IntegrationTests]");
	XCTAssertThrowsSpecificNamed(([self addClassesToContext:@[[Chicken class], [Egg class], [CircularDependency4IntegrationTests class]]]), NSException, @"AlchemicCircularDependency");
	AcInjectDependencies(self);
	XCTAssertNotNil(_chicken);
}

@end
