//
//  ALCFactoryStorageTests.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCFactoryStorage.h"

@interface ALCFactoryStorageTests : XCTestCase

@end

@implementation ALCFactoryStorageTests

-(void) testNoValue {
    ALCFactoryStorage *storage = [[ALCFactoryStorage alloc] init];
    XCTAssertNil(storage.value);
    XCTAssertFalse(storage.hasValue);
}

-(void) testStoresValues {
    ALCFactoryStorage *storage = [[ALCFactoryStorage alloc] init];
    storage.value = @"abc";
    XCTAssertFalse(storage.hasValue);
}

@end
