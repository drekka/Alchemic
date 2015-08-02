//
//  ArraysIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <StoryTeller/StoryTeller.h>

@interface ASObject : NSObject

@end

@implementation ASObject

@end

@interface ArraysIntegrationTests : ALCTestCase

@end

@implementation ArraysIntegrationTests {
	NSArray *_asObjects;
	ASObject *_obj1;
	ASObject *_obj2;
}

AcInject(_asObjects, AcClass(ASObject))
AcInject(_obj1, AcName(@"o1"))
AcInject(_obj2, AcName(@"o2"))

-(void) testNoArgInit {
	STStartLogging(ALCHEMIC_LOG);
	[self setupRealContext];
	[self addClassesToContext:@[[ArraysIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(_asObjects);
	XCTAssertNotNil(_obj1);
	XCTAssertNotNil(_obj2);
	XCTAssertNotEqual(_obj1, _obj2);
	XCTAssertTrue([_asObjects containsObject:_obj1]);
	XCTAssertTrue([_asObjects containsObject:_obj2]);
}


#pragma mark - Factories

AcMethod(ASObject, newAsObject, AcWithName(@"o1"))
AcMethod(ASObject, newAsObject, AcWithName(@"o2"))
-(ASObject *) newAsObject {
	return [[ASObject alloc] init];
}



@end
