//
//  ALCUserDefaultsAspectTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface ALCCloudkeyValueStoreAspectTests : XCTestCase
@end

@implementation ALCCloudkeyValueStoreAspectTests {
    ALCCloudKeyValueStoreAspect *_aspect;
}

-(void)setUp {
    _aspect = [[ALCCloudKeyValueStoreAspect alloc] init];
}

-(void) testEnabled {
    XCTAssertFalse(ALCCloudKeyValueStoreAspect.enabled);
    ALCCloudKeyValueStoreAspect.enabled = YES;
    XCTAssertTrue(ALCCloudKeyValueStoreAspect.enabled);
}

-(void) testModelWillResolveWhenNoFactories {
    
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    OCMStub([mockModel objectFactories]).andReturn(@[]);
    
    OCMExpect([mockModel addObjectFactory:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isKindOfClass:[ALCClassObjectFactory class]]
        && ((ALCClassObjectFactory *)obj).type.objcClass == [ALCCloudKeyValueStore class];
    }] withName:@"cloudKeyValueStore"]);
    
    [_aspect modelWillResolve:mockModel];
    
    OCMVerifyAll(mockModel);
}

-(void) testModelWillResolveWhenNoCustomExtension {
    
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([mockModel objectFactories]).andReturn(@[mockFactory]);
    ALCType *type = [ALCType typeWithClass:[NSObject class]];
    OCMStub([(id<ALCObjectFactory>) mockFactory type]).andReturn(type);
    
    OCMExpect([mockModel addObjectFactory:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isKindOfClass:[ALCClassObjectFactory class]]
        && ((ALCClassObjectFactory *)obj).type.objcClass == [ALCCloudKeyValueStore class];
    }] withName:@"cloudKeyValueStore"]);
    
    [_aspect modelWillResolve:mockModel];
    
    OCMVerifyAll(mockModel);
}

-(void) testModelWillResolveWhenCustomDefaults {
    
    Class customCloudKeyValueStore = objc_allocateClassPair([ALCCloudKeyValueStore class], "CustomCloudKeyValueStore", 0);
    objc_registerClassPair(customCloudKeyValueStore);
    
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([mockModel objectFactories]).andReturn(@[mockFactory]);
    ALCType *type = [ALCType typeWithClass:customCloudKeyValueStore];
    OCMStub([(id<ALCObjectFactory>) mockFactory type]).andReturn(type);
    
    [_aspect modelWillResolve:mockModel];
    
    OCMVerifyAll(mockModel);
}



@end
