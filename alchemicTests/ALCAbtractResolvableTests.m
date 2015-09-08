//
//  ALCAbtractResolvableTests.m
//  alchemic
//
//  Created by Derek Clarkson on 3/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;
#import "ALCAbstractResolvable.h"
#import <OCMock/OCMock.h>

@interface ALCAbtractResolvableTests : XCTestCase
@end

@implementation ALCAbtractResolvableTests {
    ALCAbstractResolvable *_resolvableA;
    ALCAbstractResolvable *_resolvableB;
    ALCAbstractResolvable *_resolvableC;
    id _partialMockResolvableA;
    id _partialMockResolvableB;
    id _partialMockResolvableC;
}

-(void)setUp {
    _resolvableA = [[ALCAbstractResolvable alloc] init];
    _resolvableB = [[ALCAbstractResolvable alloc] init];
    _resolvableC = [[ALCAbstractResolvable alloc] init];
    _partialMockResolvableA = OCMPartialMock(_resolvableA);
    _partialMockResolvableB = OCMPartialMock(_resolvableB);
    _partialMockResolvableC = OCMPartialMock(_resolvableC);
}

#pragma mark - Dependencies

-(void) testAddDependencyWhenAlreadyResolved {
    [_resolvableA resolve];
    XCTAssertThrowsSpecificNamed([_resolvableA addDependency:_resolvableB], NSException, @"AlchemicResolved");
}

#pragma mark - Availability

-(void) testAvailableBeforeResolving {
    XCTAssertFalse(_resolvableA.available);
}

-(void) testAvailableAfterResolving {
    [_resolvableA resolve];
    XCTAssertTrue(_resolvableA.available);
}

-(void) testAvailableAfterResolvingPendingDependency {

    __block BOOL available = NO;
    [self setFlag:&available whenAvailable:_resolvableA];
    OCMStub([_partialMockResolvableB available]).andReturn(NO);
    [self addUnavailableDependencyTo:_resolvableB];

    [_resolvableA addDependency:_resolvableB];
    [_resolvableA resolve];

    XCTAssertFalse(available);
    XCTAssertFalse(_resolvableA.available);
}

-(void) testAvailableWhenImmediatelyAvailable {

    __block BOOL available = NO;
    [self setFlag:&available whenAvailable:_resolvableA];

    [_resolvableA addDependency:_resolvableB];
    [_resolvableA resolve];

    XCTAssertTrue(available);
    XCTAssertTrue(_resolvableA.available);
}

-(void) testAvailableWhenDependencyComesOnline {

    // Capture the when available block we need to trigger availability.
    __block ALCResolvableAvailableBlock bAvailable = NULL;
    OCMStub([(id<ALCResolvable>)_partialMockResolvableB executeWhenAvailable:[OCMArg checkWithBlock:^BOOL(id arg){
        bAvailable = arg;
        return YES;
    }]]).andForwardToRealObject;

    __block BOOL available = NO;
    [self setFlag:&available whenAvailable:_resolvableA];

    [_resolvableA addDependency:_resolvableB];
    [self addUnavailableDependencyTo:_resolvableB];

    [_resolvableA resolve];

    XCTAssertFalse(available);
    XCTAssertFalse(_resolvableA.available);

    // Simulate the dependency coming online.
    [self removeDependenciesFrom:_resolvableB];
    [_resolvableB checkIfAvailable];

    XCTAssertTrue(available);
    XCTAssertTrue(_resolvableA.available);

}

-(void) testCheckAvailableWhenNotResolvedThrows {
    XCTAssertThrowsSpecificNamed([_resolvableA checkIfAvailable], NSException, @"AlchemicNotResolved");
}

#pragma mark - Circular dependencies and availability

-(void) testCheckAvailabilityAB {

    //OCMStub([_partialMockResolvableB available]).andReturn(YES);
    [_resolvableA addDependency:_resolvableB];
    [_resolvableB addDependency:_resolvableA];

    [_resolvableA resolve];

    XCTAssertTrue(_resolvableA.available);
}

-(void) testCheckAvailabilityABWhenBNotReady {

    OCMStub([_partialMockResolvableB available]).andReturn(NO);
    [self addUnavailableDependencyTo:_resolvableB];
    [_resolvableA addDependency:_resolvableB];
    [_resolvableA resolve];

    [_resolvableA checkIfAvailable];

    XCTAssertFalse(_resolvableA.available);
}

-(void) testCheckAvailabilityABEnteredFromC {

    [_resolvableA addDependency:_resolvableB];
    [_resolvableA resolve];

    [_resolvableA checkIfAvailable];

    XCTAssertTrue(_resolvableA.available);
}


#pragma mark - Execute when available

-(void) testExecuteWhenAvailableCallsBlock {
    [_resolvableA resolve];
    __block BOOL called = NO;
    [_resolvableA executeWhenAvailable:^(id<ALCResolvable> resolvable) {
        called = YES;
    }];
    XCTAssertTrue(called);
}

-(void) testExecuteWhenAvailableWhenNotResolved {
    __block BOOL called = NO;
    [_resolvableA executeWhenAvailable:^(id<ALCResolvable> resolvable) {
        called = YES;
    }];
    XCTAssertFalse(called);
}

#pragma mark - Did become available

-(void) testDidBecomeAvailableCalled {

    __block BOOL didBecomeAvailable = NO;
    OCMStub([_partialMockResolvableA didBecomeAvailable]).andDo(^(NSInvocation *inv){
        didBecomeAvailable = YES;
    });

    [_resolvableA resolve];

    XCTAssertTrue(didBecomeAvailable);
}

#pragma mark - Resolving

-(void) testDetectsCircularDependency {

    [_resolvableA addDependency:_resolvableB];
    [_resolvableB addDependency:_resolvableA];

    OCMStub([_partialMockResolvableA available]).andReturn(YES);
    OCMStub([_partialMockResolvableB available]).andReturn(YES);

    XCTAssertThrowsSpecificNamed([_resolvableA resolveWithDependencyStack:[NSMutableArray arrayWithObject:_resolvableB]], NSException, @"AlchemicCircularDependency");
}

-(void) testResolveWithPostProcessorsAB {

    [_resolvableA addDependency:_resolvableB];
    [_resolvableB addDependency:_resolvableA];

    OCMStub([_partialMockResolvableA available]).andReturn(YES);
    OCMStub([_partialMockResolvableB available]).andReturn(YES);

    [_resolvableA resolve];

    // Use availility to check. We should not have entered an endless loop or crahed by here.
    XCTAssertTrue(_resolvableA.available);
    XCTAssertTrue(_resolvableB.available);

}

#pragma mark - Internal

-(void) setFlag:(BOOL *) boolVar whenAvailable:(id<ALCResolvable>) resolvable {
    [resolvable executeWhenAvailable:^(id<ALCResolvable> availableResolvable) {
        *boolVar = YES;
    }];
}

-(void) addUnavailableDependencyTo:(id<ALCResolvable>) resolvable {
    id mockDep = OCMClassMock([ALCAbstractResolvable class]);
    [resolvable addDependency:mockDep];
}

-(void) removeDependenciesFrom:(id<ALCResolvable>) resolvable {
    Ivar dependencyVar = class_getInstanceVariable([ALCAbstractResolvable class], "_dependenciesNotAvailable");
    object_setIvar(resolvable, dependencyVar, [NSSet set]);
}

@end
