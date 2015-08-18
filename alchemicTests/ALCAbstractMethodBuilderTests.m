//
//  ALCAbstractMethodBuilderTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <OCMock/OCMock.h>

#import "ALCAbstractMethodBuilder.h"
#import "SimpleObject.h"
#import "ALCMacroProcessor.h"
#import "ALCClassBuilder.h"
#import <Alchemic/Alchemic.h>
#import "ALCDependency.h"

@interface ALCAbstractMethodBuilderTests : XCTestCase

@end

@implementation ALCAbstractMethodBuilderTests {
    ALCClassBuilder *_parentBuilder;
}

-(void) setUp {
    _parentBuilder = [[ALCClassBuilder alloc] initWithValueClass:[SimpleObject class]];
}

-(void) testConfigureWithMacroProcessor {
    ignoreSelectorWarnings(
                           ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
                                                                                                                         selector:@selector(stringFactoryMethodUsingAString:)];
                           )
    methodBuilder.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
    [methodBuilder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [methodBuilder configure];

    ALCDependency *dependency = methodBuilder.dependencies[0];
    XCTAssertEqualObjects(@"abc", dependency.value);
}

-(void) testConfigureWithMacroProcessorNotEnoughArguments {
    ignoreSelectorWarnings(
                           ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
                                                                                                                         selector:@selector(stringFactoryMethodUsingAString:)];
                           )
    methodBuilder.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg];
    [methodBuilder configure];
}

-(void) testConfigureWithMacroProcessorWithInvalidSelector {
    ignoreSelectorWarnings(
                           ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
                                                                                                                         selector:@selector(xxxx)];
                           )
    XCTAssertThrowsSpecificNamed([methodBuilder configure], NSException, @"AlchemicSelectorNotFound");
}

-(void) testConfigureWithMacroProcessorIncorrectNumberArguments {
    ignoreSelectorWarnings(
                           ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
                                                                                                                         selector:@selector(stringFactoryMethodUsingAString:)];
                           )
    [methodBuilder.macroProcessor addMacro:AcArg(NSString, AcValue(@"abc"))];
    [methodBuilder.macroProcessor addMacro:AcArg(NSString, AcValue(@"def"))];
    XCTAssertThrowsSpecificNamed([methodBuilder configure], NSException, @"AlchemicTooManyArguments");
}

#pragma mark - Invoking

-(void) testInvokeWithNoArgsOnSimpleMethod {

    ignoreSelectorWarnings(
                           ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
                                                                                                                         selector:@selector(stringFactoryMethod)];
                           )

    // Mock the abstract instantiate object to call the method on a SO.
    id partialMockBuilder = OCMPartialMock(methodBuilder);
    OCMStub([partialMockBuilder instantiateObject]).andDo(^(NSInvocation *inv){
        [inv retainArguments];
        SimpleObject *so = [[SimpleObject alloc] init];
        id result = [methodBuilder invokeMethodOn:so];
        [inv setReturnValue:&result];
    });

    NSString *result = [methodBuilder invokeWithArgs:@[]];
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testInvokeWithNoArgsOnMethodWithArg {

    ignoreSelectorWarnings(
                           ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:_parentBuilder
                                                                                                                         selector:@selector(stringFactoryMethodUsingAString:)];
                           )

    // Mock the abstract instantiate object to call the method on a SO.
    id partialMockBuilder = OCMPartialMock(methodBuilder);
    OCMStub([partialMockBuilder instantiateObject]).andDo(^(NSInvocation *inv){
        [inv retainArguments];
        SimpleObject *so = [[SimpleObject alloc] init];
        id result = [methodBuilder invokeMethodOn:so];
        [inv setReturnValue:&result];
    });

    NSString *result = [methodBuilder invokeWithArgs:@[@"def"]];
    XCTAssertEqualObjects(@"abc", result);
}

-(void) testInjectValueDependenciesPassesToParentBuilder {
    id mockParent = OCMClassMock([ALCClassBuilder class]);
    SimpleObject *object = [[SimpleObject alloc] init];
    OCMExpect([mockParent injectValueDependencies:object]);
    ignoreSelectorWarnings(
                           ALCAbstractMethodBuilder *methodBuilder = [[ALCAbstractMethodBuilder alloc] initWithParentClassBuilder:mockParent
                                                                                                                         selector:@selector(stringFactoryMethod)];
                           )
    [methodBuilder injectValueDependencies:object];
    OCMVerifyAll(mockParent);
}


@end
