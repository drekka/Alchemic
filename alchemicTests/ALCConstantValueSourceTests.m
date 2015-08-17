//
//  ALCConstantValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCConstantValueSource.h"

@interface ALCConstantValueSourceTests : XCTestCase

@end

@implementation ALCConstantValueSourceTests

-(void) testStoresValues {
	ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:[NSNumber class] value:@5];
	XCTAssertEqualObjects(@5, [source.values anyObject]);
}

-(void) testSetsResolved {
    ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:[NSNumber class] value:@5];
	[source resolveWithPostProcessors:[NSSet set]];
	XCTAssertTrue(source.resolved);
}

-(void) testValidateDoesNothing {
    ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:[NSNumber class] value:@5];
	[source validateWithDependencyStack:[@[] mutableCopy]];
}

@end
