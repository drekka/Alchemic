//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <OCMock/OCMock.h>

@import StoryTeller;

@import Alchemic;
@import Alchemic.Private;

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
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
    _nestedThingFactory = [_context registerObjectFactoryForClass:[NestedThing class]];
}

-(void) testSimpleInstantiation {

    [_context start];

    XCTAssertTrue(_topThingFactory.isReady);

    id value = _topThingFactory.instantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
}

-(void) testFactoryCreatingNewInstances {

    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_topThingFactory configureWithOptions:@[[ALCIsTemplate macro]] model:mockModel];

    [_context start];

    TopThing *t1 = [_context objectWithClass:[TopThing class], nil];
    TopThing *t2 = [_context objectWithClass:[TopThing class], nil];

    XCTAssertNotNil(t1);
    XCTAssertNotNil(t2);
    XCTAssertNotEqual(t1, t2);
}

-(void) testFactoryCreatingNestedNewInstances {
    
    id mockModel = OCMProtocolMock(@protocol(ALCModel));
    [_topThingFactory configureWithOptions:@[[ALCIsTemplate macro]] model:mockModel];
    [_nestedThingFactory configureWithOptions:@[[ALCIsTemplate macro]] model:mockModel];

    [_context objectFactory:_topThingFactory registerVariableInjection:@"aNestedThing", nil];

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
