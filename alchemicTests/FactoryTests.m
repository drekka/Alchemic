//
//  FactoryTests.m
//  alchemic
//
//  Created by Derek Clarkson on 14/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Alchemic.h"

@interface FactoryTests : XCTestCase

@end

@implementation FactoryTests {
    NSString *string1;
    NSString *string2;
}

inject(intoVariable(string1), withName(@"def"))
inject(intoVariable(string2), withName(@"def"))

- (void)setUp {
    injectDependencies(self);
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssertEqualObjects(string1, @"String 1");
}

@end
