//
//  ALCMethodBuilderPersonalityTests.m
//  alchemic
//
//  Created by Derek Clarkson on 8/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <OCMock/OCMock.h>
#import "ALCMethodBuilderPersonality.h"
#import "ALCBuilder.h"
#import "SimpleObject.h"
#import "ALCContext.h"
#import "ALCAlchemic.h"

@interface ALCMethodBuilderPersonalityTests : XCTestCase

@end

@implementation ALCMethodBuilderPersonalityTests{
    ALCMethodBuilderPersonality *_personality;
    id _mockMethodBuilder;
    id _mockClassBuilder;
}

-(void) setUp {
    _mockMethodBuilder = OCMClassMock([ALCBuilder class]);
    _mockClassBuilder = OCMClassMock([ALCBuilder class]);
    OCMStub([_mockClassBuilder valueClass]).andReturn([SimpleObject class]);
    OCMStub([_mockMethodBuilder valueClass]).andReturn([NSString class]);
    ignoreSelectorWarnings(
                           _personality = [[ALCMethodBuilderPersonality alloc] initWithClassBuilder:_mockClassBuilder
                                                                                           selector:@selector(stringFactoryMethodUsingAString:)
                                                                                         returnType:[NSString class]];
                           )
    _personality.builder = _mockMethodBuilder;
}

-(void) testBuilderType {
    XCTAssertEqual(ALCBuilderPersonalityTypeMethod, _personality.type);
}

-(void) testBuilderName {
    XCTAssertEqualObjects(@"SimpleObject stringFactoryMethodUsingAString:", _personality.builderName);
}

-(void) testWillResolve {

    // mock out getting a builder from the context.
    id mockStringBuilder = [self mockReturnTypeBuilder];

    [_personality willResolve]; // No errors.

    // Verify that the method builder should now have the return type builder as a dependency.
    OCMVerify([(ALCBuilder *)_mockMethodBuilder addDependency:mockStringBuilder]);
}

-(void) testWillResolveAddsClassBuilderAsDependency {

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMExpect([(ALCBuilder *)_mockMethodBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id obj) {
        return obj == self->_mockClassBuilder;
    }]]);

    [_personality willResolve];

    OCMVerifyAll(mockBuilder);
}

-(void) testWillResolveWhenNoReturnTypeBuilder {

    // mock not getting a builder from the context.
    [self mockFindingABuilderInContext:nil];

    [_personality willResolve]; // No errors.

    // Verify that nothing was called.
    OCMVerifyAll(_mockMethodBuilder);
}

-(void) testInvokeWithArgs {
    SimpleObject *object = [[SimpleObject alloc] init];
    OCMStub([(ALCBuilder *)_mockClassBuilder value]).andReturn(object);
    NSString *result = [_personality invokeWithArgs:@[@"def"]];
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testCanInjectDependencies {
    id mockStringBuilder = [self mockReturnTypeBuilder];
    OCMStub([mockStringBuilder ready]).andReturn(YES);
    [_personality willResolve];
    XCTAssertTrue(_personality.canInjectDependencies);
}

-(void) testInjectDependenciesWhenBuilderForReturnType {
    id mockStringBuilder = [self mockReturnTypeBuilder];
    NSString *aString = @"abc";
    [_personality willResolve];
    [_personality injectDependencies:aString];
    OCMVerify([mockStringBuilder injectDependencies:@"abc"]);
}

-(void) testInjectDependenciesWhenNoBuilderForReturnType {
    [self mockFindingABuilderInContext:nil];
    NSString *aString = @"abc";
    [_personality willResolve];
    [_personality injectDependencies:aString]; // Nothing should happen.
}

-(void) testAttributeText {
    XCTAssertEqualObjects(@", using method [SimpleObject stringFactoryMethodUsingAString:]", _personality.attributeText);
}

#pragma mark - Internal

-(id) mockReturnTypeBuilder {
    id mockStringBuilder = OCMClassMock([ALCBuilder class]);
    [self mockFindingABuilderInContext:mockStringBuilder];
    return mockStringBuilder;
}

-(void) mockFindingABuilderInContext:(id) builder {
    id mockContext = OCMClassMock([ALCContext class]);
    id mockAlchemic = OCMClassMock([ALCAlchemic class]);
    OCMStub(ClassMethod([mockAlchemic mainContext])).andReturn(mockContext);
    OCMStub([mockContext builderForClass:[NSString class]]).andReturn(builder);
}

@end
