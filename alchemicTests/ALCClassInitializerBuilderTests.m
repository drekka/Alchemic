//
//  ALCClassInitializerBuilderTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 28/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>
@import XCTest;

#import "ALCClassBuilder.h"
#import "ALCClassInitializerBuilder.h"
#import "SimpleObject.h"
#import "ALCMacroProcessor.h"

@interface ALCClassInitializerBuilderTests : XCTestCase

@end

@implementation ALCClassInitializerBuilderTests

-(void) testInstantiateObject {
	ignoreSelectorWarnings(
								  SimpleObject *object = [self runTestWithInitializer:@selector(initAlternative) macros:@[]];
								  )
	XCTAssertEqualObjects(@"xyz", object.aStringProperty);
}

-(void) testInstantiateObjectWithArgument {
	STStartLogging(ALCHEMIC_LOG);
	SimpleObject *object = [self runTestWithInitializer:@selector(initWithString:) macros:@[AcArg(NSString, AcValue(@"hello"))]];
	XCTAssertEqualObjects(@"hello", object.aStringProperty);
}

#pragma mark - Internal

-(SimpleObject *) runTestWithInitializer:(SEL) initializer macros:(NSArray<id<ALCMacro>> *) macros {

	ALCClassBuilder *classBuilder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];
	ALCClassInitializerBuilder *initBuilder = [[ALCClassInitializerBuilder alloc] initWithParentClassBuilder:classBuilder
																																	selector:initializer];
	for (id<ALCMacro> macro in macros) {
		[initBuilder.macroProcessor addMacro:macro];
	}
	[initBuilder configure];

	SimpleObject *object = initBuilder.value;
	XCTAssertNotNil(object);
	return object;
}

@end
