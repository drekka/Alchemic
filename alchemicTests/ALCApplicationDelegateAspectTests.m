//
//  ALCApplicationDelegateAspectTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;
@import ObjectiveC;

@interface ALCApplicationDelegateAspectTests : XCTestCase

@end

@implementation ALCApplicationDelegateAspectTests {
    id<ALCResolveAspect> _aspect;
    Class _delegateClass;
    id _appMock;
}

-(void)setUp {
    
    _aspect = [[ALCApplicationDelegateAspect alloc] init];

    // Create a fake app delegate.
    _delegateClass = objc_allocateClassPair([NSObject class], "TestDelegate", 0);
    class_addProtocol(_delegateClass, @protocol(UIApplicationDelegate));
    objc_registerClassPair(_delegateClass);
    
    _appMock = OCMClassMock([UIApplication class]);

}

-(void)tearDown {
    objc_disposeClassPair(_delegateClass);
    [_appMock stopMocking];
}

-(void) testAlwaysEnabled {
    XCTAssertTrue([ALCApplicationDelegateAspect enabled]);
    [ALCApplicationDelegateAspect setEnabled:NO];
    XCTAssertTrue([ALCApplicationDelegateAspect enabled]);
}

-(void) testModelWillResolveWhenDelegateFound {

    // Mock out the model
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([mockModel classObjectFactories]).andReturn(@[mockFactory]);
    
    
    id delegate = [[_delegateClass alloc] init];

    // Mock out the shared application.
    OCMStub(ClassMethod([_appMock sharedApplication])).andReturn(_appMock);
    OCMStub([(UIApplication *)_appMock delegate]).andReturn(delegate);
    
    ALCType *type = [ALCType typeWithClass:_delegateClass];
    OCMStub([(id<ALCObjectFactory>)mockFactory type]).andReturn(type);
    
    OCMExpect([(id<ALCObjectFactory>) mockFactory setObject:delegate]);
    
    [_aspect modelWillResolve:mockModel];
    [_aspect modelDidResolve:mockModel];
    
    OCMVerifyAll(mockFactory);
}

-(void) testModelWillResolveWhenDelegateNotFound {
    
    // Mock out the model
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([mockModel classObjectFactories]).andReturn(@[mockFactory]);
    
    
    // Mock out the shared application.
    OCMStub(ClassMethod([_appMock sharedApplication])).andReturn(nil);
    
    ALCType *type = [ALCType typeWithClass:_delegateClass];
    OCMStub([(id<ALCObjectFactory>)mockFactory type]).andReturn(type);
    
    [_aspect modelWillResolve:mockModel];
    [_aspect modelDidResolve:mockModel];
    
    OCMVerifyAll(mockFactory);
}

@end
