//
//  ArraysIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <StoryTeller/StoryTeller.h>

@interface CD1Object : NSObject
@end

@implementation CD1Object
@end

@interface CircularDependency1IntegrationTests : ALCTestCase
@end

@implementation CircularDependency1IntegrationTests {
	CD1Object *_obj;
}

AcInject(_obj, AcName(@"obj"))

-(void) testNoArgInit {
	STStartLogging(ALCHEMIC_LOG);
	STStartLogging(@"is [CircularDependency1IntegrationTests]");
	[self setupRealContext];
	[self addClassesToContext:@[[CircularDependency1IntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(_obj);
}

AcMethod(CD1Object, newObject, AcWithName(@"obj"))
-(CD1Object *) newObject {
	return [[CD1Object alloc] init];
}

@end
