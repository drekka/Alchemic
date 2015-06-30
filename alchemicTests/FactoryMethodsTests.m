//
//  FactoryTests.m
//  alchemic
//
//  Created by Derek Clarkson on 14/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>

#import "Component.h"
#import "ALCTestCase.h"

@interface FactoryMethodsTests : ALCTestCase
@end

@implementation FactoryMethodsTests {
    NSString *string1;
    NSString *string2;
    NSString *string3;
    NSString *string4;
}

ACInject(ACIntoVariable(string1), ACWithName(@"buildAString"))
ACInject(ACIntoVariable(string2), ACWithName(@"buildAString"))
ACInject(ACIntoVariable(string3), ACWithName(@"buildAComponentString"))
ACInject(ACIntoVariable(string4), ACWithName(@"buildAComponentString"))

- (void)testSimpleFactoryMethod {
    XCTAssertTrue([string1 hasPrefix:@"Factory string"]);
    XCTAssertTrue([string2 hasPrefix:@"Factory string"]);
    XCTAssertNotEqualObjects(string1, string2);
}

-(void) testFactoryMethodWithComponentArgument {
    XCTAssertTrue([string3 hasPrefix:@"Component Factory string"]);
    XCTAssertTrue([string4 hasPrefix:@"Component Factory string"]);
    XCTAssertNotEqualObjects(string3, string4);
}

@end
