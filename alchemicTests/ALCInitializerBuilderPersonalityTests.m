//
//  ALCInitializerBuilderPersonalityTests.m
//  alchemic
//
//  Created by Derek Clarkson on 8/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <OCMock/OCMock.h>
#import "ALCInitializerBuilderPersonality.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "SimpleObject.h"
#import "ALCInternalMacros.h"

@interface ALCInitializerBuilderPersonalityTests : XCTestCase

@end

@implementation ALCInitializerBuilderPersonalityTests {
    ALCInitializerBuilderPersonality *_personality;
    id _mockInitializerBuilder;
    id _mockClassBuilder;
}

-(void) setUp {
    _mockInitializerBuilder = OCMClassMock([ALCBuilder class]);
    _mockClassBuilder = OCMClassMock([ALCBuilder class]);
    OCMStub([_mockClassBuilder valueClass]).andReturn([SimpleObject class]);
    ignoreSelectorWarnings(
                           _personality = [[ALCInitializerBuilderPersonality alloc] initWithClassBuilder:_mockClassBuilder
                                                                                             initializer:@selector(initWithString:)];
                           )
    _personality.builder = _mockInitializerBuilder;
}

-(void) testBuilderType {
    XCTAssertEqual(ALCBuilderPersonalityTypeInitializer, _personality.type);
}

-(void) testBuilderName {
    XCTAssertEqualObjects(@"SimpleObject initWithString:", _personality.builderName);
}

-(void) testWillResolve {
    [_personality willResolve]; // No errors.
}

-(void) testWillResolveAddsClassBuilderAsDependency {

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMExpect([(ALCBuilder *)_mockInitializerBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id obj) {
        return obj == self->_mockClassBuilder;
    }]]);

    [_personality willResolve];

    OCMVerifyAll(mockBuilder);
}

-(void) testWillResolveThrows {
    ignoreSelectorWarnings(
                           ALCInitializerBuilderPersonality *personality = [[ALCInitializerBuilderPersonality alloc] initWithClassBuilder:_mockClassBuilder
                                                                                                                              initializer:@selector(xxx)];
                           )
    personality.builder = _mockInitializerBuilder;
    OCMStub([_mockClassBuilder valueClass]).andReturn([SimpleObject class]);

    XCTAssertThrowsSpecificNamed([personality willResolve], NSException, @"AlchemicSelectorNotFound");
}

-(void) testInvokeWithArgs {
    SimpleObject *result = [_personality invokeWithArgs:@[@"abc"]];
    XCTAssertEqualObjects(@"abc", result.aStringProperty);
}

-(void) testCanInjectDependencies {
    OCMStub([_mockClassBuilder ready]).andReturn(YES);
    XCTAssertTrue(_personality.canInjectDependencies);
    OCMVerify([_mockClassBuilder ready]);
}

-(void) testinjectDependencies {
    SimpleObject *object = [[SimpleObject alloc] init];
    [_personality injectDependencies:object];
    OCMVerify([_mockClassBuilder injectDependencies:object]);
}

-(void) testAttributeText {
    XCTAssertEqualObjects(@", using initializer [SimpleObject initWithString:]", _personality.attributeText);
}

@end
