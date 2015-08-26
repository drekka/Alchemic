//
//  ALCObjectBuilderTests.m
//  alchemic
//
//  Created by Derek Clarkson on 26/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <OCMock/OCMock.h>
#import <Alchemic/Alchemic.h>
#import "ALCObjectBuilder.h"
#import "ALCInstantiator.h"
#import "SimpleObject.h"
#import "ALCClassInstantiator.h"
#import "ALCMethodInstantiator.h"
#import "ALCInitializerInstantiator.h"
#import "ALCTestCase.h"
#import "ALCSingletonStorage.h"
#import "ALCFactoryStorage.h"
#import "ALCExternalStorage.h"
#import "ALCBuilderDependencyManager.h"
#import "ALCDependency.h"
#import "ALCConstantValueSource.h"
#import "ALCObjectBuilder+ClassBuilder.h"
#import "ALCObjectBuilder+MethodBuilder.h"

@interface ALCObjectBuilderTests : ALCTestCase

@end

@implementation ALCObjectBuilderTests

#pragma mark - Setup

-(void) testDefaultName {
    ALCObjectBuilder *builder = [self classBuilder];
    XCTAssertEqualObjects(@"SimpleObject", builder.name);
}

-(void) testSetsBuilderTypeClass {
    ALCObjectBuilder *builder = [self classBuilder];
    XCTAssertEqual(ALCBuilderTypeClass, builder.builderType);
}

-(void) testSetsBuilderTypeMethod {
    ignoreSelectorWarnings(
                           ALCObjectBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethod)];
                           )
    XCTAssertEqual(ALCBuilderTypeMethod, builder.builderType);
}

-(void) testSetsBuilderTypeInitializer {
    ignoreSelectorWarnings(
                           ALCObjectBuilder *builder = [self initializerBuilderFor:@selector(initAlternative)];
                           )
    XCTAssertEqual(ALCBuilderTypeInitializer, builder.builderType);
}

#pragma mark - MacroProcessor

-(void) testMacroProcessorClassExternal {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder.macroProcessor addMacro:AcExternal]; // No error
}

-(void) testMacroProcessorMethodExternalThrows {
    ALCObjectBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethod)];
    XCTAssertThrowsSpecificNamed([builder.macroProcessor addMacro:AcExternal], NSException, @"AlchemicUnexpectedMacro");
}

-(void) testMacroProcessorInitializerExternalThrows {
    ALCObjectBuilder *builder = [self initializerBuilderFor:@selector(initAlternative)];
    XCTAssertThrowsSpecificNamed([builder.macroProcessor addMacro:AcExternal], NSException, @"AlchemicUnexpectedMacro");
}

#pragma mark - Configure

-(void) testConfigureDefaultSingletonStorage {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCObjectBuilder class], "_valueStorage");
    id storage = object_getIvar(builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCSingletonStorage class]]);
}

-(void) testConfigureFactoryStorage {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder.macroProcessor addMacro:AcFactory];
    [builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCObjectBuilder class], "_valueStorage");
    id storage = object_getIvar(builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCFactoryStorage class]]);
}

-(void) testConfigureExternalStorage {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder.macroProcessor addMacro:AcFactory];
    [builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCObjectBuilder class], "_valueStorage");
    id storage = object_getIvar(builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCFactoryStorage class]]);
}

-(void) testConfigureWithNameSetsNewName {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder.macroProcessor addMacro:AcWithName(@"abc")];
    [builder configure];
    XCTAssertEqualObjects(@"abc", builder.name);
}

-(void) testConfigureWithMethodArd {
    ignoreSelectorWarnings(
                           ALCObjectBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];
                           )
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];

    [builder configure];

    Ivar methodArgsVar = class_getInstanceVariable([ALCObjectBuilder class], "_methodArguments");
    ALCBuilderDependencyManager *methodArgs = object_getIvar(builder, methodArgsVar);
    XCTAssertEqual(1u, methodArgs.numberOfDependencies);

    Ivar dependenciesVar = class_getInstanceVariable([ALCBuilderDependencyManager class], "_dependencies");
    NSArray<ALCDependency *> *dependencies = object_getIvar(methodArgs, dependenciesVar);

    XCTAssertEqualObjects(@"[NSString]<NSMutableCopying><NSSecureCoding><NSCopying> -> Constant: abc", [dependencies[0] description]);
}

#pragma mark - Resolving

-(void) testResolveDefault {
    ALCObjectBuilder *builder = [self classBuilder];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack]; // No error.
}

-(void) testResolveWhenCircularDependency {
    ALCObjectBuilder *builder = [self classBuilder];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray arrayWithObject:builder];
    XCTAssertThrowsSpecificNamed([builder resolveWithPostProcessors:postProcessors dependencyStack:stack], NSException, @"AlchemicCircularDependency");
}

#pragma mark - Tasks

