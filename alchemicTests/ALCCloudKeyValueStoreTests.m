//
//  ALCCloudKeyValueStoreTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 2/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface ALCCloudKeyValueStoreTests : XCTestCase
@end

@implementation ALCCloudKeyValueStoreTests {
    id _mockCloudStore;
    ALCCloudKeyValueStore *_store;
}

-(void) setUp {
    // Mock out the cloud.
    _mockCloudStore = OCMClassMock([NSUbiquitousKeyValueStore class]);
    OCMStub(ClassMethod([_mockCloudStore defaultStore])).andReturn(_mockCloudStore);
    _store = [[ALCCloudKeyValueStore alloc] init];
}

-(void) tearDown {
    [_mockCloudStore stopMocking];
    _store = nil; // Ensures dealloc is called.
}

-(void) testLoadDefaults {
    OCMStub([(NSUbiquitousKeyValueStore *)_mockCloudStore dictionaryRepresentation]).andReturn(@{@"abc":@"def"});
    NSDictionary *defaults = _store.backingStoreDefaults;
    XCTAssertEqualObjects(@"def", defaults[@"abc"]);
}

-(void) testCloudUpdateUpdatesLocalStore {
    
    OCMStub([(NSUbiquitousKeyValueStore *)_mockCloudStore dictionaryRepresentation]).andReturn(@{@"abc":@"def"});
    __unused id _ = _store.backingStoreDefaults;
    
    [self expectationForNotification:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil handler:nil];
    
    NSDictionary *userInfo = @{
                               NSUbiquitousKeyValueStoreChangeReasonKey:@(NSUbiquitousKeyValueStoreServerChange),
                               NSUbiquitousKeyValueStoreChangedKeysKey:@[@"abc"]
                                   };
    [[NSNotificationCenter defaultCenter] postNotificationName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil userInfo:userInfo];
    
    [self waitForExpectationsWithTimeout:0.5 handler:nil];

    // Nothing to really check here.
}

-(void) testValueStoreValueForKey {
    OCMStub([(NSUbiquitousKeyValueStore *)_mockCloudStore objectForKey:@"abc"]).andReturn(@"xyz");
    XCTAssertEqualObjects(@"xyz", _store[@"abc"]);
}

-(void) testValueStoreSetValueForKey {
    OCMExpect([(NSUbiquitousKeyValueStore *)_mockCloudStore setObject:@"xyz" forKey:@"abc"]);
    _store[@"abc"] = @"xyz";
    OCMVerifyAll(_mockCloudStore);
}

@end
