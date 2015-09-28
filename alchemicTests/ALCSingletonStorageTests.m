//
//  ALCClassStorageTests.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCSingletonStorage.h"

@interface ALCSingletonStorageTests : XCTestCase
@end

@implementation ALCSingletonStorageTests

-(void) testNoValue {
    ALCSingletonStorage *storage = [[ALCSingletonStorage alloc] init];
    XCTAssertFalse(storage.hasValue);
}

-(void) testStoresValues {
    ALCSingletonStorage *storage = [[ALCSingletonStorage alloc] init];
    storage.value = @"abc";
    XCTAssertEqualObjects(@"abc", storage.value);
    XCTAssertTrue(storage.hasValue);
}

@end
