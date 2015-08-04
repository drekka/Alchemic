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
@end

@implementation FakeBuilder

-(nonnull id) instantiateObject {
	return [[SimpleObject alloc] init];
}

-(void)injectValueDependencies:(nonnull id)value {}

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
}

-(void) testConfigurePrimary {
	[_builder.macroProcessor addMacro:AcIsPrimary];
	[_builder configure];
	XCTAssertTrue(_builder.primary);
}

#pragma mark - Create on boot

-(void) testCreateOnBootWhenNotAFactoryAndNoValue {
	[_builder configure];
	XCTAssertTrue(_builder.createOnBoot);
}

-(void) testCreateOnBootWhenAFactoryAndNoValue {
	[_builder.macroProcessor addMacro:AcIsFactory];
	[_builder configure];
	XCTAssertFalse(_builder.createOnBoot);
}

-(void) testCreateOnBootWhenNotAFactoryAndValueSet {
	[_builder configure];
	_builder.value = @"abc";
	XCTAssertFalse(_builder.createOnBoot);
}

-(void) testCreateOnBootWhenAFactoryAndValueSet {
	[_builder.macroProcessor addMacro:AcIsFactory];
	[_builder configure];
	_builder.value = @"abc";
	XCTAssertFalse(_builder.createOnBoot);
}

#pragma mark - Creating objects

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

#pragma mark - Resolving

-(void) testResolveWithPostProcessors {

	NSSet *postProcessors = [NSSet set];
	id mockDependency = OCMClassMock([ALCDependency class]);
	OCMExpect([mockDependency resolveWithPostProcessors:postProcessors]);
	Ivar dependencyVar = class_getInstanceVariable([_builder class], "_dependencies");
	object_setIvar(_builder, dependencyVar, [NSMutableArray arrayWithObject:mockDependency]);

	[_builder resolveWithPostProcessors:postProcessors];

	OCMVerifyAll(mockDependency);

}

-(void) testResolveWithPostProcessorsWhenNoDependencies {
	NSSet *postProcessors = [NSSet set];
	[_builder resolveWithPostProcessors:postProcessors];
	// Does nothing.
}

-(void) testValidateDependencyStack {

	NSMutableArray *stack = [@[] mutableCopy];
	id mockDependency = OCMClassMock([ALCDependency class]);
	OCMExpect([mockDependency validateWithDependencyStack:[OCMArg checkWithBlock:^BOOL(NSMutableArray *passedStack) {
		return [passedStack containsObject:self->_builder];
	}]]);

	Ivar dependencyVar = class_getInstanceVariable([_builder class], "_dependencies");
	object_setIvar(_builder, dependencyVar, [NSMutableArray arrayWithObject:mockDependency]);

	[_builder validateWithDependencyStack:stack];

	OCMVerifyAll(mockDependency);
	
}

-(void) testValidateDependencyThrowsWhenCircularDependencyDetected {
	NSMutableArray *stack = [@[_builder] mutableCopy];
	XCTAssertThrowsSpecificNamed([_builder validateWithDependencyStack:stack], NSException, @"AlchemicCircularDependency");
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

@end
