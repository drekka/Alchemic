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

#import "Component.h"
#import "InjectableObject.h"

@interface SimpleTests : ALCTestCase
@end

@implementation SimpleTests {
    Component *_component;
}

injectValues(@"_component")

-(void) testAlchemicStartup {
    XCTAssertNotNil(_component);
    XCTAssertNotNil(_component.injObj);
    XCTAssertNotNil(_component.injProto);
    XCTAssertEqualObjects(_component.injObj, _component.injProto);
}

@end
