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

@interface ObjA : NSObject
@property (nonatomic, strong) id objB;
@end

@interface ObjB : NSObject
@property (nonatomic, strong) id objA;
@end

@implementation ObjA
AcInject(objB, AcClass(ObjB))
@end

@implementation ObjB
AcInject(objA, AcClass(ObjA))
@end

@interface CircularDependency2IntegrationTests : ALCTestCase
@end

@implementation CircularDependency2IntegrationTests {
	ObjA *_objA;
}

AcInject(_objA)

-(void) testCircularDep {
	[self setupRealContext];
	//STStartLogging(ALCHEMIC_LOG);
	STStartLogging(@"is [ObjA]");
	STStartLogging(@"is [ObjB]");
	STStartLogging(@"is [CircularDependency2IntegrationTests]");
	[self addClassesToContext:@[[ObjB class], [ObjA class], [CircularDependency2IntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(_objA);
}

@end
