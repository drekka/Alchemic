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
#import "ALCMethodMacroProcessor.h"
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
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
																																								selector:@selector(stringFactoryMethodUsingAString:)];
								  )
	[methodBuilder configureWithMacroProcessor:macroProcessor];

	ALCDependency *dependency = methodBuilder.dependencies[0];
	XCTAssertEqualObjects(@"abc", dependency.value);
}

-(void) testConfigureWithMacroProcessorWithInvalidSelector {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
																																								selector:@selector(xxxx)];
								  )
	XCTAssertThrowsSpecificNamed([methodBuilder configureWithMacroProcessor:macroProcessor], NSException, @"AlchemicSelectorNotFound");

}

-(void) testConfigureWithMacroProcessorIncorrectNumberArguments {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
																																								selector:@selector(stringFactoryMethodUsingAString:)];
								  )
	XCTAssertThrowsSpecificNamed([methodBuilder configureWithMacroProcessor:macroProcessor], NSException, @"AlchemicIncorrectNumberArguments");
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

	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"def"))];
	[methodBuilder configureWithMacroProcessor:macroProcessor];

	SimpleObject *object = [[SimpleObject alloc] init];
	NSString *result = [methodBuilder invokeMethodOn:object];
	XCTAssertEqualObjects(@"abc", result);
}


@end
