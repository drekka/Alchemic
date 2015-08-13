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

@implementation ALCVariableDependencyTests {
	ALCVariableDependency *_dependency;
}

-(void) setUp {
	id mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
	OCMStub([mockValueSource valueForType:[NSString class]]).andReturn(@"abc");

	Ivar var = class_getInstanceVariable([SimpleObject class], "_aStringProperty");
	_dependency = [[ALCVariableDependency alloc] initWithVariable:var
																	  valueSource:mockValueSource];
}

-(void) testInjectsVariable {
	SimpleObject *object = [[SimpleObject alloc] init];
	[_dependency injectInto:object];
	XCTAssertEqualObjects(@"abc", object.aStringProperty);
}

-(void) testValidateWithDependencyStackDoesNothing {
	[_dependency validateWithDependencyStack:[@[] mutableCopy]];
}

-(void) testDescription {
	XCTAssertEqualObjects(@"_aStringProperty = type [NSString]<NSMutableCopying><NSSecureCoding><NSCopying> from: OCMockObject(ALCValueSource)", [_dependency description]);
}

@end
