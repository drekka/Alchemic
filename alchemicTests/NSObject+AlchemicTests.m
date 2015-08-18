//
//  NSObject+AlchemicTests.m
//  alchemic
//
//  Created by Derek Clarkson on 18/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "NSObject+Alchemic.h"

@interface NSObject_AlchemicTests : XCTestCase

@end

@implementation NSObject_AlchemicTests {
}

-(void) testNoArgs {
    NSNumber *result = [self invokeSelector:@selector(noArgs) arguments:@[]];
    XCTAssertEqualObjects(@1, result);
}

-(void) testWithArgs {
    NSNumber *result = [self invokeSelector:@selector(withArgsA:b:c:) arguments:@[@1, @4, @8]];
    XCTAssertEqualObjects(@13, result);
}

-(void) testTwoFewArgs {
    NSNumber *result = [self invokeSelector:@selector(withArgsA:b:c:) arguments:@[@1, @4]];
    XCTAssertEqualObjects(@5, result);
}

-(void) testNilArgument {
    NSNumber *result = [self invokeSelector:@selector(withArgsA:b:c:) arguments:@[@1, [NSNull null], @8]];
    XCTAssertEqualObjects(@9, result);
}

#pragma mark - Internal

-(NSNumber *) noArgs {
    return @1;
}

-(NSNumber *) withArgsA:(NSNumber *) a b:(NSNumber *) b c:(NSNumber *) c {
    return @([a intValue] + [b intValue] + [c intValue]);
}

@end
