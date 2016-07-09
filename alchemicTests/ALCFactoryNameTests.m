//
//  ALCFactoryNameTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/07/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Alchemic;
@import XCTest;

@interface ALCFactoryNameTests : XCTestCase

@end

@implementation ALCFactoryNameTests

-(void) testWithName {
    ALCFactoryName *fn = [ALCFactoryName withName:@"abc"];
    XCTAssertEqualObjects(@"abc", fn.asName);
}


@end
