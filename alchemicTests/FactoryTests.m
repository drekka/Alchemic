//
//  FactoryTests.m
//  alchemic
//
//  Created by Derek Clarkson on 14/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Alchemic.h"
#import "Component.h"

@interface FactoryTests : XCTestCase

@end

@implementation FactoryTests {
    NSString *string1;
    NSString *string2;
}

inject(intoVariable(string1), withName(@"buildADateString"))
inject(intoVariable(string2), withName(@"buildADateString"))

- (void)setUp {
    injectDependencies(self);
}

- (void)testSimpleFactoryMethod {
    XCTAssertTrue([string1 hasPrefix:@"Factory string"]);
    XCTAssertTrue([string2 hasPrefix:@"Factory string"]);
    XCTAssertNotEqualObjects(string1, string2);
}

@end
