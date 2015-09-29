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

@interface CI3ObjA : NSObject
@end

@interface CI3ObjB : NSObject
@end

@implementation CI3ObjA
AcRegister(AcWithName(@"abc"))
AcMethod(CI3ObjB, createObjB)
-(CI3ObjB *) createObjB {
	return [[CI3ObjB alloc] init];
}
@end

@implementation CI3ObjB
AcMethod(CI3ObjA, createObjA)
-(CI3ObjA *) createObjA {
	return [[CI3ObjA alloc] init];
}
@end

@interface CircularDependency3IntegrationTests : ALCTestCase
@end

@implementation CircularDependency3IntegrationTests {
	CI3ObjA *_objA;
}

AcInject(_objA, AcName(@"abc"))

-(void) testIntegrationCircularDep {
	[self setupRealContext];
	STStartLogging(ALCHEMIC_LOG);
	STStartLogging(@"is [CI3ObjA]");
	STStartLogging(@"is [CI3ObjB]");
	STStartLogging(@"is [CircularDependency3IntegrationTests]");
	[self startContextWithClasses:@[[CI3ObjB class], [CI3ObjA class], [CircularDependency3IntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(_objA);
}

@end
