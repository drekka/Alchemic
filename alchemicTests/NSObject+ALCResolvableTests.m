//
//  NSObject+ALCResolvableTests.m
//  alchemic
//
//  Created by Derek Clarkson on 20/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCResolvable.h"
#import "ALCClassBuilder.h"
#import "NSObject+ALCResolvable.h"

@interface NSObject_ALCResolvableTests : XCTestCase

@end

@implementation NSObject_ALCResolvableTests {
    BOOL _kvoCalled;
}

-(void) setUp {
    _kvoCalled = NO;
}

-(void) testKVO {
    ALCClassBuilder *classBuilder = [[ALCClassBuilder alloc] initWithValueClass:[NSString class]];
    [self kvoWatchAvailable:classBuilder];
    classBuilder.value = @"abc";
    [self kvoRemoveWatchAvailable:classBuilder];
    XCTAssertTrue(_kvoCalled);
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    _kvoCalled = YES;
}

@end
