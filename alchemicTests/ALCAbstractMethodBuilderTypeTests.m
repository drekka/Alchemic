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
    id _mockMethodBuilder;
    id _mockClassBuilder;
}

-(void) setUp {
    _mockMethodBuilder = OCMClassMock([ALCBuilder class]);
    _mockClassBuilder = OCMClassMock([ALCBuilder class]);
    _builderType = [[ALCAbstractMethodBuilderType alloc] initWithType:[SimpleObject class]
                                                         classBuilder:_mockClassBuilder];
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

    OCMExpect([(ALCBuilder *)_mockMethodBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj conformsToProtocol:@protocol(ALCValueSource)];
    }]]);

    [_builderType builder:_mockMethodBuilder isConfiguringWithMacroProcessor:macroProcessor];

    OCMVerifyAll(_mockMethodBuilder);
}

-(void) testWillResolveAddsClassBuilderAsDependency {

    OCMExpect([(ALCBuilder *)_mockMethodBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id obj) {
        return obj == self->_mockClassBuilder;
    }]]);

    [_builderType builderWillResolve:_mockMethodBuilder];

    OCMVerifyAll(_mockMethodBuilder);
}

-(void) testReturnsArrayOfargumentValuesFromArguments {

    ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
    [macroProcessor addMacro:AcArg(NSNumber, AcValue(@12))];
    [macroProcessor addMacro:AcArg(NSNumber, AcValue(@"abc"))];

    // Make sure values sources are resolved.
    OCMStub([(ALCBuilder *)_mockMethodBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id<ALCValueSource> valueSource) {
        [valueSource resolve]; // This must happen.
        return YES;
    }]]);

    [_builderType builder:_mockMethodBuilder isConfiguringWithMacroProcessor:macroProcessor];

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
    OCMStub([(ALCBuilder *)_mockMethodBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id<ALCValueSource> valueSource) {
        [valueSource resolve];
        return YES;
    }]]);

    [_builderType builder:_mockMethodBuilder isConfiguringWithMacroProcessor:macroProcessor];

    id result = [_builderType instantiateObject];

    XCTAssertEqualObjects(@24, result);
}

@end
