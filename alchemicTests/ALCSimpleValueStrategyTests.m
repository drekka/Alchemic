//
//  ALCSimpleValueStrategyTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCSimpleValueStrategy.h"
#import "ALCDependency.h"
#import "ALCConstantValueSource.h"

@interface ALCSimpleValueStrategyTests : XCTestCase

@end

@implementation ALCSimpleValueStrategyTests

-(void) testCanResolveDependency {
	ALCSimpleValueStrategy *strategy = [[ALCSimpleValueStrategy alloc] init];
	ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithValue:@5];
	ALCDependency *dependency = [[ALCDependency alloc] initWithValueClass:[NSNumber class]
																				 valueSource:source];
	XCTAssertTrue([strategy canResolveValueForDependency:dependency values:source.values]);
}

@end
