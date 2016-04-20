//
//  AlchemicTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Alchemic/Alchemic.h>

#import "SingletonA.h"
#import "SingletonB.h"

@interface AlchemicTests : XCTestCase

@end

@implementation AlchemicTests

-(void) testStartUp {

    SingletonA *a = AcGet(SingletonA);
    XCTAssertNotNil(a);

    SingletonB *b = AcGet(SingletonB);
    XCTAssertNotNil(b);

    XCTAssertEqual(a.singletonB, b);
    XCTAssertEqual(b.singletonA, a);
}

@end
