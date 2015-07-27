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

#import "ALCModel.h"
#import "ALCSearchableBuilder.h"
#import "ALCClassBuilder.h"
#import "ALCMethodBuilder.h"
#import "ALCMethodMacroProcessor.h"

@interface ALCModelTests : ALCTestCase

@end

@implementation ALCModelTests {
	ALCModel *_model;
	id<ALCSearchableBuilder> _classBuilder;
	id<ALCSearchableBuilder> _methodBuilder;
}

-(void) setUp {

	[super setUp];
	[self setupMockContext];

	_model = [[ALCModel alloc] init];
	_classBuilder = [[ALCClassBuilder alloc] initWithValueClass:[ALCModelTests class]];
	((ALCClassBuilder *)_classBuilder).name = @"abc";

	_methodBuilder = [[ALCMethodBuilder alloc] initWithSelector:@selector(someMethod) valueClass:[NSString class]];
	[(ALCClassBuilder *)_classBuilder addMethodBuilder:_methodBuilder];
	((ALCClassBuilder *)_methodBuilder).name = @"def";

	[_model addBuilder:_classBuilder];
	[_model addBuilder:_methodBuilder];
}

-(void) testNumberBuilders {
	XCTAssertEqual(2u, [_model numberBuilders]);
}

#pragma mark - Querying

-(void) testBuildersForSearchExpressionWhenNoResults {
	NSSet<id<ALCBuilder>> *results = [_model buildersForSearchExpressions:[NSSet setWithObject:AcName(@"fred")]];
	XCTAssertEqual(0u, [results count]);
}

-(void) testBuildersForSearchExpressionSimpleQuery {
	STStartLogging(ALCHEMIC_LOG);
	NSSet<id<ALCSearchableBuilder>> *results = [_model buildersForSearchExpressions:[NSSet setWithObject:AcName(@"abc")]];
	XCTAssertEqual(1u, [results count]);
	XCTAssertEqual([ALCModelTests class], [results anyObject].valueClass);
	XCTAssertEqual(@"abc", [results anyObject].name);
}

-(void) testBuildersForSearchExpressionComplexQuery {
	id<ALCModelSearchExpression> expression1 = AcName(@"abc");
	id<ALCModelSearchExpression> expression2 = AcClass(ALCModelTests);
	NSSet<id<ALCSearchableBuilder>> *results = [_model buildersForSearchExpressions:[NSSet setWithObjects:expression1, expression2, nil]];
	XCTAssertEqual(1u, [results count]);
	XCTAssertEqual([ALCModelTests class], [results anyObject].valueClass);
	XCTAssertEqual(@"abc", [results anyObject].name);
}

-(void) testBuildersForSearchExpressionComplexWideRangeQuery {
	id<ALCModelSearchExpression> expression1 = AcClass(NSObject);
	id<ALCModelSearchExpression> expression2 = AcProtocol(NSCopying);
	NSSet<id<ALCSearchableBuilder>> *results = [_model buildersForSearchExpressions:[NSSet setWithObjects:expression2, expression1, nil]];
	XCTAssertEqual(1u, [results count]);
	XCTAssertEqual([NSString class], [results anyObject].valueClass);
	XCTAssertEqual(@"def", [results anyObject].name);
}

-(void) testBuildersForSearchExpressionSecondQueryReturnsCachedResults {
	id<ALCModelSearchExpression> expression1 = AcName(@"abc");
	NSSet<id<ALCBuilder>> *result1 = [_model buildersForSearchExpressions:[NSSet setWithObject:expression1]];
	NSSet<id<ALCBuilder>> *result2 = [_model buildersForSearchExpressions:[NSSet setWithObject:expression1]];
	XCTAssertEqual(result1, result2);
}

#pragma mark - Accessing builders

-(void) testAllBuilders {
	NSSet<id<ALCBuilder>> *results = [_model allBuilders];
	XCTAssertEqual(2u, [results count]);
	XCTAssertTrue([results containsObject:_classBuilder]);
	XCTAssertTrue([results containsObject:_methodBuilder]);
}

-(void) testAllClassBuilders {
	NSSet<id<ALCBuilder>> *results = [_model allClassBuilders];
	XCTAssertEqual(1u, [results count]);
	XCTAssertTrue([results containsObject:_classBuilder]);
}

-(void) testClassBuildersFromBuilders {
	NSSet<id<ALCBuilder>> *results = [_model classBuildersFromBuilders:[_model allBuilders]];
	XCTAssertEqual(1u, [results count]);
	XCTAssertTrue([results containsObject:_classBuilder]);
}

#pragma mark - Internal

-(NSString *) someMethod {
	return @"xyc";
}

@end