-(void) testInject {
    ALCObjectBuilder *builder = [self classBuilder];
    SimpleObject *so = [[SimpleObject alloc] init];
    Ivar var = class_getInstanceVariable([SimpleObject class], "_aStringProperty");
    [builder addVariableInjection:var valueSource:[[ALCConstantValueSource alloc] initWithType:[NSString class] value:@"abc"]];

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    [builder injectDependencies:so];

    XCTAssertEqual(@"abc", so.aStringProperty);
}

-(void) testInvokeOnClassThrows {
    ALCObjectBuilder *builder = [self classBuilder];

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    XCTAssertThrowsSpecificNamed([builder invokeWithArgs:@[@"abc"]], NSException, @"AlchemicWrongBuilderType");
}

-(void) testInvokeOnMethodWithArgs {
    ALCObjectBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    NSString *result = [builder invokeWithArgs:@[@"abc"]];
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testInvokeOnInitializerWithArgs {
    ALCObjectBuilder *builder = [self initializerBuilderFor:@selector(initWithString:)];

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    SimpleObject *so = [builder invokeWithArgs:@[@"abc"]];
    XCTAssertNotNil(so);
    XCTAssertEqualObjects(@"abc", so.aStringProperty);
}

#pragma mark - Value

-(void) testValueFromClass {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder configure];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    SimpleObject *so = builder.value;
    XCTAssertNotNil(so);
}

-(void) testValueFromClassCachesValue {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder configure];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    SimpleObject *so1 = builder.value;
    SimpleObject *so2 = builder.value;
    XCTAssertEqual(so1, so2);
}

-(void) testValueFromMethod {
    ALCObjectBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethod)];
    [builder configure];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    NSString *result = builder.value;
    XCTAssertEqual(@"abc", result);
}

-(void) testValueFromMethodWithArg {
    ALCObjectBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [builder configure];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    NSString *result = builder.value;
    XCTAssertEqual(@"abc", result);
}

-(void) testValueFromInitializer {
    ALCObjectBuilder *builder = [self initializerBuilderFor:@selector(initAlternative)];
    [builder configure];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    SimpleObject *so = builder.value;
    XCTAssertNotNil(so);
}

-(void) testValueFromInitializerWithArg {
    ALCObjectBuilder *builder = [self initializerBuilderFor:@selector(initWithString:)];
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [builder configure];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    SimpleObject *so = builder.value;
    XCTAssertNotNil(so);
    XCTAssertEqualObjects(@"abc", so.aStringProperty);
}

-(void) testSetValue {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder configure];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    builder.value = @"abc";
    XCTAssertEqualObjects(@"abc", builder.value);
}

#pragma mark - Description

-(void) testDescriptionForClass {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder configure];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject', singleton, class builder", [builder description]);

}

-(void) testDescriptionForClassWhenInstantiated {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder configure];
    [builder value];
    XCTAssertEqualObjects(@"* builder for type SimpleObject, name 'SimpleObject', singleton, class builder", [builder description]);

}

-(void) testDescriptionForClassFactory {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder.macroProcessor addMacro:AcFactory];
    [builder configure];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject', factory, class builder", [builder description]);
}

-(void) testDescriptionForClassExternal {
    ALCObjectBuilder *builder = [self classBuilder];
    [builder.macroProcessor addMacro:AcExternal];
    [builder configure];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject', external, class builder", [builder description]);
}

-(void) testDescriptionForMethod {
    ignoreSelectorWarnings(
                           ALCObjectBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];
                           )
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [builder configure];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject stringFactoryMethodUsingAString:', singleton, using method [SimpleObject stringFactoryMethodUsingAString:]", [builder description]);
}

#pragma mark - Internal

-(id<ALCBuilder>) classBuilder {
    id<ALCInstantiator> initiator = [[ALCClassInstantiator alloc] initWithObjectType:[SimpleObject class]];
    ALCObjectBuilder *builder = [[ALCObjectBuilder alloc] initWithInstantiator:initiator
                                                                      forClass:[SimpleObject class]];
    return builder;
}

-(id<ALCBuilder>) methodBuilderFor:(SEL) selector {
    id<ALCBuilder> parentBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    id<ALCInstantiator> initiator = [[ALCMethodInstantiator alloc] initWithClassBuilder:parentBuilder
                                                                               selector:selector];
    ALCObjectBuilder *builder = [[ALCObjectBuilder alloc] initWithInstantiator:initiator
                                                                      forClass:[SimpleObject class]];
    return builder;
}

-(id<ALCBuilder>) initializerBuilderFor:(SEL) selector {
    id<ALCBuilder> parentBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    id<ALCInstantiator> initiator = [[ALCInitializerInstantiator alloc] initWithClassBuilder:parentBuilder
                                                                                 initializer:selector];
    ALCObjectBuilder *builder = [[ALCObjectBuilder alloc] initWithInstantiator:initiator
                                                                      forClass:[SimpleObject class]];
    return builder;
}

@end
