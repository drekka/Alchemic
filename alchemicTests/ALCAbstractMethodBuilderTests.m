//
//  ALCAbstractMethodBuilderTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCAbstractMethodBuilder.h"
#import "SimpleObject.h"
#import "ALCMacroProcessor.h"
#import "ALCClassBuilder.h"
#import <Alchemic/Alchemic.h>
#import "ALCDependency.h"

@interface ALCAbstractMethodBuilderTests : XCTestCase

@end

@implementation ALCAbstractMethodBuilderTests {
	ALCClassBuilder *_parentBuilder;
}

-(void) setUp {
	_parentBuilder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];
}

-(void) testConfigureWithMacroProcessor {
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
																																								selector:@selector(stringFactoryMethodUsingAString:)];
								  )
	methodBuilder.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
	[methodBuilder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
	[methodBuilder configure];

	ALCDependency *dependency = methodBuilder.dependencies[0];
	XCTAssertEqualObjects(@"abc", dependency.value);
}

-(void) testConfigureWithMacroProcessorWithInvalidSelector {
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
																																								selector:@selector(xxxx)];
								  )
	XCTAssertThrowsSpecificNamed([methodBuilder configure], NSException, @"AlchemicSelectorNotFound");
}

-(void) testConfigureWithMacroProcessorIncorrectNumberArguments {
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
																																								selector:@selector(stringFactoryMethodUsingAString:)];
								  )
	XCTAssertThrowsSpecificNamed([methodBuilder configure], NSException, @"AlchemicIncorrectNumberArguments");
}

#pragma mark - Invoking

-(void) testInvokeMethodOn {
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
																																								selector:@selector(stringFactoryMethod)];
								  )
	SimpleObject *object = [[SimpleObject alloc] init];
	NSString *result = [methodBuilder invokeMethodOn:object];
	XCTAssertEqualObjects(@"abc", result);
}

-(void) testInvokeMethodOnWithArgs {
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
																																								selector:@selector(stringFactoryMethodUsingAString:)];
								  )
	methodBuilder.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
	[methodBuilder.macroProcessor addMacro:AcArg(NSString, AcValue(@"def"))];
	[methodBuilder configure];

	SimpleObject *object = [[SimpleObject alloc] init];
	NSString *result = [methodBuilder invokeMethodOn:object];
	XCTAssertEqualObjects(@"abc", result);
}


@end
