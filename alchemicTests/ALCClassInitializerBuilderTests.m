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
	ALCInitializerMacroProcessor *initMacroProcessor = [[ALCInitializerMacroProcessor alloc] init];
	ignoreSelectorWarnings(
								  SimpleObject *object = [self runTestWithMacroProcessor:initMacroProcessor
																							initializer:@selector(initAlternative)];
								  )
	XCTAssertEqualObjects(@"xyz", object.aStringProperty);
}

-(void) testInstantiateObjectWithArgument {
	ALCInitializerMacroProcessor *initMacroProcessor = [[ALCInitializerMacroProcessor alloc] init];
	[initMacroProcessor addMacro:AcArg(NSString, AcValue(@"hello"))];
	SimpleObject *object = [self runTestWithMacroProcessor:initMacroProcessor
															 initializer:@selector(initWithString:)];
	XCTAssertEqualObjects(@"hello", object.aStringProperty);
}

-(SimpleObject *) runTestWithMacroProcessor:(ALCInitializerMacroProcessor *) initMacroProcessor
										  initializer:(SEL) initializer {

	ALCClassBuilder *classBuilder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];

	ALCClassInitializerBuilder *initBuilder = [classBuilder createInitializerBuilderForSelector:initializer];
	[initBuilder configureWithMacroProcessor:initMacroProcessor];

	SimpleObject *object = classBuilder.value;
	XCTAssertNotNil(object);
	return object;
}

@end
