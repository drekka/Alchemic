//
//  ALCClassStorageTests.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCBuilderStorageSingleton.h"

@interface ALCBuilderStorageSingletonTests : XCTestCase
@end

@implementation ALCBuilderStorageSingletonTests

-(void) testNoValue {
    ALCBuilderStorageSingleton *storage = [[ALCBuilderStorageSingleton alloc] init];
    XCTAssertFalse(storage.hasValue);
}

-(void) testStoresValues {
    ALCBuilderStorageSingleton *storage = [[ALCBuilderStorageSingleton alloc] init];
    storage.value = @"abc";
    XCTAssertEqualObjects(@"abc", storage.value);
    XCTAssertTrue(storage.hasValue);
}

@end
