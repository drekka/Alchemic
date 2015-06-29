//
//  STExpressionMatcherFactoryTests.m
//  StoryTeller
//
//  Created by Derek Clarkson on 25/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <OCMock/OCMock.h>
#import <StoryTeller/StoryTeller.h>
#import "STExpressionMatcherFactory.h"
#import "STMatcher.h"

@interface B : NSObject
@property (nonatomic, assign) BOOL y;
@end

@implementation B
@end

@protocol C <NSObject>
@property (nonatomic, assign) int x;
@end

@interface A : NSObject<C>
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) B *b;
@end

@implementation A
@synthesize x = _x;
@end

@interface STExpressionMatcherFactoryTests : XCTestCase
@end

@implementation STExpressionMatcherFactoryTests {
    STExpressionMatcherFactory *_factory;
    id _mockStoryTeller;
}

-(void) setUp {
    _factory = [[STExpressionMatcherFactory alloc] init];

    // Mock out story teller.
    _mockStoryTeller = OCMClassMock([STStoryTeller class]);
    OCMStub([_mockStoryTeller storyTeller]).andReturn(_mockStoryTeller);
}

-(void) tearDown {
    [_mockStoryTeller stopMocking];
}

#pragma mark - Options

-(void) testLogAll {
    id<STMatcher> matcher = [_factory parseExpression:@"LogAll" error:NULL];
    XCTAssertNil(matcher);
    OCMVerify([_mockStoryTeller logAll]);
}

-(void) testLogRoots {
    id<STMatcher> matcher = [_factory parseExpression:@"LogRoots" error:NULL];
    XCTAssertNil(matcher);
    OCMVerify([_mockStoryTeller logRoots]);
}

#pragma mark - Simple values

-(void) testStringMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"abc" error:NULL];
    XCTAssertTrue([matcher matches:@"abc"]);
}

-(void) testStringFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"abc" error:NULL];
    XCTAssertFalse([matcher matches:@"def"]);
}

-(void) testNumberMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"12" error:NULL];
    XCTAssertTrue([matcher matches:@12]);
}

-(void) testNumberFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"12.5" error:NULL];
    XCTAssertFalse([matcher matches:@12.678]);
}

#pragma mark - Classes

-(void) testClassMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[NSString]" error:NULL];
    XCTAssertTrue([matcher matches:@"abc"]);
}

-(void) testClassUnknown {
    NSError *error = nil;
    id<STMatcher> matcher = [_factory parseExpression:@"[Abc]" error:&error];
    XCTAssertNil(matcher);
    XCTAssertEqualObjects(@"Unable to find class Abc\nLine : Unknown\n", error.localizedFailureReason);
}

-(void) testClassFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"[NSString]" error:NULL];
    XCTAssertFalse([matcher matches:@12]);
}

#pragma mark - Properties

-(void) testClassStringPropertyQuotedMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].string == \"abc\"" error:NULL];
    A *a = [[A alloc] init];
    a.string = @"abc";
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassStringPropertyUnQuotedMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].string == abc" error:NULL];
    A *a = [[A alloc] init];
    a.string = @"abc";
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassStringPropertyUnQuotedFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].string == abc" error:NULL];
    A *a = [[A alloc] init];
    a.string = @"def";
    XCTAssertFalse([matcher matches:a]);
}

-(void) testClassStringPropertyNilMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].string == nil" error:NULL];
    A *a = [[A alloc] init];
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassStringPropertyNilNotEqualMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].string != nil" error:NULL];
    A *a = [[A alloc] init];
    a.string = @"def";
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassStringPropertyNilFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].string == nil" error:NULL];
    A *a = [[A alloc] init];
    a.string = @"def";
    XCTAssertFalse([matcher matches:a]);
}

-(void) testClassIntPropertyEqualsMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x == 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 5;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassIntPropertyNotEqualsMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x != 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 1;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassIntPropertyGTMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x > 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 6;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassIntPropertyGTFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x > 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 5;
    XCTAssertFalse([matcher matches:a]);
}

-(void) testClassIntPropertyGEWhenEqualMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x >= 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 5;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassIntPropertyGEMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x >= 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 6;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassIntPropertyGEFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x >= 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 4;
    XCTAssertFalse([matcher matches:a]);
}

-(void) testClassIntPropertyLTMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x < 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 4;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassIntPropertyLTFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x < 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 5;
    XCTAssertFalse([matcher matches:a]);
}

-(void) testClassIntPropertyLEWhenEqualMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x <= 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 5;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassIntPropertyLEWhenEqualFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x <= 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 6;
    XCTAssertFalse([matcher matches:a]);
}

-(void) testClassIntPropertyLEMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].x <= 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 4;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassInvalidStringProperty {
    NSError *error = nil;
    id<STMatcher> matcher = [_factory parseExpression:@"[A].xxxx == abc" error:&error];
    A *a = [[A alloc] init];
    a.string = @"def";
    XCTAssertThrowsSpecificNamed([matcher matches:a], NSException, @"NSUnknownKeyException");
}

-(void) testClassBoolNestedPropertyTrueMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].b.y == true" error:NULL];
    A *a = [[A alloc] init];
    B *b = [[B alloc] init];
    a.b = b;
    b.y = YES;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassBoolNestedPropertyNotFalseMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].b.y != false" error:NULL];
    A *a = [[A alloc] init];
    B *b = [[B alloc] init];
    a.b = b;
    b.y = YES;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassBoolNestedPropertyYesMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"[A].b.y == YES" error:NULL];
    A *a = [[A alloc] init];
    B *b = [[B alloc] init];
    a.b = b;
    b.y = YES;
    XCTAssertTrue([matcher matches:a]);
}

-(void) testClassBoolNestedPropertyInvalidOp {
    NSError *error = nil;
    id<STMatcher> matcher = [_factory parseExpression:@"[A].b.y > YES" error:&error];
    XCTAssertNil(matcher);
    XCTAssertEqualObjects(@"Failed to match next input token", error.localizedDescription);
}

#pragma mark - Protocols

-(void) testProtocolMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"<NSCopying>" error:NULL];
    XCTAssertTrue([matcher matches:@"abc"]);
}

-(void) testProtocolUnknown {
    NSError *error = nil;
    id<STMatcher> matcher = [_factory parseExpression:@"<Abc>" error:&error];
    XCTAssertNil(matcher);
    XCTAssertEqualObjects(@"Unable to find protocol Abc\nLine : Unknown\n", error.localizedFailureReason);
}

-(void) testProtocolFailsMatch {
    id<STMatcher> matcher = [_factory parseExpression:@"<NSFastEnumeration>" error:NULL];
    XCTAssertFalse([matcher matches:@12]);
}

-(void) testProtocolIntPropertyMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"<C>.x == 5" error:NULL];
    A *a = [[A alloc] init];
    a.x = 5;
    XCTAssertTrue([matcher matches:a]);
}

#pragma mark - Runtime

-(void) testIsaClassMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"isa [A]" error:NULL];
    XCTAssertTrue([matcher matches:[A class]]);
}

-(void) testIsaProtocolMatches {
    id<STMatcher> matcher = [_factory parseExpression:@"isa <C>" error:NULL];
    XCTAssertTrue([matcher matches:@protocol(C)]);
}

@end
