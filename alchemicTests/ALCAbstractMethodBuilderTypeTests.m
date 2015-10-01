//
//  ALCAbstractMethodBuilderTypeTests.m
//  alchemic
//
//  Created by Derek Clarkson on 5/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <Alchemic/Alchemic.h>
#import <OCMock/OCMock.h>
#import "ALCAbstractMethodBuilderType.h"
#import "ALCtestCase.h"
#import "SimpleObject.h"
#import "ALCMacroProcessor.h"
#import "ALCBuilder.h"
#import "ALCValueSource.h"
#import "ALCResolvable.h"

@interface ALCAbstractMethodBuilderTypeTests : ALCTestCase

@end

@implementation ALCAbstractMethodBuilderTypeTests {
    ALCAbstractMethodBuilderType *_builderType;
    ALCBuilder *_classBuilder;
}

-(void) setUp {
    _classBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    _builderType = [[ALCAbstractMethodBuilderType alloc] initWithClassBuilder:_classBuilder];
}

-(void) testMacroProcessorFlags {
    XCTAssertEqual(ALCAllowedMacrosFactory
                   + ALCAllowedMacrosName
                   + ALCAllowedMacrosPrimary
                   + ALCAllowedMacrosArg,
                   _builderType.macroProcessorFlags);
}

-(void) testConfigureWithMacroProcessorWithArg {

    ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
    [macroProcessor addMacro:AcArg(NSNumber, AcValue(@12))];

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMExpect([(ALCBuilder *)mockBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj conformsToProtocol:@protocol(ALCValueSource)];
    }]]);

    _builderType.builder = mockBuilder;
    [_builderType configureWithMacroProcessor:macroProcessor];

    OCMVerifyAll(mockBuilder);
}

-(void) testWillResolveAddsClassBuilderAsDependency {

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMExpect([(ALCBuilder *)mockBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id obj) {
        return obj == self->_classBuilder;
    }]]);

    _builderType.builder = mockBuilder;
    [_builderType willResolve];

    OCMVerifyAll(mockBuilder);
}

-(void) testReturnsArrayOfargumentValuesFromArguments {

    ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
    [macroProcessor addMacro:AcArg(NSNumber, AcValue(@12))];
    [macroProcessor addMacro:AcArg(NSNumber, AcValue(@"abc"))];

    // Make sure values sources are resolved.
    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMStub([(ALCBuilder *)mockBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id<ALCValueSource> valueSource) {
        [valueSource resolve];
        return YES;
    }]]);

    _builderType.builder = mockBuilder;
    [_builderType configureWithMacroProcessor:macroProcessor];

    NSArray<id> *values = _builderType.argumentValues;

    XCTAssertEqualObjects(@12, values[0]);
    XCTAssertEqualObjects(@"abc", values[1]);
}

-(void) testInstantiateObjectCallsInvoke {

    // Mock out the invoke method.
    id partialMockALCBuilderType = OCMPartialMock(_builderType);
    OCMExpect([partialMockALCBuilderType invokeWithArgs:[OCMArg checkWithBlock:^BOOL(NSArray *args) {
        return [args containsObject:@12];
    }]]).andReturn(@24);

    // Setup the args.
    ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
    [macroProcessor addMacro:AcArg(NSNumber, AcValue(@12))];

    // Make sure values sources are resolved.
    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMStub([(ALCBuilder *)mockBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id<ALCValueSource> valueSource) {
        [valueSource resolve];
        return YES;
    }]]);

    _builderType.builder = mockBuilder;
    [_builderType configureWithMacroProcessor:macroProcessor];

    id result = [_builderType instantiateObject];

    XCTAssertEqualObjects(@24, result);
}

-(void) testAddVariableInjectThrows {
    Ivar classBuilderRef = class_getInstanceVariable([self class], "_classBuilder");
    id mockValueSourceFactory = OCMClassMock([ALCValueSourceFactory class]);
    XCTAssertThrowsSpecificNamed([_builderType addVariableInjection:classBuilderRef valueSourceFactory:mockValueSourceFactory], NSException, @"AlchemicUnexpectedInjection");
}

@end
