//
//  NSSet+AlchemicTests.m
//  alchemic
//
//  Created by Derek Clarkson on 14/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "NSSet+Alchemic.h"

@interface NSSet_AlchemicTests : XCTestCase

@end

@implementation NSSet_AlchemicTests

-(void) testComponentsJoinedByString {
    NSSet *set = [NSSet setWithObjects:@"abc", @12, @"def", nil];
    XCTAssertEqualObjects(@"abc,12,def", [set componentsJoinedByString:@","]);
}

-(void) testComponentsJoinedByStringTemplate {
    NSSet *set = [NSSet setWithObjects:@"abc", @12, @"def", nil];
    XCTAssertEqualObjects(@"<abc>,<12>,<def>", [set componentsJoinedByString:@"," withTemplate:@"<%@>"]);
}

@end
