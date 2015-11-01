//
//  ALCMethodBuilderTypeTests.m
//  alchemic
//
//  Created by Derek Clarkson on 8/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <OCMock/OCMock.h>
#import "ALCMethodBuilderType.h"
#import "ALCBuilder.h"
#import "SimpleObject.h"
#import "ALCContext.h"
#import "ALCAlchemic.h"
#import "ALCMacroProcessor.h"

@interface ALCMethodBuilderTypeTests : XCTestCase

@end

@implementation ALCMethodBuilderTypeTests{
    ALCMethodBuilderType *_builderType;
    id _mockClassBuilder;
    id _mockMethodBuilder;
}

-(void) setUp {
    _mockClassBuilder = OCMClassMock([ALCBuilder class]);
    _mockMethodBuilder = OCMClassMock([ALCBuilder class]);
    OCMStub([_mockClassBuilder valueClass]).andReturn([SimpleObject class]);
    ignoreSelectorWarnings(
                           _builderType = [[ALCMethodBuilderType alloc] initWithType:[NSString class]
                                                                  parentClassBuilder:_mockClassBuilder
                                                                            selector:@selector(stringFactoryMethodUsingAString:)];
                           )
}

-(void) testBuilderName {
    XCTAssertEqualObjects(@"SimpleObject stringFactoryMethodUsingAString:", _builderType.name);
}

-(void) testMacroProcessorFlags {
    XCTAssertEqual(ALCAllowedMacrosFactory
                   + ALCAllowedMacrosName
                   + ALCAllowedMacrosPrimary
                   + ALCAllowedMacrosArg,
                   _builderType.macroProcessorFlags);
}

-(void) testWillResolve {

    // mock out getting a builder from the context.
    id mockStringBuilder = [self mockReturnTypeBuilder];

    [_builderType builderWillResolve:_mockMethodBuilder]; // No errors.

    // Verify that the method builder should now have the return type builder as a dependency.
    OCMVerify([(ALCBuilder *)_mockMethodBuilder addDependency:mockStringBuilder]);
}

-(void) testWillResolveAddsClassBuilderAsDependency {

    id mockBuilder = OCMClassMock([ALCBuilder class]);
    OCMExpect([(ALCBuilder *)_mockMethodBuilder addDependency:[OCMArg checkWithBlock:^BOOL(id obj) {
        return obj == self->_mockClassBuilder;
    }]]);

    [_builderType builderWillResolve:_mockMethodBuilder];

    OCMVerifyAll(mockBuilder);
}

-(void) testWillResolveWhenNoReturnTypeBuilder {

    // mock not getting a builder from the context.
    [self mockFindingABuilderInContext:nil];

    [_builderType builderWillResolve:_mockMethodBuilder]; // No errors.

    // Verify that nothing was called.
    OCMVerifyAll(_mockMethodBuilder);
}

-(void) testInvokeWithArgs {
    SimpleObject *object = [[SimpleObject alloc] init];
    OCMStub([(ALCBuilder *)_mockClassBuilder value]).andReturn(object);
    NSString *result = [_builderType invokeWithArgs:@[@"def"]];
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testCanInjectDependencies {
    id mockStringBuilder = [self mockReturnTypeBuilder];
    OCMStub([mockStringBuilder ready]).andReturn(YES);
    [_builderType builderWillResolve:_mockMethodBuilder];
    XCTAssertTrue(_builderType.canInjectDependencies);
}

-(void) testAttributeText {
    XCTAssertEqualObjects(@", using method stringFactoryMethodUsingAString:", _builderType.attributeText);
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
    OCMStub([mockContext classBuilderForClass:[NSString class]]).andReturn(builder);
}

@end
