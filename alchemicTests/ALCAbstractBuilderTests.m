//
//  ALCAbstractBuilderTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <Alchemic/Alchemic.h>
#import <OCMock/OCMock.h>

#import "SimpleObject.h"
#import "ALCAbstractBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCVariableDependency.h"
#import "NSObject+ALCResolvable.h"
#import "ALCConstantValueSource.h"

@interface FakeBuilder : ALCAbstractBuilder
@property (nonatomic, strong) id injectedValue;
@end

@implementation FakeBuilder

-(nonnull id) instantiateObject {
    return [[SimpleObject alloc] init];
}

-(void)injectValueDependencies:(nonnull id)value {
    self.injectedValue = value;
}

@end

@interface ALCAbstractBuilderTests : XCTestCase {
    FakeBuilder *_builder;
    BOOL _availableKVOCalled;
}

@end

#pragma mark - Tests

@implementation ALCAbstractBuilderTests

-(void) setUp {
    _availableKVOCalled = NO;
    _builder = [[FakeBuilder alloc] init];
    _builder.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosFactory + ALCAllowedMacrosPrimary + ALCAllowedMacrosName];
}

-(void) testConfigureFactory {
    [self configureWithMacros:@[AcFactory]];
    XCTAssertTrue(_builder.factory);
}

-(void) testConfigurePrimary {
    [self configureWithMacros:@[AcPrimary]];
    XCTAssertTrue(_builder.primary);
}

#pragma mark - Querying

-(void) testCreateOnBootWhenNotAFactoryAndNoValue {
    [self configureWithMacros:@[]];
    XCTAssertTrue(_builder.createOnBoot);
}

-(void) testCreateOnBootWhenAFactoryAndNoValue {
    [self configureWithMacros:@[AcFactory]];
    XCTAssertFalse(_builder.createOnBoot);
}

-(void) testCreateOnBootWhenNotAFactoryAndValueSet {
    [self configureWithMacros:@[]];
    _builder.value = @"abc";
    XCTAssertFalse(_builder.createOnBoot);
}

-(void) testCreateOnBootWhenAFactoryAndValueSet {
    [self configureWithMacros:@[AcFactory]];
    XCTAssertFalse(_builder.createOnBoot);
}

-(void) testInjectDependencies {
    [self configureWithMacros:@[]];
    SimpleObject *so = [[SimpleObject alloc] init];
    [_builderinjectDependencies:so];
    XCTAssertEqual(so, _builder.injectedValue);
}

-(void) testStateDescriptionWhenNoValue {
    XCTAssertEqualObjects(@"  ", [_builder stateDescription]);
}

-(void) testStateDescriptionWhenValue {
    [self configureWithMacros:@[]];
    _builder.value = @"abc";
    XCTAssertEqualObjects(@"* ", [_builder stateDescription]);
}

-(void) testAttributeDescriptionWhenNothingSet {
    XCTAssertEqualObjects(@"", [_builder attributesDescription]);
}

-(void) testAttributeDescriptionWhenFactory {
    [self configureWithMacros:@[AcFactory]];
    XCTAssertEqualObjects(@" (factory)", [_builder attributesDescription]);
}

#pragma mark - Creating objects

-(void) testDependenciesAvailableCreatesObject {

    ALCConstantValueSource *valueSource = [[ALCConstantValueSource alloc] initWithType:[NSString class] value:@"abc"];
    valueSource.available = NO;
    ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:valueSource];
    [self injectDependencies:@[dependency]];

    // Trigger cascading KVOs.
    valueSource.available = YES;

    Ivar valueVar = class_getInstanceVariable([_builder class], "_value");
    id value = object_getIvar(_builder, valueVar);

    XCTAssertNotNil(value);
    XCTAssertTrue([value isKindOfClass:[SimpleObject class]]);
}

-(void) testDependenciesAvailableOnFactoryBuilderDoesntCreateObject {

    _builder.available = NO;
    id mockDependency = OCMClassMock([ALCDependency class]);
    OCMStub([(ALCDependency *)mockDependency available]).andReturn(YES);
    [self injectDependencies:@[mockDependency]];

    _builder.factory = YES;

    Ivar valueVar = class_getInstanceVariable([_builder class], "_value");
    id value = object_getIvar(_builder, valueVar);

    XCTAssertNil(value);
}


-(void) testValueCachesWhenNotAFactory {
    [self configureWithMacros:@[]];
    id value1 = _builder.value;
    id value2 = _builder.value;
    XCTAssertEqual(value1, value2);
}

-(void) testValueCreatesNewValueWHenAFactory {
    [self configureWithMacros:@[AcFactory]];
    id value1 = _builder.value;
    id value2 = _builder.value;
    XCTAssertNotEqual(value1, value2);
}

-(void) testInstantiateCreatesObjectButDoesNotWireIt {
    [self configureWithMacros:@[]];
    id mockDependency = OCMStrictClassMock([ALCVariableDependency class]);
    [_builder.dependencies addObject:mockDependency];

    id value = [_builder instantiate];

    XCTAssertNotNil(value);
    XCTAssertEqual([SimpleObject class], [value class]);

    OCMVerifyAll(mockDependency);
}

-(void) testKVOFiresWhenObjectCreated {
    [self configureWithMacros:@[]];
    [self kvoWatchAvailable:_builder];
    XCTAssertNotNil(_builder.value);
    [self kvoRemoveWatchAvailable:_builder];
    XCTAssertTrue(_availableKVOCalled);
}

-(void) testKVOFiresWhenValueSet {
    [self configureWithMacros:@[]];
    [self kvoWatchAvailable:_builder];
    _builder.value = @"abc";
    [self kvoRemoveWatchAvailable:_builder];
    XCTAssertTrue(_availableKVOCalled);
}

-(void) testSettingValueThrowsWhenFactory {
    [self configureWithMacros:@[AcFactory]];
    XCTAssertThrowsSpecificNamed(_builder.value = @"abc", NSException, @"AlchemicCannotSetValueOnFactory");
}

#pragma mark - Resolving

-(void) testResolveWithPostProcessors {

    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    id mockDependency = OCMClassMock([ALCDependency class]);
    OCMExpect([mockDependency resolveWithPostProcessors:postProcessors dependencyStack:stack]);
    [self injectDependencies:@[mockDependency]];

    [_builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    OCMVerifyAll(mockDependency);

}

-(void) testResolveWithPostProcessorsWhenNoDependencies {
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [_builder resolveWithPostProcessors:postProcessors dependencyStack:stack];
    // Does nothing.
}

-(void) testResolveWithPostProcessorsThrowsWhenCircularDependencyDetected {
    NSMutableArray *stack = [@[_builder] mutableCopy];
    XCTAssertThrowsSpecificNamed([_builder resolveWithPostProcessors:[NSSet set] dependencyStack:stack], NSException, @"AlchemicCircularDependency");
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
    Ivar dependencyVar = class_getInstanceVariable([_builder class], "_dependencies");
    object_setIvar(_builder, dependencyVar, [dependencies mutableCopy]);
    [_builder kvoWatchAvailableInResolvables:[NSSet setWithArray:dependencies]];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    _availableKVOCalled = YES;
}



@end
