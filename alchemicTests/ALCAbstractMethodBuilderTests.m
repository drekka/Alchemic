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
	ALCAbstractMethodBuilder *_methodBuilder;
}

-(void) setUp {
	_parentBuilder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];
}

-(void) testConfigureWithMacroProcessor {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithSelector:@selector(stringFactoryMethodUsingAString:)];
								  )
	methodBuilder.parentClassBuilder = _parentBuilder;
	[methodBuilder configureWithMacroProcessor:macroProcessor];

	Ivar dependenciesVar = class_getInstanceVariable([ALCAbstractMethodBuilder class], "_invArgumentDependencies");
	NSMutableArray<ALCDependency *> *invArgumentDependencies = object_getIvar(methodBuilder, dependenciesVar);
	XCTAssertNotNil(invArgumentDependencies);
	ALCDependency *dependency = invArgumentDependencies[0];
	XCTAssertEqualObjects(@"abc", dependency.value);
}

-(void) testConfigureWithMacroProcessorWithInvalidSelector {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	ignoreSelectorWarnings(
								  ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithSelector:@selector(xxxx)];
								  )
	methodBuilder.parentClassBuilder = _parentBuilder;
	XCTAssertThrowsSpecificNamed([_methodBuilder configureWithMacroProcessor:macroProcessor], NSException, @"AlchemicSelectorNotFound");

}

-(void) testConfigureWithMacroProcessorIncorrectNumberArguments {
	ALCMethodMacroProcessor *macroProcessor = [[ALCMethodMacroProcessor alloc] init];
	//_methodBuilder.selector = @selector(stringFactoryMethodUsingAString:);
	XCTAssertThrowsSpecificNamed([_methodBuilder configureWithMacroProcessor:macroProcessor], NSException, @"AlchemicIncorrectNumberArguments");
}

#pragma mark - Invoking

-(void) testInvokeMethodOn {
	ignoreSelectorWarnings(
	//							  _methodBuilder.selector = @selector(stringFactoryMethod);
								  )
	SimpleObject *object = [[SimpleObject alloc] init];
	NSString *result = [_methodBuilder invokeMethodOn:object];
	XCTAssertEqualObjects(@"abc", result);
}


@end
