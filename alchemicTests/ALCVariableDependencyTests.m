//
//  ALCVariableDependencyTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
@import XCTest;
@import ObjectiveC;
#import <OCmock/OCMock.h>

#import "ALCVariableDependency.h"
#import "ALCValueSource.h"
#import "SimpleObject.h"

@interface ALCVariableDependencyTests : XCTestCase

@end

@implementation ALCVariableDependencyTests

-(void) testInjectsVariable {
	id mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
	OCMStub([mockValueSource valueForType:[NSString class]]).andReturn(@"abc");

	Ivar var = class_getInstanceVariable([SimpleObject class], "_aStringProperty");
	ALCVariableDependency *dependency = [[ALCVariableDependency alloc] initWithVariable:var
																									valueSource:mockValueSource];
	SimpleObject *object = [[SimpleObject alloc] init];

	[dependency injectInto:object];

	XCTAssertEqualObjects(@"abc", object.aStringProperty);
}


@end
