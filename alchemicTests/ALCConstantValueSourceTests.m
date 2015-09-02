//
//  ALCConstantValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCConstantValueSource.h"
#import "ALCResolvable.h"

@interface ALCConstantValueSourceTests : XCTestCase

@end

@implementation ALCConstantValueSourceTests

-(void) testStoresValues {
    __block BOOL blockCalled;
	ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:[NSNumber class]
                                                                            value:@5
                                                                    whenAvailable:^(ALCWhenAvailableBlockArgs){
                                                                        blockCalled = YES;
                                                                    }];
	XCTAssertEqualObjects(@5, [source.values anyObject]);
    XCTAssertFalse(blockCalled);
}

-(void) testResolves {
    __block BOOL blockCalled;
    ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:[NSNumber class]
                                                                            value:@5
                                                                    whenAvailable:^(ALCWhenAvailableBlockArgs){
                                                                        blockCalled = YES;
                                                                    }];
	[source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertTrue(blockCalled);
}

@end
