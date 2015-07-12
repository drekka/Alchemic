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
#import "ALCMethodBuilder.h"
#import <Alchemic/Alchemic.h>

@interface ALCModelTests : XCTestCase

@end

@implementation ALCModelTests {
    ALCModel *_model;
    id _mockContext;
    id<ALCBuilder> _builder1;
    id<ALCBuilder> _builder2;
}

-(void) setUp {
    _model = [[ALCModel alloc] init];
    _mockContext = OCMClassMock([ALCContext class]);
    _builder1 = [[ALCClassBuilder alloc] initWithContext:_mockContext
                                              valueClass:[ALCModelTests class]
                                                    name:@"abc"];
    _builder2 = [[ALCMethodBuilder alloc] initWithContext:_mockContext
                                               valueClass:[NSString class]
                                                     name:@"def"
                                       parentClassBuilder:_builder1
                                                 selector:@selector(someMethod)
                                               qualifiers:@[]];
    [_model addBuilder:_builder1];
    [_model addBuilder:_builder2];
}

-(void) testSimpleQuery {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@"abc"];
    NSSet<id<ALCBuilder>> *results = [_model buildersForQualifiers:[NSSet setWithObject:qualifier]];
    XCTAssertEqual(1u, [results count]);
    XCTAssertEqual([ALCModelTests class], [results anyObject].valueClass);
    XCTAssertEqual(@"abc", [results anyObject].name);
}

-(void) testComplexQuery {
    ALCQualifier *qualifier1 = [ALCQualifier qualifierWithValue:@"abc"];
    ALCQualifier *qualifier2 = [ALCQualifier qualifierWithValue:[ALCModelTests class]];
    NSSet<id<ALCBuilder>> *results = [_model buildersForQualifiers:[NSSet setWithObjects:qualifier1, qualifier2, nil]];
    XCTAssertEqual(1u, [results count]);
    XCTAssertEqual([ALCModelTests class], [results anyObject].valueClass);
    XCTAssertEqual(@"abc", [results anyObject].name);
}

-(void) testSecondQueryReturnsCachedResults {
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@"abc"];
    NSSet<id<ALCBuilder>> *result1 = [_model buildersForQualifiers:[NSSet setWithObject:qualifier]];
    NSSet<id<ALCBuilder>> *result2 = [_model buildersForQualifiers:[NSSet setWithObject:qualifier]];
    XCTAssertEqual(result1, result2);
}

-(void) testAllBuilders {
    NSSet<id<ALCBuilder>> *results = [_model allBuilders];
    XCTAssertEqual(2u, [results count]);
    XCTAssertTrue([results containsObject:_builder1]);
    XCTAssertTrue([results containsObject:_builder2]);
}

-(void) testClassBuildersFromBuilders {
    NSSet<id<ALCBuilder>> *results = [_model classBuildersFromBuilders:[_model allBuilders]];
    XCTAssertEqual(1u, [results count]);
    XCTAssertTrue([results containsObject:_builder1]);
}

#pragma mark - Internal

-(NSString *) someMethod {
    return @"xyc";
}

@end
