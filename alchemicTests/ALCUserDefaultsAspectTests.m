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

@interface ALCUserDefaultsAspectTests : XCTestCase
@end

@implementation ALCUserDefaultsAspectTests {
    ALCUserDefaultsAspect *_aspect;
}

-(void)setUp {
    _aspect = [[ALCUserDefaultsAspect alloc] init];
}

-(void) testEnabled {
    XCTAssertFalse([ALCUserDefaultsAspect enabled]);
    [ALCUserDefaultsAspect setEnabled:YES];
    XCTAssertTrue([ALCUserDefaultsAspect enabled]);
}

-(void) testModelWillResolveWhenNoFactories {

    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    OCMStub([mockModel objectFactories]).andReturn(@[]);
    
    OCMExpect([mockModel addObjectFactory:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isKindOfClass:[ALCClassObjectFactory class]]
        && ((ALCClassObjectFactory *)obj).objectClass == [ALCUserDefaults class];
    }] withName:@"userDefaults"]);
    
    [_aspect modelWillResolve:mockModel];
    
    OCMVerifyAll(mockModel);
}

-(void) testModelWillResolveWhenNoCustomDefaults {
    
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([mockModel objectFactories]).andReturn(@[mockFactory]);
    OCMStub([mockFactory objectClass]).andReturn([NSObject class]);
    
    OCMExpect([mockModel addObjectFactory:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isKindOfClass:[ALCClassObjectFactory class]]
        && ((ALCClassObjectFactory *)obj).objectClass == [ALCUserDefaults class];
    }] withName:@"userDefaults"]);
    
    [_aspect modelWillResolve:mockModel];
    
    OCMVerifyAll(mockModel);
}

-(void) testModelWillResolveWhenCustomDefaults {
    
    Class customDefaults = objc_allocateClassPair([ALCUserDefaults class], "CustomDefaults", 0);
    objc_registerClassPair(customDefaults);
    
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([mockModel objectFactories]).andReturn(@[mockFactory]);
    OCMStub([mockFactory objectClass]).andReturn(customDefaults);
    
    [_aspect modelWillResolve:mockModel];
    
    OCMVerifyAll(mockModel);
}



@end