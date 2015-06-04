//
//  InjectByMatcherTests.m
//  alchemic
//
//  Created by Derek Clarkson on 30/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "Alchemic.h"
#import "SimpleObject.h"

@import XCTest;

@interface InjectByMatcherTests : ALCTestCase
@end

@implementation InjectByMatcherTests {
    id _simpleObject1;
    id _listSimpleObjects;
}

inject(intoVariable(_simpleObject1), withName(@"abc"))
inject(intoVariable(_listSimpleObjects), withClass(SimpleObject))

-(void) setUp {
    injectDependencies(self);
}

-(void) testInjectByName {
    XCTAssertNotNil(_simpleObject1);
    XCTAssertTrue([_simpleObject1 isKindOfClass:[SimpleObject class]]);
}

-(void) testInjectByClass {
    XCTAssertNotNil(_listSimpleObjects);
    XCTAssertTrue([_listSimpleObjects isKindOfClass:[NSArray class]]);
}

@end
