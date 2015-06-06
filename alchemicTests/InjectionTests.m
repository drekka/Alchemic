//
//  InjectByMatcherTests.m
//  alchemic
//
//  Created by Derek Clarkson on 30/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "Alchemic.h"
#import "SingletonObject.h"

@import XCTest;

@interface InjectionTests : ALCTestCase
@end

@implementation InjectionTests {
    id _singletonObject;
    id _listSimpleObjects;
}

inject(intoVariable(_singletonObject), withName(@"Test singleton"))
inject(intoVariable(_listSimpleObjects), withClass(SingletonObject))

-(void) setUp {
    injectDependencies(self);
}

-(void) testInjectByName {
    XCTAssertNotNil(_singletonObject);
    XCTAssertTrue([_singletonObject isKindOfClass:[SingletonObject class]]);
}

-(void) testInjectByClass {
    XCTAssertNotNil(_listSimpleObjects);
    XCTAssertTrue([_listSimpleObjects isKindOfClass:[NSArray class]]);
}

@end
