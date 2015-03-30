//
//  AlchemicRuntimeInjectorTests.m
//  alchemic
//
//  Created by Derek Clarkson on 17/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "Alchemic.h"
#import "ALCContext.h"

#import "ALCRuntime.h"
#import "SimpleObject.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface InjectByClassTests : ALCTestCase
@end

@implementation InjectByClassTests {
    SimpleObject *_simpleObject;
}

injectValues(@"_simpleObject")

-(void) setUp {
    injectDependencies(self);
}

-(void) testNonContextInjection {
    XCTAssertNotNil(_simpleObject);
}

@end
