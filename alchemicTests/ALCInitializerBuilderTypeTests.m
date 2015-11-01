//
//  ALCInitializerBuilderTypeTests.m
//  alchemic
//
//  Created by Derek Clarkson on 8/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <OCMock/OCMock.h>
#import "ALCInitializerBuilderType.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "SimpleObject.h"
#import "ALCInternalMacros.h"

@interface ALCInitializerBuilderTypeTests : XCTestCase

@end

@implementation ALCInitializerBuilderTypeTests {
    ALCInitializerBuilderType *_builderType;
    id _mockInitializerBuilder;
    id _mockClassBuilder;
}

-(void) setUp {
    _mockInitializerBuilder = OCMClassMock([ALCBuilder class]);
    _mockClassBuilder = OCMClassMock([ALCBuilder class]);
    OCMStub([_mockClassBuilder valueClass]).andReturn([SimpleObject class]);
    ignoreSelectorWarnings(
                           _builderType = [[ALCInitializerBuilderType alloc] initWithParentClassBuilder:_mockClassBuilder
                                                                                            initializer:@selector(initWithString:)];
                           )
}

-(void) testBuilderName {
    XCTAssertEqualObjects(@"SimpleObject initWithString:", _builderType.name);
}

-(void) testMacroProcessorFlags {
    XCTAssertEqual(ALCAllowedMacrosArg, _builderType.macroProcessorFlags);
}

-(void) testWillResolve {
    [_builderType builderWillResolve:_mockInitializerBuilder]; // No errors.
}

-(void) testWillResolveAddsClassBuilderAsDependency {

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMExpect([(ALCBuilder *)_mockInitializerBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id obj) {
        return obj == self->_mockClassBuilder;
    }]]);

    [_builderType builderWillResolve:_mockInitializerBuilder];

    OCMVerifyAll(mockBuilder);
}

-(void) testWillResolveThrows {
    ignoreSelectorWarnings(
                           ALCInitializerBuilderType *builderType = [[ALCInitializerBuilderType alloc] initWithParentClassBuilder:_mockClassBuilder
                                                                                                                      initializer:@selector(xxx)];
                           )
    OCMStub([_mockClassBuilder valueClass]).andReturn([SimpleObject class]);

    XCTAssertThrowsSpecificNamed([builderType builderWillResolve:_mockInitializerBuilder], NSException, @"AlchemicSelectorNotFound");
}

-(void) testInvokeWithArgs {
    SimpleObject *result = [_builderType invokeWithArgs:@[@"abc"]];
    XCTAssertEqualObjects(@"abc", result.aStringProperty);
}

-(void) testCanInjectDependencies {
    OCMStub([_mockClassBuilder ready]).andReturn(YES);
    XCTAssertTrue(_builderType.canInjectDependencies);
    OCMVerify([_mockClassBuilder ready]);
}

-(void) testAttributeText {
    XCTAssertEqualObjects(@", using initializer [SimpleObject initWithString:]", _builderType.attributeText);
}

@end
