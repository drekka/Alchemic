//
//  ALCConstantValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCConstantValueSource.h"
#import "NSObject+ALCResolvable.h"

@interface ALCConstantValueSourceTests : XCTestCase

@end

@implementation ALCConstantValueSourceTests {
    BOOL _kvoCalled;
}

-(void)setUp {
    _kvoCalled = NO;
}

-(void) testStoresValues {
	ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:[NSNumber class] value:@5];
	XCTAssertEqualObjects(@5, [source.values anyObject]);
}

-(void) testResolves {
    ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:[NSNumber class] value:@5];
	[source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    XCTAssertTrue(source.available);
}

-(void) testRsolveDoesNottriggerKVO {

    ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:[NSNumber class] value:@5];
    [self kvoWatchAvailable:source];

    [source resolveWithPostProcessors:[NSSet set] dependencyStack:[NSMutableArray array]];
    [self kvoRemoveWatchAvailable:source];

    XCTAssertFalse(_kvoCalled);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    _kvoCalled = YES;
}

@end
