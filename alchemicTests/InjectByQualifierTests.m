//
//  InjectByMatcherTests.m
//  alchemic
//
//  Created by Derek Clarkson on 30/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "Alchemic.h"

@import XCTest;

@interface InjectByMatcherTests : ALCTestCase

@end

@implementation InjectByMatcherTests {
    id _simpleObject;
}

injectValue(intoVariable(_simpleObject), withName(abc))

-(void) setUp {
    resolveDependencies(self);
}

-(void) testInjectByMatcher {
    XCTAssertNotNil(_simpleObject);
}

@end
