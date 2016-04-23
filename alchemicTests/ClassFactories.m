//
//  FactoryFactories.m
//  Alchemic
//
//  Created by Derek Clarkson on 21/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>

#import "ALCContextImpl.h"
#import "ALCClassObjectFactory.h"
#import "ALCIsFactory.h"

#import "TopThing.h"
#import "NestedThing.h"

@interface ClassFactories : XCTestCase

@end

@implementation ClassFactories {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThingFactory;
    ALCClassObjectFactory *_nestedThingFactory;
}

-(void) setUp {
    STStartLogging(@"<ALCContext>");
    STStartLogging(@"is [TopThing]");
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
    _nestedThingFactory = [_context registerObjectFactoryForClass:[NestedThing class]];
}

-(void) testCreatingNewInstances {
    [_topThingFactory configureWithOptions:@[[ALCIsFactory factoryMacro]] unknownOptionHandler:^(id option) {
        XCTFail();
    }];

    [_context start];

    TopThing *t1 = [_context objectWithClass:[TopThing class], nil];
    TopThing *t2 = [_context objectWithClass:[TopThing class], nil];

    XCTAssertNotNil(t1);
    XCTAssertNotNil(t2);
    XCTAssertNotEqual(t1, t2);
}

-(void) testCreatingNestedNewInstances {
    [_topThingFactory configureWithOptions:@[[ALCIsFactory factoryMacro]] unknownOptionHandler:^(id option) {
        XCTFail();
    }];
    [_nestedThingFactory configureWithOptions:@[[ALCIsFactory factoryMacro]] unknownOptionHandler:^(id option) {
        XCTFail();
    }];

    [_context objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", nil];

    [_context start];

    TopThing *t1 = [_context objectWithClass:[TopThing class], nil];
    TopThing *t2 = [_context objectWithClass:[TopThing class], nil];

    NestedThing *n1 = t1.aNestedThing;
    NestedThing *n2 = t2.aNestedThing;

    XCTAssertNotNil(t1);
    XCTAssertNotNil(t2);
    XCTAssertNotEqual(t1, t2);

    XCTAssertNotNil(n1);
    XCTAssertNotNil(n2);
    XCTAssertNotEqual(n1, n2);
}

@end
