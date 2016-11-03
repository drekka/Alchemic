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
    ALCInstantiation *inst = [ALCInstantiation instantiationWithObject:@"abc" completion:NULL];
    XCTAssertEqualObjects(@"abc", inst.object);
}

-(void) testCompletionCallsBlock {

    __block BOOL blockCalled = NO;
    ALCInstantiation *inst = [ALCInstantiation instantiationWithObject:@"abc" completion:^(id obj) {
        blockCalled = YES;
    }];

    [inst complete];

    XCTAssertTrue(blockCalled);
}

@end
