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
#import "ALCMacroProcessor.h"
#import "ALCClassInitializerBuilder.h"
#import "ALCMethodBuilder.h"
#import "SimpleObject.h"
#import "ALCVariableDependency.h"


@interface ALCClassBuilderTests : XCTestCase

@end

@implementation ALCClassBuilderTests {
	ALCClassBuilder *_builder;
}

-(void) setUp {
	_builder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];
}

#pragma mark - Configuration

-(void) testConfigureSetsFactory {
	[_builder.macroProcessor addMacro:AcIsFactory];
	[_builder configure];
	XCTAssertTrue(_builder.factory);
}

-(void) testConfigureSetsPrimary {
	[_builder.macroProcessor addMacro:AcIsPrimary];
	[_builder configure];
	XCTAssertTrue(_builder.primary);
}

-(void) testConfigureSetsName {
	[_builder configure];
	XCTAssertEqualObjects(@"SimpleObject", _builder.name);
}

-(void) testConfigureSetsCustomName {
	[_builder.macroProcessor addMacro:AcWithName(@"abc")];
	[_builder configure];
	XCTAssertEqualObjects(@"abc", _builder.name);
}

#pragma mark - Other methods

-(void) testAddVariableInjection {

	Ivar stringVar = class_getInstanceVariable([SimpleObject class], "_aStringProperty");

	ALCMacroProcessor *dependencyMacroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosValueDef];
	[dependencyMacroProcessor addMacro:AcValue(@"abc")];

	[_builder addVariableInjection:stringVar macroProcessor:dependencyMacroProcessor];

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

	[_builder resolveWithPostProcessors:postProcessors];

	OCMVerifyAll(mockDependency);

}

-(void) testResolveDependenciesCascadesToInitializer {

	id mockDependency = OCMClassMock([ALCVariableDependency class]);
	Ivar dependenciesVar = class_getInstanceVariable([ALCClassBuilder class], "_dependencies");
	object_setIvar(_builder, dependenciesVar, [NSMutableSet setWithObject:mockDependency]);

	id mockInitializer = OCMClassMock([ALCClassInitializerBuilder class]);
	Ivar initializerVar = class_getInstanceVariable([ALCClassBuilder class], "_initializerBuilder");
	object_setIvar(_builder, initializerVar, mockInitializer);

	NSSet<id<ALCDependencyPostProcessor>> *postProcessors = [NSSet set];
	OCMExpect([mockDependency resolveWithPostProcessors:postProcessors]);
	OCMExpect([mockInitializer resolveWithPostProcessors:postProcessors]);

	[_builder resolveWithPostProcessors:postProcessors];

	OCMVerifyAll(mockDependency);
	OCMVerifyAll(mockInitializer);

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
