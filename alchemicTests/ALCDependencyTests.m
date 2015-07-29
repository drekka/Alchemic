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

@interface ALCDependencyTests : XCTestCase

@end

@implementation ALCDependencyTests

-(void) testHandsOffPostProcessingToValueSource {

	NSSet<id<ALCDependencyPostProcessor>> *postProcessors = [NSSet set];
	id mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
	OCMExpect([mockValueSource resolveWithPostProcessors:postProcessors]);

	ALCDependency *dependency = [[ALCDependency alloc] initWithValueClass:[NSString class] valueSource:mockValueSource];
	[dependency resolveWithPostProcessors:postProcessors];

	OCMVerifyAll(mockValueSource);
}

-(void) testGetsValueFromValueSource {

	id mockValueSource = OCMProtocolMock(@protocol(ALCValueSource));
	OCMExpect([mockValueSource valueForType:[NSString class]]).andReturn(@"abc");

	ALCDependency *dependency = [[ALCDependency alloc] initWithValueClass:[NSString class] valueSource:mockValueSource];
	id value = dependency.value;
	XCTAssertEqualObjects(@"abc", value);

	OCMVerifyAll(mockValueSource);
}

@end
