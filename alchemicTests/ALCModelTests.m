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
}

-(void) setUp {
    STStartLogging(ALCHEMIC_LOG);
    _model = [[ALCModel alloc] init];
    _mockContext = OCMClassMock([ALCContext class]);
}

-(void) testQueryClass {
    ALCClassBuilder *builder = [[ALCClassBuilder alloc] initWithContext:_mockContext
                                                             valueClass:[NSString class]
                                                                   name:@"abc"];
    [_model addBuilder:builder];
    NSSet<id<ALCBuilder>> *result = [_model buildersWithClass:[NSString class]];
    XCTAssertEqual(1u, [result count]);
    XCTAssertEqual([NSString class], [result anyObject].valueClass);
}

-(void) testQueryProtocol {
    ALCClassBuilder *builder = [[ALCClassBuilder alloc] initWithContext:_mockContext
                                                             valueClass:[NSString class]
                                                                   name:@"abc"];
    [_model addBuilder:builder];
    NSSet<id<ALCBuilder>> *result = [_model buildersWithClass:[NSString class]];
    XCTAssertEqual(1u, [result count]);
    XCTAssertEqual(builder, [result anyObject]);
}

-(void) testQueryName {
    ALCClassBuilder *builder = [[ALCClassBuilder alloc] initWithContext:_mockContext
                                                             valueClass:[NSString class]
                                                                   name:@"abc"];
    [_model addBuilder:builder];
    NSSet<id<ALCBuilder>> *result = [_model buildersWithName:@"abc"];
    XCTAssertEqual(1u, [result count]);
    XCTAssertEqual(@"abc", [result anyObject].name);
}

-(void) testSecondQueryReturnsCachedResults {
    ALCClassBuilder *builder = [[ALCClassBuilder alloc] initWithContext:_mockContext
                                                             valueClass:[NSString class]
                                                                   name:@"abc"];
    [_model addBuilder:builder];

    NSSet<id<ALCBuilder>> *result1 = [_model buildersWithClass:[NSString class]];
    NSSet<id<ALCBuilder>> *result2 = [_model buildersWithClass:[NSString class]];
    XCTAssertEqual(result1, result2);
}


@end
