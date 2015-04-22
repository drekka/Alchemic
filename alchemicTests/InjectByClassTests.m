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

inject(intoVariable(_simpleObject))

-(void) setUp {
    injectDependencies(self);
}

-(void) testInjectByClass {
    XCTAssertNotNil(_simpleObject);
}

@end
