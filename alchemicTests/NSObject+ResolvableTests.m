//
//  NSObject+ResolvableTests.m
//  alchemic
//
//  Created by Derek Clarkson on 26/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCResolvable.h"
#import "NSObject+ALCResolvable.h"

@interface DummyResolvable : NSObject<ALCResolvable>
@property (nonatomic, assign) BOOL available;
@end

@implementation DummyResolvable
@synthesize available = _available;
-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {}
@end

@interface NSObject_ResolvableTests : XCTestCase
@end

@implementation NSObject_ResolvableTests {
    BOOL _kvoCalled;
}

-(void) setUp {
    _kvoCalled = NO;
}

-(void) testWatchingFieldInArray {

    DummyResolvable *resolvable = [[DummyResolvable alloc] init];

    [self kvoWatchAvailableInResolvableArray:@[resolvable]];

    resolvable.available = YES;
    XCTAssertTrue(_kvoCalled);

    _kvoCalled = NO;
    [self kvoRemoveWatchAvailableFromResolvableArray:@[resolvable]];
    resolvable.available = NO;
    XCTAssertFalse(_kvoCalled);
}

-(void) testWatchingFieldInSet {

    DummyResolvable *resolvable = [[DummyResolvable alloc] init];

    [self kvoWatchAvailableInResolvableSet:[NSSet setWithObject:resolvable]];

    resolvable.available = YES;
    XCTAssertTrue(_kvoCalled);

    _kvoCalled = NO;
    [self kvoRemoveWatchAvailableFromResolvableSet:[NSSet setWithObject:resolvable]];
    resolvable.available = NO;
    XCTAssertFalse(_kvoCalled);
}

-(void) testWatchingField {

    DummyResolvable *resolvable = [[DummyResolvable alloc] init];

    [self kvoWatchAvailable:resolvable];

    resolvable.available = YES;
    XCTAssertTrue(_kvoCalled);

    _kvoCalled = NO;
    [self kvoRemoveWatchAvailable:resolvable];
    resolvable.available = NO;
    XCTAssertFalse(_kvoCalled);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    _kvoCalled = YES;
}

@end
