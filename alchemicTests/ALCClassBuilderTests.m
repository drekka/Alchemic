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
	[_macroProcessor addMacro:ACIsFactory];
	[_builder configureWithMacroProcessor:_macroProcessor];
	XCTAssertTrue(_builder.factory);
	XCTAssertFalse(_builder.createOnBoot);
}

-(void) testConfigureWithmacroProcessorSetsPrimary {
	[_macroProcessor addMacro:ACIsPrimary];
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

	Ivar dependenciesVar = class_getInstanceVariable([ALCClassBuilder class], "_dependencies");
	NSSet<ALCVariableDependency *> *dependencies = object_getIvar(_builder, dependenciesVar);

	XCTAssertEqual(1u,[dependencies count]);
	ALCVariableDependency *dependency = [dependencies anyObject];
	XCTAssertEqual(stringVar, dependency.variable);
}

-(void) testSetInitializerBuilder {
	ALCClassInitializerBuilder *initBuilder = [[ALCClassInitializerBuilder alloc] initWithValueClass:_builder.valueClass];
	_builder.initializerBuilder = initBuilder;
	id<ALCBuilder> parentBuilder = initBuilder.parentClassBuilder;
	XCTAssertEqual(_builder, parentBuilder);
}

-(void) testAddMethodBuilder {
	ALCMethodBuilder *methodBuilder = [[ALCMethodBuilder alloc] initWithValueClass:[NSString class]];
	[_builder addMethodBuilder:methodBuilder];
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

	id mockInitializerBuilder = OCMClassMock([ALCClassInitializerBuilder class]);
	_builder.initializerBuilder = mockInitializerBuilder;
	SimpleObject *object = [[SimpleObject alloc] init];
	OCMExpect([mockInitializerBuilder instantiate]).andReturn(object);

	id resultObject = [_builder instantiateObject];
	XCTAssertEqual(object, resultObject);

	OCMVerifyAll(mockInitializerBuilder);
}

#pragma mark - Injecting

-(void) testInjectObjectDependencies {

	id mockDependency = OCMClassMock([ALCVariableDependency class]);
	Ivar dependenciesVar = class_getInstanceVariable([ALCClassBuilder class], "_dependencies");
	object_setIvar(_builder, dependenciesVar, [NSMutableSet setWithObject:mockDependency]);

	SimpleObject *object = [[SimpleObject alloc] init];
	OCMExpect([mockDependency injectInto:object]);

	[_builder injectObjectDependencies:object];

	OCMVerifyAll(mockDependency);

}

@end
