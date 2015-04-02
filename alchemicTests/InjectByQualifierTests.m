//
//  InjectByQualifierTests.m
//  alchemic
//
//  Created by Derek Clarkson on 30/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "Alchemic.h"

@import XCTest;

@interface InjectByQualifierTests : ALCTestCase

@end

@implementation InjectByQualifierTests {
    id _simpleObject;
}

injectValueWithName(@"_simpleObject", @"abc")

-(void) setUp {
    resolveDependencies(self);
}

-(void) testInjectByQualifier {
    XCTAssertNotNil(_simpleObject);
}

@end
