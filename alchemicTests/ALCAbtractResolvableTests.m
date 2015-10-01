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
#import "ALCResolvable.h"
#import <OCMock/OCMock.h>

@interface DummyResolvable : ALCAbstractResolvable
@property (nonatomic, assign) BOOL instantiateCalled;
@end

@implementation DummyResolvable
-(void) instantiate {
    self.instantiateCalled = YES;
}
@end

@interface ALCAbstractResolvable (_internal)
-(BOOL) checkStatus;
-(void) resolveWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack;
@end

@interface ALCAbtractResolvableTests : XCTestCase
@end

@implementation ALCAbtractResolvableTests

#pragma mark - Dependencies

-(void) testAddDependencyThrowsWhenAlreadyResolved {
    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    [resolvable resolve];
    XCTAssertThrowsSpecificNamed([resolvable addDependency:[[ALCAbstractResolvable alloc] init]], NSException, @"AlchemicResolved");
}

#pragma mark - Ready

-(void) testReadyIsFalseBeforeResolving {
    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    XCTAssertFalse(resolvable.ready);
}

-(void) testReadyIsTrueAfterResolving {
    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    [resolvable resolve];
    XCTAssertTrue(resolvable.ready);
}

-(void) testReadyIsFalseWhenDependencyCannotInject {

    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    id mockDependency = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockDependency ready]).andReturn(NO);

    [resolvable addDependency:mockDependency];
    [resolvable resolve];

    XCTAssertFalse(resolvable.ready);
}

-(void) testReadyIsTrueWhenImmediatelyAvailable {

    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    id mockDependency = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockDependency ready]).andReturn(YES);

    [resolvable addDependency:mockDependency];
    [resolvable resolve];

    XCTAssertTrue(resolvable.ready);
}

#pragma mark - Resolving

-(void) testResolveThrowsWhenABLoop {

    id<ALCResolvable> resolvableA = [[ALCAbstractResolvable alloc] init];
    id<ALCResolvable> resolvableB = [[ALCAbstractResolvable alloc] init];

    [resolvableA addDependency:resolvableB];
    [resolvableB addDependency:resolvableA];

    XCTAssertThrowsSpecificNamed([resolvableA resolve], NSException, @"AlchemicCircularDependency");
}

-(void) testResolveWhenABAndBStartsANewStack {

    id<ALCResolvable> resolvableA = [[ALCAbstractResolvable alloc] init];
    id<ALCResolvable> resolvableB = [[ALCAbstractResolvable alloc] init];
    resolvableB.startsResolvingStack = YES;

    [resolvableA addDependency:resolvableB];
    [resolvableB addDependency:resolvableA];

    [resolvableA resolve];
}

#pragma mark - Instantiate 

-(void) testInstantiateCalledWhenReady {
    DummyResolvable *resolvableA = [[DummyResolvable alloc] init];
    [resolvableA resolve];
    XCTAssertTrue(resolvableA.instantiateCalled);
}

@end
