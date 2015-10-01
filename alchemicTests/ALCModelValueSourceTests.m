//
//  ALCModelValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <OCMock/OCMock.h>
#import <Alchemic/Alchemic.h>

#import "ALCTestCase.h"
#import "ALCModelValueSource.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCResolvable.h"
#import "SimpleObject.h"
#import "ALCBuilder.h"

@interface ALCModelValueSourceTests : ALCTestCase

@end

@implementation ALCModelValueSourceTests {
	ALCModelValueSource *_source;
	NSSet<id<ALCModelSearchExpression>> * _searchExpressions;
    id _mockBuilder;
}

-(void) setUp {

	[super setUp];
	[self setupMockContext];

	_searchExpressions = [NSSet setWithObject:AcName(@"abc")];
    _source = [[ALCModelValueSource alloc] initWithType:[SimpleObject class]
                                      searchExpressions:_searchExpressions];
    _mockBuilder = OCMClassMock([ALCBuilder class]);
}

#pragma mark - Setup

-(void) testInitWithTypeThrowsWhenNoExpressions {
    XCTAssertThrowsSpecificNamed([[ALCModelValueSource alloc] initWithType:[SimpleObject class]
                                      searchExpressions:[NSSet set]], NSException, @"AlchemicMissingSearchExpressions");
}

#pragma mark - Values

-(void) testValues {
    [self stubMockContextToReturnBuilders:@[_mockBuilder]];
    OCMStub([(ALCBuilder *)_mockBuilder value]).andReturn(@"abc");
    [_source resolve];
    NSSet<id> *values = _source.values;
    XCTAssertEqual(1u, [values count]);
    XCTAssertEqualObjects(@"abc", [values anyObject]);
}

#pragma mark - Will Resolve

-(void) testWillResolve {
    [self stubMockContextToReturnBuilders:@[_mockBuilder]];
    [_source resolve];
    NSSet<id<ALCResolvable>> *dependencies = _source.dependencies;
    XCTAssertEqual(1u, [dependencies count]);
    XCTAssertTrue([dependencies containsObject:_mockBuilder]);
}

-(void) testWillResolveWhenPrimaryObjectPresent {
    id mockBuilder2 = OCMClassMock([ALCBuilder class]);
    OCMStub([mockBuilder2 primary]).andReturn(YES);
    [self stubMockContextToReturnBuilders:@[_mockBuilder, mockBuilder2]];
    [_source resolve];
    NSSet<id<ALCResolvable>> *dependencies = _source.dependencies;
    XCTAssertEqual(1u, [dependencies count]);
    XCTAssertTrue([dependencies containsObject:mockBuilder2]);
}

-(void) testWillResolveThrowsWhenNoResults {
    [self stubMockContextToReturnBuilders:@[]];
    XCTAssertThrowsSpecificNamed([_source resolve], NSException, @"AlchemicNoCandidateBuildersFound");
}

-(void) testDescription {
    XCTAssertEqualObjects(@"Value Source for SimpleObject -> Model search: 'abc'", [_source description]);
}

@end
