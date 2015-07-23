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
#import <Alchemic/Alchemic.h>

#import "ALCModel.h"
#import "ALCBuilder.h"
#import "ALCClassBuilder.h"
#import "ALCMethodBuilder.h"
#import "ALCMethodMacroProcessor.h"

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
    _builder1 = [[ALCClassBuilder alloc] initWithValueClass:[ALCModelTests class]];
    _builder2 = [[ALCMethodBuilder alloc] initWithValueClass:[NSString class]];
	[(ALCClassBuilder *)_builder1 addMethodBuilder:_builder2];
    [_model addBuilder:_builder1];
    [_model addBuilder:_builder2];
}

-(void) testSimpleQuery {
    id<ALCModelSearchExpression> expression = [ALCName withName:@"abc"];
    NSSet<id<ALCBuilder>> *results = [_model buildersForSearchExpressions:[NSSet setWithObject:expression]];
    XCTAssertEqual(1u, [results count]);
    XCTAssertEqual([ALCModelTests class], [results anyObject].valueClass);
    XCTAssertEqual(@"abc", [results anyObject].name);
}

-(void) testComplexQuery {
    id<ALCModelSearchExpression> expression1 = [ALCName withName:@"abc"];
    id<ALCModelSearchExpression> expression2 = [ALCClass withClass:[ALCModelTests class]];
    NSSet<id<ALCBuilder>> *results = [_model buildersForSearchExpressions:[NSSet setWithObjects:expression1, expression2, nil]];
    XCTAssertEqual(1u, [results count]);
    XCTAssertEqual([ALCModelTests class], [results anyObject].valueClass);
    XCTAssertEqual(@"abc", [results anyObject].name);
}

-(void) testSecondQueryReturnsCachedResults {
    id<ALCModelSearchExpression> expression1 = [ALCName withName:@"abc"];
    NSSet<id<ALCBuilder>> *result1 = [_model buildersForSearchExpressions:[NSSet setWithObject:expression1]];
    NSSet<id<ALCBuilder>> *result2 = [_model buildersForSearchExpressions:[NSSet setWithObject:expression1]];
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
