//
//  ALCModelTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 3/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <OCMock/OCMock.h>
#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>

#import "ALCBuilder.h"
#import "ALCBuilder.h"
#import "ALCBuilder.h"
#import "ALCBuilderStorageSingleton.h"
#import "ALCMacroProcessor.h"
#import "ALCBuilderType.h"
#import "ALCMethodBuilderType.h"

#import "ALCModel.h"

@interface ALCModelTests : ALCTestCase

@end

@implementation ALCModelTests {
    ALCModel *_model;
    ALCBuilder *_classBuilder;
    ALCBuilder *_methodBuilder;
}

-(void) setUp {

    [super setUp];
    [self setupMockContext];

    _model = [[ALCModel alloc] init];
    _classBuilder = [self simpleBuilderForClass:[ALCModelTests class]];
    [_classBuilder.macroProcessor addMacro:AcWithName(@"abc")];
    [_classBuilder configure];

    id<ALCBuilderType> builderType = [[ALCMethodBuilderType alloc] initWithType:[NSString class]
                                                             parentClassBuilder:_classBuilder
                                                                       selector:@selector(someMethod)];
    _methodBuilder = [[ALCBuilder alloc] initWithBuilderType:builderType];
    [_methodBuilder.macroProcessor addMacro:AcWithName(@"def")];
    [_methodBuilder configure];

    [_model addBuilder:_classBuilder];
    [_model addBuilder:_methodBuilder];
}

-(void) testNumberBuilders {
    XCTAssertEqual(2u, [_model numberBuilders]);
}

#pragma mark - Querying

-(void) testBuildersForSearchExpressionWhenNoResults {
    NSSet<ALCBuilder *> *results = [_model buildersForSearchExpressions:[NSSet setWithObject:AcName(@"fred")]];
    XCTAssertEqual(0u, [results count]);
}

-(void) testBuildersForSearchExpressionSimpleQuery {
    STStartLogging(ALCHEMIC_LOG);
    NSSet<ALCBuilder *> *results = [_model buildersForSearchExpressions:[NSSet setWithObject:AcName(@"abc")]];
    XCTAssertEqual(1u, [results count]);
    XCTAssertEqual([ALCModelTests class], [results anyObject].valueClass);
    XCTAssertEqual(@"abc", [results anyObject].name);
}

-(void) testBuildersForSearchExpressionComplexQuery {
    id<ALCModelSearchExpression> expression1 = AcName(@"abc");
    id<ALCModelSearchExpression> expression2 = AcClass(ALCModelTests);
    NSSet<ALCBuilder *> *results = [_model buildersForSearchExpressions:[NSSet setWithObjects:expression1, expression2, nil]];
    XCTAssertEqual(1u, [results count]);
    XCTAssertEqual([ALCModelTests class], [results anyObject].valueClass);
    XCTAssertEqual(@"abc", [results anyObject].name);
}

-(void) testBuildersForSearchExpressionComplexWideRangeQuery {
    id<ALCModelSearchExpression> expression1 = AcClass(NSObject);
    id<ALCModelSearchExpression> expression2 = AcProtocol(NSCopying);
    NSSet<ALCBuilder *> *results = [_model buildersForSearchExpressions:[NSSet setWithObjects:expression2, expression1, nil]];
    XCTAssertEqual(1u, [results count]);
    XCTAssertEqual([NSString class], [results anyObject].valueClass);
    XCTAssertEqual(@"def", [results anyObject].name);
}

-(void) testBuildersForSearchExpressionSecondQueryReturnsCachedResults {
    id<ALCModelSearchExpression> expression1 = AcClass(ALCModelTests);
    NSSet<ALCBuilder *> *result1 = [_model buildersForSearchExpressions:[NSSet setWithObject:expression1]];
    NSSet<ALCBuilder *> *result2 = [_model buildersForSearchExpressions:[NSSet setWithObject:expression1]];
    XCTAssertEqual(result1, result2);
}

#pragma mark - Accessing builders

-(void) testAllBuilders {
    NSSet<ALCBuilder *> *results = [_model allBuilders];
    XCTAssertEqual(2u, [results count]);
    XCTAssertTrue([results containsObject:_classBuilder]);
    XCTAssertTrue([results containsObject:_methodBuilder]);
}

-(void) testClassBuildersFromBuilders {
    NSSet<ALCBuilder *> *results = [_model classBuildersFromBuilders:[_model allBuilders]];
    XCTAssertEqual(1u, [results count]);
    XCTAssertTrue([results containsObject:_classBuilder]);
}

#pragma mark - Names and indexing

-(void) testRegisteringDuplicateNames {
    ALCBuilder *dupClassBuilder = [self simpleBuilderForClass:[ALCModelTests class]];
    [dupClassBuilder.macroProcessor addMacro:AcWithName(@"abc")];
    [dupClassBuilder configure];
    XCTAssertThrowsSpecificNamed([_model addBuilder:dupClassBuilder], NSException, @"AlchemicDuplicateName");
}

#pragma mark - Internal

-(NSString *) someMethod {
    return @"xyc";
}

@end
