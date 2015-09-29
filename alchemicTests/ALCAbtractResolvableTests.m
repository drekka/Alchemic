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

#pragma mark - When ready to inject

-(void) testWhenReadyToInject {
    ALCAbstractResolvable *resolvable = [[ALCAbstractResolvable alloc] init];
    __block BOOL readyToInject = NO;
    [resolvable whenReadyDo:^(id<ALCResolvable> resolvableComingOnline) {
        readyToInject = YES;
    }];

    [resolvable resolve];
    [resolvable checkStatus];

    XCTAssertTrue(readyToInject);

}

#pragma mark - Dependencies

-(void) testAddDependencyThrowsWhenAlreadyResolved {
    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    [resolvable resolve];
    XCTAssertThrowsSpecificNamed([resolvable addDependency:[[ALCAbstractResolvable alloc] init]], NSException, @"AlchemicResolved");
}

#pragma mark - Can instantiate

-(void) testCanInjectIsFalseBeforeResolving {
    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    XCTAssertFalse(resolvable.ready);
}

-(void) testCanInjectIsTrueAfterResolving {
    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    [resolvable resolve];
    XCTAssertTrue(resolvable.ready);
}

-(void) testCanInjectIsFalseWhenDependencyCannotInject {

    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    id mockDependency = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockDependency ready]).andReturn(NO);

    [resolvable addDependency:mockDependency];
    [resolvable resolve];

    XCTAssertFalse(resolvable.ready);
}

-(void) testCanInjectIsTrueWhenImmediatelyAvailable {

    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    id mockDependency = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockDependency ready]).andReturn(YES);

    [resolvable addDependency:mockDependency];
    [resolvable resolve];

    XCTAssertFalse(resolvable.ready);
}

-(void) testCanInjectWhenDependencyComesOnline {

    id<ALCResolvable> resolvable = [[ALCAbstractResolvable alloc] init];
    id mockDependency = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockDependency ready]).andReturn(NO);

    // Capture the when available block passed to the dependency.
    __block ALCDependencyReadyBlock whenAvailableCallbackBlock = NULL;
    OCMStub([mockDependency whenReadyDo:[OCMArg checkWithBlock:^BOOL(id arg){
        whenAvailableCallbackBlock = arg;
        return YES;
    }]]);

    // Start tests
    [resolvable addDependency:mockDependency];
    [resolvable resolve];

    XCTAssertFalse(resolvable.ready);

    // Simulate the dependency coming online.
    OCMStub([mockDependency ready]).andReturn(YES);
    OCMStub([mockDependency checkStatus]).andReturn(YES);
    whenAvailableCallbackBlock(mockDependency);

    XCTAssertTrue(resolvable.ready);

}

-(void) testCanInjectWhenTwoResolvableWithCommonDependencyComesOnline {

    id<ALCResolvable> resolvableA = [[ALCAbstractResolvable alloc] init];
    id<ALCResolvable> resolvableB = [[ALCAbstractResolvable alloc] init];
    id mockDependency = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockDependency ready]).andReturn(NO);

    // Capture the when available block passed to the dependency.
    NSMutableSet<ALCDependencyReadyBlock> *blocks = [NSMutableSet set];
    OCMStub([mockDependency whenReadyDo:[OCMArg checkWithBlock:^BOOL(id arg){
        [blocks addObject:arg];
        return YES;
    }]]);

    [resolvableA addDependency:mockDependency];
    [resolvableB addDependency:mockDependency];

    // Start tests
    [resolvableA resolve];
    [resolvableB resolve];

    XCTAssertFalse(resolvableA.ready);
    XCTAssertFalse(resolvableB.ready);

    // Simulate the dependency coming online.
    OCMStub([mockDependency ready]).andReturn(YES);
    OCMStub([mockDependency checkStatus]).andReturn(YES);
    for (ALCDependencyReadyBlock block in blocks) {
        block(mockDependency);
    }

    XCTAssertTrue(resolvableA.ready);
    XCTAssertTrue(resolvableB.ready);

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

    XCTAssertTrue(resolvableA.resolved);
    XCTAssertTrue(resolvableB.resolved);

}

#pragma mark - Instantiate 

-(void) testInstantiateCalledWhenCanInject {
    DummyResolvable *resolvableA = [[DummyResolvable alloc] init];
    [resolvableA resolve];
    XCTAssertTrue(resolvableA.instantiateCalled);
}

@end
