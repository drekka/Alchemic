//
//  OnLoadIntegrationTests.m
//  alchemic
//
//  Created by Derek Clarkson on 12/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>

@interface OnLoadIntegrationTests : ALCTestCase

@end

@implementation OnLoadIntegrationTests

-(void) testIntegrationCallbackBlock {

    XCTestExpectation *blockExecuted = [self expectationWithDescription:@"callback-executed"];

    [self setupRealContext];

    AcExecuteWhenStarted(^{
        XCTAssertTrue([NSThread isMainThread]);
        [blockExecuted fulfill];
    });

    // Start on background thread.
    dispatch_async(dispatch_queue_create("TestBG", NULL), ^{
        [self startContextWithClasses:@[]];
    });

    [self waitForExpectationsWithTimeout:10.0f handler:nil];

}

-(void) testIntegrationCallbackBlockWhenAlreadyStarted {

    XCTestExpectation *blockExecuted = [self expectationWithDescription:@"callback-executed"];

    [self setupRealContext];
    [self startContextWithClasses:@[]];

    // from a background thread - execute the callback and test it's called on the background thread instead of the main thread.
    dispatch_async(dispatch_queue_create("TestBG", NULL), ^{
        NSThread *testBGThread = [NSThread currentThread];
        __block BOOL executed = NO;
        AcExecuteWhenStarted(^{
            executed = YES;
            XCTAssertTrue([[NSThread currentThread] isEqual:testBGThread]);
            [blockExecuted fulfill];
        });
        XCTAssertTrue(executed);
    });

    [self waitForExpectationsWithTimeout:10.0f handler:nil];
    
}

@end
