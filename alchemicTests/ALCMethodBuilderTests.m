//
//  ALCMethodBuilderTests.m
//  alchemic
//
//  Created by Derek Clarkson on 1/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>

#import "ALCMethodBuilder.h"
#import "ALCTestCase.h"
#import "SimpleObject.h"
#import "ALCInternalMacros.h"
#import "ALCMacroProcessor.h"
#import "ALCMethodInstantiator.h"
#import "ALCInitializerInstantiator.h"

@interface ALCMethodBuilderTests : ALCTestCase

@end

@implementation ALCMethodBuilderTests

-(void) testMacroProcessorMethodExternalThrows {
    ignoreSelectorWarnings(
                           ALCMethodBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethod)];
                           )
    XCTAssertThrowsSpecificNamed([builder.macroProcessor addMacro:AcExternal], NSException, @"AlchemicUnexpectedMacro");
}
-(void) testMacroProcessorInitializerExternalThrows {
    ignoreSelectorWarnings(
                           ALCMethodBuilder *builder = [self initializerBuilderFor:@selector(initAlternative)];
                           )
    XCTAssertThrowsSpecificNamed([builder.macroProcessor addMacro:AcExternal], NSException, @"AlchemicUnexpectedMacro");
}
-(void) testConfigureWithMethodArg {
    ignoreSelectorWarnings(
                           ALCMethodBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];
                           )
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];

    [builder configure];

    Ivar methodArgsVar = class_getInstanceVariable([ALCMethodBuilder class], "_arguments");
    NSArray *dependencies = object_getIvar(builder, methodArgsVar);

    XCTAssertEqual(1u, [dependencies count]);
    XCTAssertEqualObjects(@"[NSString]<NSMutableCopying><NSSecureCoding><NSCopying> -> Constant: abc", [dependencies[0] description]);
}

-(void) testValueFromMethod {
    ALCMethodBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethod)];
    [self configureAndResolveBuilder:builder];
    NSString *result = builder.value;
    XCTAssertEqual(@"abc", result);
}

-(void) testValueFromMethodWithArg {
    ignoreSelectorWarnings(
                           ALCMethodBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];
                           )
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [self configureAndResolveBuilder:builder];
    NSString *result = builder.value;
    XCTAssertEqual(@"abc", result);
}

-(void) testValueFromInitializer {
    ignoreSelectorWarnings(
                           ALCMethodBuilder *builder = [self initializerBuilderFor:@selector(initAlternative)];
                           )
    [self configureAndResolveBuilder:builder];
    SimpleObject *so = builder.value;
    XCTAssertNotNil(so);
}

-(void) testValueFromInitializerWithArg {
    ALCMethodBuilder *builder = [self initializerBuilderFor:@selector(initWithString:)];
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [self configureAndResolveBuilder:builder];
    SimpleObject *so = builder.value;
    XCTAssertNotNil(so);
    XCTAssertEqualObjects(@"abc", so.aStringProperty);
}

-(void) testInvokeOnMethodWithArgs {
    ALCMethodBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    NSString *result = [builder invokeWithArgs:@[@"abc"]];
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testInvokeOnInitializerWithArgs {
    ALCMethodBuilder *builder = [self initializerBuilderFor:@selector(initWithString:)];

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    SimpleObject *so = [builder invokeWithArgs:@[@"abc"]];
    XCTAssertNotNil(so);
    XCTAssertEqualObjects(@"abc", so.aStringProperty);
}

-(void) testDescriptionForMethod {
    ignoreSelectorWarnings(
                           ALCMethodBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];
                           )
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [builder configure];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject stringFactoryMethodUsingAString:', singleton, using method [SimpleObject stringFactoryMethodUsingAString:]", [builder description]);
}

-(ALCMethodBuilder *) methodBuilderFor:(SEL) selector {
    ALCClassBuilder *parentBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    id<ALCInstantiator> initiator = [[ALCMethodInstantiator alloc] initWithClass:[SimpleObject class]
                                                                      returnType:[SimpleObject class]
                                                                        selector:selector];
    return [[ALCMethodBuilder alloc] initWithInstantiator:initiator
                                                 forClass:[SimpleObject class]
                                            parentBuilder:parentBuilder];
}

-(ALCMethodBuilder *) initializerBuilderFor:(SEL) selector {
    ALCClassBuilder *simpleObjectBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    id<ALCInstantiator> initiator = [[ALCInitializerInstantiator alloc] initWithClass:[SimpleObject class]
                                                                          initializer:selector];
    return [[ALCMethodBuilder alloc] initWithInstantiator:initiator
                                                 forClass:[SimpleObject class]
                                            parentBuilder:simpleObjectBuilder];
}

@end
