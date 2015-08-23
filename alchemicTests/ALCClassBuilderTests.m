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
    [self configureWithMacros:@[AcFactory]];
	XCTAssertTrue(_builder.factory);
}

-(void) testConfigureSetsPrimary {
    [self configureWithMacros:@[AcPrimary]];
	XCTAssertTrue(_builder.primary);
}

-(void) testConfigureSetsName {
    [self configureWithMacros:@[]];
	XCTAssertEqualObjects(@"SimpleObject", _builder.name);
}

-(void) testConfigureSetsCustomName {
    [self configureWithMacros:@[AcWithName(@"abc")]];
	XCTAssertEqualObjects(@"abc", _builder.name);
}

#pragma mark - Other methods

-(void) testAddVariableInjection {

	Ivar stringVar = class_getInstanceVariable([SimpleObject class], "_aStringProperty");

	ALCMacroProcessor *dependencyMacroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosValue];
	[dependencyMacroProcessor addMacro:AcValue(@"abc")];

    [_builder addVariableInjection:stringVar class:[NSString class] macroProcessor:dependencyMacroProcessor];

	ALCVariableDependency *dependency = (ALCVariableDependency *)_builder.dependencies[0];
	XCTAssertEqual(stringVar, dependency.variable);
}

-(void) testAddVariableInjectionAddsKVOWatch {

    Ivar stringVar = class_getInstanceVariable([SimpleObject class], "_aStringProperty");

    ALCMacroProcessor *dependencyMacroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosValue];
    [dependencyMacroProcessor addMacro:AcValue(@"abc")];

    [_builder addVariableInjection:stringVar class:[NSString class] macroProcessor:dependencyMacroProcessor];
    ALCVariableDependency *dependency = (ALCVariableDependency *)_builder.dependencies[0];

    [_builder resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertTrue(dependency.available);
    XCTAssertTrue(_builder.available);
}

-(void) testResolveDependencies {

	id mockDependency = OCMClassMock([ALCVariableDependency class]);
	[self injectDependencies:@[mockDependency]];

	NSSet<id<ALCDependencyPostProcessor>> *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
	OCMExpect([mockDependency resolveWithPostProcessors:postProcessors dependencyStack:stack]);

	[_builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

	OCMVerifyAll(mockDependency);

}

#pragma mark - Instantiating

-(void) testAvailableWhenNotExternalAndValueSet {
    [self configureWithMacros:@[]];
    _builder.value = [[SimpleObject alloc] init];
    XCTAssertTrue(_builder.available);
}

-(void) testAvailableWhenNotExternalAndNoValue {
    [self configureWithMacros:@[]];
    XCTAssertTrue(_builder.available);
}

-(void) testAvailableWhenExternalAndValueSet {
    _builder.external = YES;
    [self configureWithMacros:@[]];
    _builder.value = [[SimpleObject alloc] init];
    XCTAssertTrue(_builder.available);
}

-(void) testAvailableWhenExternalAndNoValue {
    _builder.external = YES;
    [self configureWithMacros:@[]];
    XCTAssertFalse(_builder.available);
}

-(void) testInstantiateObjectViaInit {
	id object = [_builder instantiateObject];
	XCTAssertEqual([SimpleObject class], [object class]);
}

-(void) testValueInstantiatesObject {
    [self configureWithMacros:@[]];
    id object = _builder.value;
    XCTAssertEqual([SimpleObject class], [object class]);
}

-(void) testValueWhenExternalAndNoValueThrows {
    _builder.external = YES;
    XCTAssertThrowsSpecificNamed([_builder value], NSException, @"AlchemicCannotCreateValue");
}

-(void) testValueWhenExternalAndValueSet {
    _builder.external = YES;
    [self configureWithMacros:@[]];
    SimpleObject *so = [[SimpleObject alloc] init];
    _builder.value = so;
    XCTAssertEqual(so, _builder.value);
}

#pragma mark - Injecting

-(void) testInjecting {

	SimpleObject *object = [[SimpleObject alloc] init];

	id mockDependency = OCMClassMock([ALCVariableDependency class]);
    [self injectDependencies:@[mockDependency]];
	OCMExpect([mockDependency injectInto:object]);

	[_builderinjectDependencies:object];

	XCTAssertTrue(object.didInject);
	OCMVerifyAll(mockDependency);
}

-(void) testDidInjectDependenciesCalledWhenNoDependencies {

	SimpleObject *object = [[SimpleObject alloc] init];
    [self injectDependencies:@[]];

	[_builderinjectDependencies:object];

	XCTAssertTrue(object.didInject);
}

#pragma mark - Description

-(void) testDescription {
    XCTAssertEqualObjects(@"  'SimpleObject' Class builder for type SimpleObject", [_builder description]);
}

-(void) testDescriptionWhenExternal {
    _builder.external = YES;
    XCTAssertEqualObjects(@"  'SimpleObject' Class builder for type SimpleObject (external)", [_builder description]);
}


#pragma mark - Internal

-(void) configureWithMacros:(NSArray *) macros {
    for (id<ALCMacro> macro in macros) {
        [_builder.macroProcessor addMacro:macro];
    }
    [_builder configure];
    [_builder resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
}

-(void) injectDependencies:(NSArray *) dependencies {
    Ivar dependenciesVar = class_getInstanceVariable([ALCClassBuilder class], "_dependencies");
    object_setIvar(_builder, dependenciesVar, [NSMutableSet setWithArray:dependencies]);
}


@end
