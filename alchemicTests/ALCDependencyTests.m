//
//  ALCDependencyTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <OCMock/OCMock.h>

#import "ALCDependency.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCValueSource.h"
#import "ALCConstantValueSource.h"

@interface ALCDependencyTests : XCTestCase

@end

@implementation ALCDependencyTests

-(void) testHandsOffPostProcessingToValueSource {

	NSSet<id<ALCDependencyPostProcessor>> *postProcessors = [NSSet set];
	id mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
	OCMExpect([mockValueSource resolveWithPostProcessors:postProcessors]);

	ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:mockValueSource];
	[dependency resolveWithPostProcessors:postProcessors];

	OCMVerifyAll(mockValueSource);
}

-(void) testGetsValueFromValueSource {

	id mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
	OCMExpect([(id<ALCValueSource>)mockValueSource value]).andReturn(@"abc");

	ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:mockValueSource];
	id value = dependency.value;
	XCTAssertEqualObjects(@"abc", value);

	OCMVerifyAll(mockValueSource);
}

-(void) testDescription {
    ALCConstantValueSource *valueSource = [[ALCConstantValueSource alloc] initWithType:[NSNumber class] value:@5];
	ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:valueSource];
	XCTAssertEqualObjects(@"type [NSNumber]<NSSecureCoding><NSCopying> from: Constant: 5", [dependency description]);
}

@end
