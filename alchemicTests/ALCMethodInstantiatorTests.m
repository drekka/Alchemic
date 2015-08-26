//
//  ALCMethodInstantiatorTests.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCTestCase.h"
#import "SimpleObject.h"
#import "ALCMethodInstantiator.h"
#import "ALCBuilder.h"

@interface ALCMethodInstantiatorTests : ALCTestCase

@end

@implementation ALCMethodInstantiatorTests

-(void) testBuilderName {
    id<ALCBuilder> classBuilder = [self simpleBuilderForClass:[ALCMethodInstantiatorTests class]];
    ALCMethodInstantiator *instantiator = [[ALCMethodInstantiator alloc] initWithClassBuilder:classBuilder selector:@selector(createSO)];
    XCTAssertEqualObjects(@"ALCMethodInstantiatorTests createSO", instantiator.builderName);
}

-(void) testInstantiateWithSimpleMethod {
    id<ALCBuilder> classBuilder = [self simpleBuilderForClass:[ALCMethodInstantiatorTests class]];
    ALCMethodInstantiator *instantiator = [[ALCMethodInstantiator alloc] initWithClassBuilder:classBuilder selector:@selector(createSO)];
    SimpleObject *so = [instantiator instantiateWithArguments:@[]];
    XCTAssertNotNil(so);
}

-(void) testInstantiateWithMethodWithOneArg {
    id<ALCBuilder> classBuilder = [self simpleBuilderForClass:[ALCMethodInstantiatorTests class]];
    ALCMethodInstantiator *instantiator = [[ALCMethodInstantiator alloc] initWithClassBuilder:classBuilder selector:@selector(createSOWithString:)];
    SimpleObject *so = [instantiator instantiateWithArguments:@[@"abc"]];
    XCTAssertNotNil(so);
}

-(void) testInstantiateWithMethodWithOneNilArg {
    id<ALCBuilder> classBuilder = [self simpleBuilderForClass:[ALCMethodInstantiatorTests class]];
    ALCMethodInstantiator *instantiator = [[ALCMethodInstantiator alloc] initWithClassBuilder:classBuilder selector:@selector(createSOWithNilString:)];
    SimpleObject *so = [instantiator instantiateWithArguments:@[]];
    XCTAssertNotNil(so);
}

#pragma mark - Internal

-(SimpleObject *) createSO {
    return [[SimpleObject alloc] init];
}

-(SimpleObject *) createSOWithString:(NSString *) aString {
    XCTAssertEqualObjects(@"abc", aString);
    return [[SimpleObject alloc] init];
}

-(SimpleObject *) createSOWithNilString:(NSString *) aString {
    XCTAssertNil(aString);
    return [[SimpleObject alloc] init];
}

@end
