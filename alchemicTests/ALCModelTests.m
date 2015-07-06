//
//  ALCModelTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 3/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <OCMock/OCMock.h>
#import <StoryTeller/StoryTeller.h>

#import "ALCModel.h"
#import "ALCBuilder.h"
#import "ALCClassBuilder.h"
#import <Alchemic/Alchemic.h>

@interface ALCModelTests : XCTestCase

@end

@implementation ALCModelTests {
    ALCModel *_model;
    id _mockContext;
    ALCClassBuilder *_builder;
}

-(void) setUp {
    STStartLogging(ALCHEMIC_LOG);
    _model = [[ALCModel alloc] init];
    _mockContext = OCMClassMock([ALCContext class]);
    _builder = [[ALCClassBuilder alloc] initWithContext:_mockContext
                                                             valueClass:[NSString class]
                                                                   name:@"abc"];
}

-(void) testSimpleQuery {
    [_model addBuilder:_builder];
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@"abc"];
    NSSet<id<ALCBuilder>> *result = [_model buildersMatchingQualifiers:[NSSet setWithObject:qualifier]];
    XCTAssertEqual(1u, [result count]);
    XCTAssertEqual([NSString class], [result anyObject].valueClass);
}

-(void) testSecondQueryReturnsCachedResults {
    [_model addBuilder:_builder];
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@"abc"];
    NSSet<id<ALCBuilder>> *result1 = [_model buildersMatchingQualifiers:[NSSet setWithObject:qualifier]];
    NSSet<id<ALCBuilder>> *result2 = [_model buildersMatchingQualifiers:[NSSet setWithObject:qualifier]];
    XCTAssertEqual(result1, result2);
}


@end
