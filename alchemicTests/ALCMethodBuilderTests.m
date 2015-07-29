//
//  ALCMethodBuilderTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 28/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <Alchemic/Alchemic.h>

#import "ALCMethodBuilder.h"
#import "ALCMethodMacroProcessor.h"
#import "ALCClassBuilder.h"
#import "SimpleObject.h"
#import "ALCInternalMacros.h"

@interface ALCMethodBuilderTests : XCTestCase

@end

@implementation ALCMethodBuilderTests {
	ALCClassBuilder *_parentBuilder;
}

-(void) setUp {
	_parentBuilder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];
}

-(void) testConfigureWithMacroProcessorIsFactory {
	ignoreSelectorWarnings(
								  ALCMethodBuilder *methodBuilder = [self createBuilderWithSelector:@selector(stringFactoryMethod)
																												 macros:@[AcIsFactory]];
								  )
	XCTAssertTrue(methodBuilder.factory);
	XCTAssertFalse(methodBuilder.createOnBoot);
}

-(void) testConfigureWithMacroProcessorIsPrimary {
	ignoreSelectorWarnings(
								  ALCMethodBuilder *methodBuilder = [self createBuilderWithSelector:@selector(stringFactoryMethod)
																												 macros:@[AcIsPrimary]];
								  )
	XCTAssertTrue(methodBuilder.primary);
}

-(void) testConfigureWithMacroProcessorDefaultName {
	ignoreSelectorWarnings(
								  ALCMethodBuilder *methodBuilder = [self createBuilderWithSelector:@selector(stringFactoryMethod)
																												 macros:@[]];
								  )
	XCTAssertEqualObjects(@"SimpleObject::stringFactoryMethod", methodBuilder.name);
}

-(void) testConfigureWithMacroProcessorName {
	ignoreSelectorWarnings(
								  ALCMethodBuilder *methodBuilder = [self createBuilderWithSelector:@selector(stringFactoryMethod)
																												 macros:@[AcWithName(@"abc")]];
								  )
	XCTAssertEqualObjects(@"abc", methodBuilder.name);
}

-(void) testInstantiate {
	ignoreSelectorWarnings(
								  ALCMethodBuilder *methodBuilder = [self createBuilderWithSelector:@selector(stringFactoryMethod)
																												 macros:@[]];
								  )
	id value = [methodBuilder instantiate];
	XCTAssertNotNil(value);
	XCTAssertEqualObjects(@"abc", value);
}

#pragma mark - Internal

-(ALCMethodBuilder *) createBuilderWithSelector:(SEL) selector
													  macros:(NSArray<id<ALCMacro>> *) macros {
	ignoreSelectorWarnings(
								  ALCMethodBuilder *methodBuilder = [_parentBuilder createMethodBuilderForSelector:selector
																																valueClass:[NSString class]];
								  )
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	for (id<ALCMacro> macro in macros) {
		[macroProcessor addMacro:macro];
	}

	[methodBuilder configureWithMacroProcessor:macroProcessor];
	return methodBuilder;
}



@end
