//
//  STCompareMatcherTests.m
//  StoryTeller
//
//  Created by Derek Clarkson on 26/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "STCompareMatcher.h"
#import <OCMock/OCMock.h>

@interface STCompareMatcherTests : XCTestCase

@end

@implementation STCompareMatcherTests

-(void) testCallsNextMatcherWhenMatches {

    __block BOOL compareCalled = NO;
    id mockMatcher = OCMProtocolMock(@protocol(STMatcher));
    OCMStub([mockMatcher matches:@"abc"]).andReturn(YES);

    STCompareMatcher *matcher = [[STCompareMatcher alloc] initWithCompare:^BOOL(id  __nonnull key) {
        compareCalled = YES;
        return YES;
    }];

    matcher.nextMatcher = mockMatcher;

    XCTAssertTrue([matcher matches:@"abc"]);
    OCMVerify([mockMatcher matches:@"abc"]);
    
}

-(void) testHandlesNilNextMatcher {

}

-(void) testDoesntCallNextMatcherWhenMatchFails {

}

@end
