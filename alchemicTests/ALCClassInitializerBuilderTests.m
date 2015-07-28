//
//  ALCClassInitializerBuilderTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 28/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCClassBuilder.h"
#import "ALCClassInitializerBuilder.h"
#import "SimpleObject.h"
#import "ALCInternalMacros.h"


@interface ALCClassInitializerBuilderTests : XCTestCase

@end

@implementation ALCClassInitializerBuilderTests

-(void) testInstantiateObject {
	ALCClassBuilder *classBuilder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];
	ignoreSelectorWarnings(
								  ALCClassInitializerBuilder *initBuilder = [[ALCClassInitializerBuilder alloc] initWithSelector:@selector(initAlternative)];
	)
	classBuilder.initializerBuilder = initBuilder;

	SimpleObject *object = classBuilder.value;
	XCTAssertNotNil(object);
	XCTAssertEqualObjects(@"xyz", object.aStringProperty);
}


@end
