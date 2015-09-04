//
//  ALCBuilderTests.m
//  alchemic
//
//  Created by Derek Clarkson on 1/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>

#import "ALCBuilder.h"
#import "ALCTestCase.h"
#import "SimpleObject.h"
#import "ALCInternalMacros.h"
#import "ALCMacroProcessor.h"
#import "ALCMethodInstantiator.h"
#import "ALCInitializerInstantiator.h"

@interface ALCBuilderTests : ALCTestCase

@end

@implementation ALCBuilderTests

-(void) testMacroProcessorMethodExternalThrows {
    ignoreSelectorWarnings(
                           ALCBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethod)];
                           )
    XCTAssertThrowsSpecificNamed([builder.macroProcessor addMacro:AcExternal], NSException, @"AlchemicUnexpectedMacro");
}
-(void) testMacroProcessorInitializerExternalThrows {
    ignoreSelectorWarnings(
                           ALCBuilder *builder = [self initializerBuilderFor:@selector(initAlternative)];
                           )
    XCTAssertThrowsSpecificNamed([builder.macroProcessor addMacro:AcExternal], NSException, @"AlchemicUnexpectedMacro");
}
-(void) testConfigureWithMethodArg {
    ignoreSelectorWarnings(
                           ALCBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];
                           )
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];

    [builder configure];

    Ivar methodArgsVar = class_getInstanceVariable([ALCBuilder class], "_arguments");
    NSArray *dependencies = object_getIvar(builder, methodArgsVar);

    XCTAssertEqual(1u, [dependencies count]);
    XCTAssertEqualObjects(@"[NSString]<NSMutableCopying><NSSecureCoding><NSCopying> -> Constant: abc", [dependencies[0] description]);
}

-(void) testValueFromMethod {
    ALCBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethod)];
    [self configureAndResolveBuilder:builder];
    NSString *result = builder.value;
    XCTAssertEqual(@"abc", result);
}

-(void) testValueFromMethodWithArg {
    ignoreSelectorWarnings(
                           ALCBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];
                           )
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [self configureAndResolveBuilder:builder];
    NSString *result = builder.value;
    XCTAssertEqual(@"abc", result);
}

-(void) testValueFromInitializer {
    ignoreSelectorWarnings(
                           ALCBuilder *builder = [self initializerBuilderFor:@selector(initAlternative)];
                           )
    [self configureAndResolveBuilder:builder];
    SimpleObject *so = builder.value;
    XCTAssertNotNil(so);
}

-(void) testValueFromInitializerWithArg {
    ALCBuilder *builder = [self initializerBuilderFor:@selector(initWithString:)];
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [self configureAndResolveBuilder:builder];
    SimpleObject *so = builder.value;
    XCTAssertNotNil(so);
    XCTAssertEqualObjects(@"abc", so.aStringProperty);
}

-(void) testInvokeOnMethodWithArgs {
    ALCBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    NSString *result = [builder invokeWithArgs:@[@"abc"]];
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testInvokeOnInitializerWithArgs {
    ALCBuilder *builder = [self initializerBuilderFor:@selector(initWithString:)];

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    SimpleObject *so = [builder invokeWithArgs:@[@"abc"]];
    XCTAssertNotNil(so);
    XCTAssertEqualObjects(@"abc", so.aStringProperty);
}

-(void) testDescriptionForMethod {
    ignoreSelectorWarnings(
                           ALCBuilder *builder = [self methodBuilderFor:@selector(stringFactoryMethodUsingAString:)];
                           )
    [builder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [builder configure];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject stringFactoryMethodUsingAString:', singleton, using method [SimpleObject stringFactoryMethodUsingAString:]", [builder description]);
}

-(ALCBuilder *) methodBuilderFor:(SEL) selector {
    ALCBuilder *parentBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    id<ALCInstantiator> initiator = [[ALCMethodInstantiator alloc] initWithClass:[SimpleObject class]
                                                                      returnType:[SimpleObject class]
                                                                        selector:selector];
    return [[ALCBuilder alloc] initWithInstantiator:initiator
                                                 forClass:[SimpleObject class]
                                            parentBuilder:parentBuilder];
}

-(ALCBuilder *) initializerBuilderFor:(SEL) selector {
    ALCBuilder *simpleObjectBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    id<ALCInstantiator> initiator = [[ALCInitializerInstantiator alloc] initWithClass:[SimpleObject class]
                                                                          initializer:selector];
    return [[ALCBuilder alloc] initWithInstantiator:initiator
                                                 forClass:[SimpleObject class]
                                            parentBuilder:simpleObjectBuilder];
}

@end
