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

-(void) testIntegrationCircularDep {
	[self setupRealContext];
	STStartLogging(@"LogAll");
	XCTAssertThrowsSpecificNamed(([self startContextWithClasses:@[[Chicken class], [Egg class], [CircularDependency4IntegrationTests class]]]), NSException, @"AlchemicCircularDependency");
}

@end
