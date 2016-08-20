//
//  ALCAbstractConstantInjectorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 21/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;
@import ObjectiveC;

@interface ALCAbstractConstantInjectorTests : XCTestCase

@end

@implementation ALCAbstractConstantInjectorTests {
    ALCAbstractConstantInjector *_injector;
}

-(void) setUp {
    _injector = [[ALCAbstractConstantInjector alloc] init];
}


-(void) testReady {
    XCTAssertTrue(_injector.isReady);
}

-(void) testObjectClass {
    XCTAssertEqual([ALCAbstractConstantInjector class], _injector.objectClass);
}

-(void) testResolveWithStackModel {
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_injector resolveWithStack:[[NSMutableArray alloc] init] model:mockModel];
    // Nothing to check.
}

-(void) testResolvingdescription {
    XCTAssertThrows([_injector resolvingDescription]);
}

-(void) testReferencesObjectFactory {
    id mockFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    XCTAssertFalse([_injector referencesObjectFactory:mockFactory]);
}

-(void) testSetObjectVariableError {
    id mockObj = OCMClassMock([NSObject class]);
    NSError *error;
    Ivar ivar = class_getInstanceVariable([self class], "_injector");
    XCTAssertThrows([_injector setObject:mockObj variable:ivar error:&error]);
}

-(void) testSetInvocationArgumentIndexError {
    id mockInv = OCMClassMock([NSInvocation class]);
    NSError *error;
    XCTAssertThrows([_injector setInvocation:mockInv argumentIndex:0    error:&error]);
}


@end
