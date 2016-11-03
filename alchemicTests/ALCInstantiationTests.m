//
//  ALCInstantiationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/7/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;


@interface ALCInstantiationTests : XCTestCase
@end

@implementation ALCInstantiationTests

-(void) testFactoryMethodStoresObject {
    ALCValue *value = [ALCValue withObject:@"abc" completion:NULL];
    XCTAssertEqualObjects(@"abc", value.object);
}

-(void) testCompletionCallsBlock {

    __block BOOL blockCalled = NO;
    ALCValue *value = [ALCValue withObject:@"abc" completion:^(id obj) {
        blockCalled = YES;
    }];

    [value complete];

    XCTAssertTrue(blockCalled);
}

@end
