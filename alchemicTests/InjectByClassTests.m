//
//  AlchemicRuntimeInjectorTests.m
//  alchemic
//
//  Created by Derek Clarkson on 17/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "Alchemic.h"
#import "SimpleObject.h"

@interface InjectByClassTests : ALCTestCase
@end

@implementation InjectByClassTests {
    SimpleObject *_simpleObject;
}

injectValues(intoVariable(_simpleObject))

-(void) setUp {
    resolveDependencies(self);
}

-(void) testInjectByClass {
    XCTAssertNotNil(_simpleObject);
}

@end
