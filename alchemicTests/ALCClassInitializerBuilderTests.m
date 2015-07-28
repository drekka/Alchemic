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
#import "ALCInitializerMacroProcessor.h"
#import <Alchemic/Alchemic.h>

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

-(void) testInstantiateObjectWithArgument {
	ALCClassBuilder *classBuilder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];

	ALCInitializerMacroProcessor *initMacroProcessor = [[ALCInitializerMacroProcessor alloc] init];
	[initMacroProcessor addMacro:AcArg(NSString, AcValue(@"hello"))];
	[initMacroProcessor validate];

	ignoreSelectorWarnings(
								  ALCClassInitializerBuilder *initBuilder = [[ALCClassInitializerBuilder alloc] initWithSelector:@selector(initWithString:)];
								  )
	classBuilder.initializerBuilder = initBuilder;
	[initBuilder configureWithMacroProcessor:initMacroProcessor];

	SimpleObject *object = classBuilder.value;
	XCTAssertNotNil(object);
	XCTAssertEqualObjects(@"hello", object.aStringProperty);
}

@end
