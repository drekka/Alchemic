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
#import "ALCInternalMacros.h"
#import "ALCClassBuilder.h"

@interface ALCInitializerInstantiatorTests : ALCTestCase

@end

@implementation ALCInitializerInstantiatorTests

-(void) testBuilderName {
    ignoreSelectorWarnings(
                           ALCInitializerInstantiator *instantiator = [[ALCInitializerInstantiator alloc] initWithClass:[SimpleObject class]
                                                                                                            initializer:@selector(initAlternative)];
                           )
    XCTAssertEqualObjects(@"SimpleObject initAlternative", instantiator.builderName);
}

-(void) testInstantiateWithSimpleMethod {
    ignoreSelectorWarnings(
                           ALCInitializerInstantiator *instantiator = [[ALCInitializerInstantiator alloc] initWithClass:[SimpleObject class]
                                                                                                            initializer:@selector(initAlternative)];
                           )
    ALCClassBuilder *classBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    SimpleObject *so = [instantiator instantiateWithClassBuilder:classBuilder arguments:@[]];
    XCTAssertNotNil(so);
}

-(void) testInstantiateWithMethodWithArg {
    ignoreSelectorWarnings(
                           ALCInitializerInstantiator *instantiator = [[ALCInitializerInstantiator alloc] initWithClass:[SimpleObject class]
                                                                                                            initializer:@selector(initWithString:)];
                           )
    ALCClassBuilder *classBuilder = [self simpleBuilderForClass:[SimpleObject class]];
    SimpleObject *so = [instantiator instantiateWithClassBuilder:classBuilder arguments:@[@"abc"]];
    XCTAssertNotNil(so);
    XCTAssertEqualObjects(@"abc", so.aStringProperty);
}

@end
