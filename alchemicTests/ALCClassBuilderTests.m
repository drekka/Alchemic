//
//  ALCClassBuilderTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <Alchemic/Alchemic.h>
#import <OCMock/OCMock.h>

#import "ALCClassBuilder.h"
#import "ALCClassRegistrationMacroProcessor.h"
#import "ALCClassInitializerBuilder.h"
#import "ALCMethodBuilder.h"
#import "ALCVariableDependencyMacroProcessor.h"
#import "SimpleObject.h"
#import "ALCVariableDependency.h"


@interface ALCClassBuilderTests : XCTestCase

@end

@implementation ALCClassBuilderTests {
	ALCClassBuilder *_builder;
	ALCClassRegistrationMacroProcessor *_macroProcessor;
}

-(void) setUp {
	_macroProcessor = [[ALCClassRegistrationMacroProcessor alloc] init];
	_builder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];
}

#pragma mark - Configuration

-(void) testConfigureWithmacroProcessorSetsFactory {
	[_macroProcessor addMacro:AcIsFactory];
	[_builder configureWithMacroProcessor:_macroProcessor];
	XCTAssertTrue(_builder.factory);
	XCTAssertFalse(_builder.createOnBoot);
}

-(void) testConfigureWithmacroProcessorSetsPrimary {
	[_macroProcessor addMacro:AcIsPrimary];
	[_builder configureWithMacroProcessor:_macroProcessor];
	XCTAssertTrue(_builder.primary);
	XCTAssertTrue(_builder.createOnBoot);
}

-(void) testConfigureWithmacroProcessorSetsName {
	[_builder configureWithMacroProcessor:_macroProcessor];
	XCTAssertEqualObjects(@"SimpleObject", _builder.name);
}

-(void) testConfigureWithmacroProcessorSetsCustomName {
	[_macroProcessor addMacro:AcWithName(@"abc")];
	[_builder configureWithMacroProcessor:_macroProcessor];
	XCTAssertEqualObjects(@"abc", _builder.name);
}

#pragma mark - Other methods

-(void) testAddVariableInjection {

	Ivar stringVar = class_getInstanceVariable([SimpleObject class], "_aStringProperty");
	ALCVariableDependencyMacroProcessor *dependencyMacroProcessor = [[ALCVariableDependencyMacroProcessor alloc] initWithVariable:stringVar];
	[dependencyMacroProcessor addMacro:AcValue(@"abc")];

	[_builder addVariableInjection:dependencyMacroProcessor];

	ALCVariableDependency *dependency = (ALCVariableDependency *)_builder.dependencies[0];
	XCTAssertEqual(stringVar, dependency.variable);
}

-(void) testCreatesInitializerBuilder {
	ALCClassInitializerBuilder *initBuilder = [_builder createInitializerBuilderForSelector:@selector(init)];
	XCTAssertNotNil(initBuilder);
	id<ALCBuilder> parentBuilder = initBuilder.parentClassBuilder;
	XCTAssertEqual(_builder, parentBuilder);
}

-(void) testAddMethodBuilder {
	ignoreSelectorWarnings(
								  ALCMethodBuilder *methodBuilder = [_builder createMethodBuilderForSelector:@selector(stringFactoryMethod)
																														valueClass:[NSString class]];
								  )
	id<ALCBuilder> parentBuilder = methodBuilder.parentClassBuilder;
	XCTAssertEqual(_builder, parentBuilder);
}

-(void) testResolveDependencies {

	id mockDependency = OCMClassMock([ALCVariableDependency class]);
	Ivar dependenciesVar = class_getInstanceVariable([ALCClassBuilder class], "_dependencies");
	object_setIvar(_builder, dependenciesVar, [NSMutableSet setWithObject:mockDependency]);

	NSSet<id<ALCDependencyPostProcessor>> *postProcessors = [NSSet set];
	OCMExpect([mockDependency resolveWithPostProcessors:postProcessors]);

	[_builder resolveDependenciesWithPostProcessors:postProcessors];

	OCMVerifyAll(mockDependency);

}

#pragma mark - Instantiating

-(void) testInstantiateObjectViaInit {
	id object = [_builder instantiateObject];
	XCTAssertEqual([SimpleObject class], [object class]);
}

-(void) testInstantiateObjectUsingInitializer {
	[_builder createInitializerBuilderForSelector:@selector(init)];
	id resultObject = [_builder instantiateObject];
	XCTAssertTrue([resultObject isKindOfClass:[SimpleObject class]]);
}

@end
