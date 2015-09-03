//
//  ALCAbtractResolvableTests.m
//  alchemic
//
//  Created by Derek Clarkson on 3/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCAbstractResolvable.h"
#import <OCMock/OCMock.h>

@interface ALCAbtractResolvableTests : XCTestCase
@end

@implementation ALCAbtractResolvableTests {
    ALCAbstractResolvable *_resolvable;
}

-(void)setUp {
    _resolvable = [[ALCAbstractResolvable alloc] init];
}

-(void) testWatchResolvableWhenOtherResolvableAvailable {

    __block BOOL callbackExecuted = NO;
    [_resolvable executeWhenAvailable:^(id<ALCResolvable> resolvable) {
        callbackExecuted = YES;
    }];

    id mockOtherResolvable = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockOtherResolvable available]).andReturn(YES);

    [_resolvable watchResolvable:mockOtherResolvable];
    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertTrue(_resolvable.available);
    XCTAssertTrue(callbackExecuted);
}

-(void) testWatchResolvableWhenOtherResolvableNotAvailable {

    [_resolvable executeWhenAvailable:^(id<ALCResolvable> resolvable) {
        XCTFail(@"Callback should not be executed");
    }];

    id mockOtherResolvable = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockOtherResolvable available]).andReturn(NO);

    [_resolvable watchResolvable:mockOtherResolvable];
    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertFalse(_resolvable.available);
}

-(void) testWatchResolvableBlockIsCalledWhenBecomesAvailable {

    __block BOOL callbackExecuted = NO;
    [_resolvable executeWhenAvailable:^(ALCResolvableAvailableBlockArgs) {
        callbackExecuted = YES;
    }];

    id mockOtherResolvable = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockOtherResolvable available]).andReturn(NO);
    __block ALCResolvableAvailableBlock availableBlock = NULL;
    OCMStub([mockOtherResolvable executeWhenAvailable:[OCMArg checkWithBlock:^BOOL(id obj) {
        availableBlock = obj;
        return YES;
    }]
             ]);

    [_resolvable watchResolvable:mockOtherResolvable];
    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertFalse(_resolvable.available);
    XCTAssertFalse(callbackExecuted);

    // Simulate the dependency coming online.
    availableBlock(mockOtherResolvable);

    XCTAssertTrue(_resolvable.available);
    XCTAssertTrue(callbackExecuted);

}

-(void) testExecuteWhenAvailable {
    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    __block BOOL executed = NO;
    [_resolvable executeWhenAvailable:^(id<ALCResolvable> resolvable) {
        executed = YES;
    }];
    XCTAssertTrue(executed);
}

-(void) testExecuteWhenAvailableWhenNotResolved {
    [_resolvable executeWhenAvailable:^(id<ALCResolvable> resolvable) {
        XCTFail(@"Block should not be called");
    }];
}

-(void) testAvailableBeforeResolving {
    XCTAssertFalse(_resolvable.available);
}

-(void) testAvailableAfterResolving {
    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertTrue(_resolvable.available);
}

-(void) testAvailableAfterResolvingPendingDependency {
    id mockOtherResolvable = OCMClassMock([ALCAbstractResolvable class]);
    OCMStub([mockOtherResolvable available]).andReturn(NO);
    [_resolvable watchResolvable:mockOtherResolvable];
    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertFalse(_resolvable.available);
}

-(void) testDidBecomeAvailableCalled {

    id partialResolvable = OCMPartialMock(_resolvable);
    __block BOOL didBecomeAvailable = NO;
    OCMStub([partialResolvable didBecomeAvailable]).andDo(^(NSInvocation *inv){
        didBecomeAvailable = YES;
    });

    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertTrue(didBecomeAvailable);
}

-(void) testResolveCallsResolveDependencies {

    id partialResolvable = OCMPartialMock(_resolvable);
    __block BOOL resolveDependencies = NO;
    OCMStub([partialResolvable resolveDependenciesWithPostProcessors:OCMOCK_ANY dependencyStack:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
        resolveDependencies = YES;
    });

    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertTrue(resolveDependencies);

}

