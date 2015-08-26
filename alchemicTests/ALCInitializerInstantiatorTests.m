//
//  ALCInitializerInstantiatorTests.m
//  alchemic
//
//  Created by Derek Clarkson on 26/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCTestCase.h"
#import "SimpleObject.h"
#import "ALCInitializerInstantiator.h"
#import "ALCBuilder.h"
#import "ALCInternalMacros.h"

@interface ALCInitializerInstantiatorTests : ALCTestCase

@end

@implementation ALCInitializerInstantiatorTests

-(void) testBuilderName {
    id<ALCBuilder> classBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    ignoreSelectorWarnings(
                           ALCInitializerInstantiator *instantiator = [[ALCInitializerInstantiator alloc] initWithClassBuilder:classBuilder initializer:@selector(initAlternative)];
    )
    XCTAssertEqualObjects(@"SimpleObject initAlternative", instantiator.builderName);
}

-(void) testInstantiateWithSimpleMethod {
    id<ALCBuilder> classBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    ignoreSelectorWarnings(
                           ALCInitializerInstantiator *instantiator = [[ALCInitializerInstantiator alloc] initWithClassBuilder:classBuilder initializer:@selector(initAlternative)];
                           )
    SimpleObject *so = [instantiator instantiateWithArguments:@[]];
    XCTAssertNotNil(so);
}

-(void) testInstantiateWithMethodWithArg {
    id<ALCBuilder> classBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    ignoreSelectorWarnings(
                           ALCInitializerInstantiator *instantiator = [[ALCInitializerInstantiator alloc] initWithClassBuilder:classBuilder initializer:@selector(initWithString:)];
                           )
    SimpleObject *so = [instantiator instantiateWithArguments:@[@"abc"]];
    XCTAssertNotNil(so);
    XCTAssertEqualObjects(@"abc", so.aStringProperty);
}

@end
