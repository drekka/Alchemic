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
#import <Alchemic/Alchemic.h>
#import "ALCDependency.h"

@interface ALCAbstractMethodBuilderTests : XCTestCase

@end

@implementation ALCAbstractMethodBuilderTests {
	ALCAbstractMethodBuilder *_builder;
}

-(void) setUp {
	_builder = [[ALCAbstractMethodBuilder alloc] init];
}

-(void) testConfigureWithMacroProcessor {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
	ignoreSelectorWarnings(
								  _builder.selector = @selector(stringFactoryMethodUsingAString:);
								  )
	[_builder configureWithMacroProcessor:macroProcessor];

	Ivar dependenciesVar = class_getInstanceVariable([ALCAbstractMethodBuilder class], "_invArgumentDependencies");
	NSMutableArray<ALCDependency *> *invArgumentDependencies = object_getIvar(_builder, dependenciesVar);
	XCTAssertNotNil(invArgumentDependencies);
	ALCDependency *dependency = invArgumentDependencies[0];
	XCTAssertEqualObjects(@"abc", dependency.value);

}

-(void) testConfigureWithMacroProcessorWithInvalidSelector {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	ignoreSelectorWarnings(
								  _builder.selector = @selector(xxxx);
								  )
	XCTAssertThrowsSpecificNamed([_builder configureWithMacroProcessor:macroProcessor], NSException, @"AlchemicSelectorNotFound");

}

-(void) testConfigureWithMacroProcessorIncorrectNumberArguments {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	_builder.selector = @selector(stringFactoryMethodUsingAString:);
	XCTAssertThrowsSpecificNamed([_builder configureWithMacroProcessor:macroProcessor], NSException, @"AlchemicIncorrectNumberArguments");
}

#pragma mark - Invoking

-(void) testInvokeMethodOn {
	ignoreSelectorWarnings(
								  _builder.selector = @selector(stringFactoryMethod);
								  )
	SimpleObject *object = [[SimpleObject alloc] init];
	NSString *result = [_builder invokeMethodOn:object];
	XCTAssertEqualObjects(@"abc", result);
}


@end