-(void) testResolveThrowsWhenCircularDependencies {

    ALCAbstractResolvable *resolvable2 = [[ALCAbstractResolvable alloc] init];

    [_resolvable watchResolvable:resolvable2];
    [resolvable2 watchResolvable:_resolvable];

    // Stub call to resolve 2.
    id partialResolvable = OCMPartialMock(_resolvable);
    OCMStub([partialResolvable resolveDependenciesWithPostProcessors:OCMOCK_ANY dependencyStack:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
        __unsafe_unretained NSSet *postProcessors;
        __unsafe_unretained NSMutableArray *stack;
        [inv getArgument:&postProcessors atIndex:2];
        [inv getArgument:&stack atIndex:3];
        [resolvable2 resolveWithPostProcessors:postProcessors dependencyStack:stack];
    });
    OCMStub([partialResolvable available]).andReturn(YES);

    // Stub call to resolve back.
    id partialResolvable2 = OCMPartialMock(resolvable2);
    OCMStub([partialResolvable2 resolveDependenciesWithPostProcessors:OCMOCK_ANY dependencyStack:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
        __unsafe_unretained NSSet *postProcessors;
        __unsafe_unretained NSMutableArray *stack;
        [inv getArgument:&postProcessors atIndex:2];
        [inv getArgument:&stack atIndex:3];
        [self->_resolvable resolveWithPostProcessors:postProcessors dependencyStack:stack];
    });
    OCMStub([partialResolvable2 available]).andReturn(YES);

    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    
    XCTAssertTrue(_resolvable.available);
    XCTAssertTrue(resolvable2.available);
    
}

-(void) testDependenciesComingOnline {

    ALCAbstractResolvable *resolvable2 = [[ALCAbstractResolvable alloc] init];

    // Stub call to resolve 2.
    id partialResolvable = OCMPartialMock(_resolvable);
    OCMStub([partialResolvable resolveDependenciesWithPostProcessors:OCMOCK_ANY dependencyStack:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
        __unsafe_unretained NSSet *postProcessors;
        __unsafe_unretained NSMutableArray *stack;
        [inv getArgument:&postProcessors atIndex:2];
        [inv getArgument:&stack atIndex:3];
        [resolvable2 resolveWithPostProcessors:postProcessors dependencyStack:stack];
    });

    // Stub call to resolve back.
    id partialResolvable2 = OCMPartialMock(resolvable2);
    OCMStub([partialResolvable2 resolveDependenciesWithPostProcessors:OCMOCK_ANY dependencyStack:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
        __unsafe_unretained NSSet *postProcessors;
        __unsafe_unretained NSMutableArray *stack;
        [inv getArgument:&postProcessors atIndex:2];
        [inv getArgument:&stack atIndex:3];
        [self->_resolvable resolveWithPostProcessors:postProcessors dependencyStack:stack];
    });

    // Capture the block being set on the second resolvable so we can call it to simulate a value being set.
    __block ALCResolvableAvailableBlock availableBlock = NULL;
    OCMStub([partialResolvable2 executeWhenAvailable:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
        __unsafe_unretained ALCResolvableAvailableBlock whenAvailableBlock = NULL;
        [inv getArgument:&whenAvailableBlock atIndex:2];
        availableBlock = whenAvailableBlock;

    }).andForwardToRealObject;

    [_resolvable watchResolvable:resolvable2];
    [resolvable2 watchResolvable:_resolvable];

    [_resolvable resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];

    XCTAssertFalse(_resolvable.available);
    XCTAssertFalse(resolvable2.available);

    // Bring the 2nd resolvable online.
    OCMStub([partialResolvable2 available]).andReturn(YES);
    availableBlock(resolvable2);

    XCTAssertTrue(_resolvable.available);
    XCTAssertTrue(resolvable2.available);

}


@end
