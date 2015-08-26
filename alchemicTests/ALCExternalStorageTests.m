//
//  ALCExternalStorageTests.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCExternalStorage.h"

@interface ALCExternalStorageTests : XCTestCase

@end

@implementation ALCExternalStorageTests

-(void) testNoValue {
    ALCExternalStorage *storage = [[ALCExternalStorage alloc] init];
    XCTAssertThrowsSpecificNamed([storage value], NSException, @"AlchemicCannotCreateValue");
    XCTAssertFalse(storage.hasValue);
    XCTAssertFalse(storage.available);
}

-(void) testStoresValues {
    ALCExternalStorage *storage = [[ALCExternalStorage alloc] init];
    storage.value = @"abc";
    XCTAssertEqualObjects(@"abc", storage.value);
    XCTAssertTrue(storage.hasValue);
    XCTAssertTrue(storage.available);
}

@end
