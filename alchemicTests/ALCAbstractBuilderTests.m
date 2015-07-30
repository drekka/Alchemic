//
//  ALCAbstractBuilderTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <Alchemic/Alchemic.h>

#import "SimpleObject.h"
#import "ALCAbstractBuilder.h"
#import "ALCMacroProcessor.h"
#import <OCMock/OCMock.h>
#import "ALCVariableDependency.h"

@interface FakeBuilder : ALCAbstractBuilder
@property(nonatomic, assign) BOOL resolveDependenciesCalled;
@end

@implementation FakeBuilder

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors {
	self.resolveDependenciesCalled = YES;
}

-(nonnull id) instantiateObject {
	return [[SimpleObject alloc] init];
}

@end

@interface ALCAbstractBuilderTests : XCTestCase {
	FakeBuilder *_builder;
}

@end

#pragma mark - Tests

@implementation ALCAbstractBuilderTests

-(void) setUp {
	_builder = [[FakeBuilder alloc] init];
	_builder.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosFactory + ALCAllowedMacrosPrimary + ALCAllowedMacrosName];
}

-(void) testConfigureFactory {
	[_builder.macroProcessor addMacro:AcIsFactory];
	[_builder configure];
	XCTAssertTrue(_builder.factory);
	XCTAssertFalse(_builder.createOnBoot);
}

-(void) testConfigurePrimary {
	[_builder.macroProcessor addMacro:AcIsPrimary];
	[_builder configure];
	XCTAssertTrue(_builder.primary);
	XCTAssertTrue(_builder.createOnBoot);
}

#pragma mark - Creating objects

-(void) testValueBuildsAndInjects {

	id mockDependency = OCMStrictClassMock([ALCVariableDependency class]);
	OCMExpect([mockDependency injectInto:[OCMArg isKindOfClass:[SimpleObject class]]]);
	[_builder.dependencies addObject:mockDependency];

	id value = _builder.value;

	XCTAssertNotNil(value);
	XCTAssertEqual([SimpleObject class], [value class]);

	OCMVerifyAll(mockDependency);
}

-(void) testValueCachesWhenNotAFactory {
	id value1 = _builder.value;
	id value2 = _builder.value;
	XCTAssertEqual(value1, value2);
}

-(void) testValueCreatesNewValueWHenAFactory {
	_builder.factory = YES;
	id value1 = _builder.value;
	id value2 = _builder.value;
	XCTAssertNotEqual(value1, value2);
}

-(void) testInstantiateCreatesObjectButDoesNotWireIt {
	id mockDependency = OCMStrictClassMock([ALCVariableDependency class]);
	[_builder.dependencies addObject:mockDependency];

	id value = [_builder instantiate];

	XCTAssertNotNil(value);
	XCTAssertEqual([SimpleObject class], [value class]);

	OCMVerifyAll(mockDependency);
}

#pragma mark - Validations

-(void) testValidateClassSelectorWhenNoArgs {
	ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] init];
	[_builder validateClass:[SimpleObject class] selector:@selector(description) macroProcessor:macroProcessor];
}

-(void) testValidateClassSelectorWhenUnknownSelector {
	ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] init];
	ignoreSelectorWarnings(
								  XCTAssertThrowsSpecificNamed([_builder validateClass:[SimpleObject class] selector:@selector(xxxx) macroProcessor:macroProcessor], NSException, @"AlchemicSelectorNotFound");
								  )
}

-(void) testValidateArgumentsForSelector {
	ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
	ignoreSelectorWarnings(
								  [_builder validateClass:[SimpleObject class] selector:@selector(stringFactoryMethodUsingAString:) macroProcessor:macroProcessor];
								  )
}

-(void) testValidateArgumentsForSelectorWithToFewNumberArguments {
	ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] init];
	XCTAssertThrowsSpecificNamed([_builder validateClass:[SimpleObject class] selector:@selector(stringFactoryMethodUsingAString:) macroProcessor:macroProcessor], NSException, @"AlchemicIncorrectNumberArguments");
}

-(void) testValidateArgumentsForSelectorWithToManyNumberArguments {
	ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
	[macroProcessor addMacro:AcArg(NSString, AcValue(@"def"))];
	XCTAssertThrowsSpecificNamed([_builder validateClass:[SimpleObject class] selector:@selector(stringFactoryMethodUsingAString:) macroProcessor:macroProcessor], NSException, @"AlchemicIncorrectNumberArguments");
}
#pragma mark - Injecting

-(void) testInjectObjectDependencies {

	id mockDependency = OCMClassMock([ALCVariableDependency class]);
	[_builder.dependencies addObject:mockDependency];

	SimpleObject *object = [[SimpleObject alloc] init];
	OCMExpect([mockDependency injectInto:object]);

	[_builder injectValueDependencies:object];

	OCMVerifyAll(mockDependency);
	
}


@end
