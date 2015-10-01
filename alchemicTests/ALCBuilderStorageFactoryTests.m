//
//  ALCFactoryStorageTests.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCBuilderStorageFactory.h"

@interface ALCBuilderStorageFactoryTests : XCTestCase

@end

@implementation ALCBuilderStorageFactoryTests

-(void) testNoValue {
    ALCBuilderStorageFactory *storage = [[ALCBuilderStorageFactory alloc] init];
    XCTAssertNil(storage.value);
    XCTAssertFalse(storage.hasValue);
}

-(void) testStoresValues {
    ALCBuilderStorageFactory *storage = [[ALCBuilderStorageFactory alloc] init];
    storage.value = @"abc";
    XCTAssertFalse(storage.hasValue);
}

@end
