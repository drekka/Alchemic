//
//  ModelInjectionTests.m
//  alchemic
//
//  Created by Derek Clarkson on 2/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "Component.h"
#import "InjectableObject.h"
#import "Alchemic.h"

@interface ModelInjectionTests : ALCTestCase

@end

@implementation ModelInjectionTests {
    Component *_component;
    InjectableObject *_injectableObject;
}

injectValues(@"_component", @"_injectableObject")

-(void) setUp {
    injectDependencies(self);
}

-(void) testInjections {
    XCTAssertNotNil(_component);
    XCTAssertNotNil(_injectableObject);
}

@end
