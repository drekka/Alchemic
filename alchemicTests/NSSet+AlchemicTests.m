//
//  NSSet+AlchemicTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface NSSet_AlchemicTests : XCTestCase

@end

@implementation NSSet_AlchemicTests

-(void) testUnionSetTwoSets {
    NSMutableSet<NSString *> *set1 = [NSMutableSet setWithObject:@"abc"];
    NSMutableSet<NSString *> *set2 = [NSMutableSet setWithObject:@"def"];
    [NSSet unionSet:set2 intoMutableSet:&set1];
    XCTAssertEqual(2u, set1.count);
    XCTAssertTrue([set1 containsObject:@"abc"]);
    XCTAssertTrue([set1 containsObject:@"def"]);
}

-(void) testUnionSetOnlyRightSet {
    NSMutableSet<NSString *> *set1 = nil;
    NSMutableSet<NSString *> *set2 = [NSMutableSet setWithObject:@"def"];
    [NSSet unionSet:set2 intoMutableSet:&set1];
    XCTAssertEqual(1u, set1.count);
    XCTAssertTrue([set1 containsObject:@"def"]);
}

-(void) testUnionSetOnlyLeftSet {
    NSMutableSet<NSString *> *set1 = [NSMutableSet setWithObject:@"abc"];
    NSMutableSet<NSString *> *set2 = nil;
    [NSSet unionSet:set2 intoMutableSet:&set1];
    XCTAssertEqual(1u, set1.count);
    XCTAssertTrue([set1 containsObject:@"abc"]);
}

-(void) testUnionSetAllNils {
    NSMutableSet<NSString *> *set1 = nil;
    NSMutableSet<NSString *> *set2 = nil;
    [NSSet unionSet:set2 intoMutableSet:&set1];
    XCTAssertNil(set1);
}



@end
