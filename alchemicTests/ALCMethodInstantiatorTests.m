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
#import "ALCBuilder.h"

@interface ALCMethodInstantiatorTests : ALCTestCase

@end

@implementation ALCMethodInstantiatorTests

-(void) testBuilderName {
    ALCMethodInstantiator *instantiator = [[ALCMethodInstantiator alloc] initWithClass:[ALCMethodInstantiatorTests class]
                                                                            returnType:[SimpleObject class]
                                                                              selector:@selector(createSO)];
    XCTAssertEqualObjects(@"ALCMethodInstantiatorTests createSO", instantiator.builderName);
}

-(void) testInstantiateWithSimpleMethod {
    ALCBuilder *classBuilder = [self simpleBuilderForClass:[ALCMethodInstantiatorTests class]];
    [self configureAndResolveBuilder:classBuilder];
    ALCMethodInstantiator *instantiator = [[ALCMethodInstantiator alloc] initWithClass:[ALCMethodInstantiatorTests class]
                                                                            returnType:[SimpleObject class]
                                                                              selector:@selector(createSO)];
    SimpleObject *so = [instantiator instantiateWithClassBuilder:classBuilder arguments:@[]];
    XCTAssertNotNil(so);
}

-(void) testInstantiateWithMethodWithOneArg {
    ALCBuilder *classBuilder = [self simpleBuilderForClass:[ALCMethodInstantiatorTests class]];
    [self configureAndResolveBuilder:classBuilder];
    ALCMethodInstantiator *instantiator = [[ALCMethodInstantiator alloc] initWithClass:[ALCMethodInstantiatorTests class]
                                                                            returnType:[SimpleObject class]
                                                                              selector:@selector(createSOWithString:)];
    SimpleObject *so = [instantiator instantiateWithClassBuilder:classBuilder arguments:@[@"abc"]];
    XCTAssertNotNil(so);
}

-(void) testInstantiateWithMethodWithOneNilArg {
    ALCBuilder *classBuilder = [self simpleBuilderForClass:[ALCMethodInstantiatorTests class]];
    [self configureAndResolveBuilder:classBuilder];
    ALCMethodInstantiator *instantiator = [[ALCMethodInstantiator alloc] initWithClass:[ALCMethodInstantiatorTests class]
                                                                            returnType:[SimpleObject class]
                                                                              selector:@selector(createSOWithNilString:)];
    SimpleObject *so = [instantiator instantiateWithClassBuilder:classBuilder arguments:@[]];
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
