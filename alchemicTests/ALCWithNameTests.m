//
//  ALCConstantValueTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCWithName.h"

@import XCTest;

@interface ALCWithNameTests : XCTestCase

@end

@implementation ALCWithNameTests

-(void) testFactoryMethod {
	ALCWithName *macro = [ALCWithName withName:@"abc"];
	XCTAssertEqualObjects(@"abc", macro.asName);
}

@end
