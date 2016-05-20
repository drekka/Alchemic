//
//  AccessingObjects.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
@import StoryTeller;

@import Alchemic;
@import Alchemic.Private;

#import "TopThing.h"
#import "NestedThing.h"


@interface AccessingObjects : XCTestCase
@end

@implementation AccessingObjects {
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

-(void) testSimpleGet {
    
    [_context start];
    
    TopThing *topThing = [_context objectWithClass:[TopThing class], nil];
    
    XCTAssertNotNil(topThing);
    XCTAssertTrue([topThing isKindOfClass:[TopThing class]]);
}

-(void) testGetWithNestedValue {
    
    [_context objectFactory:_topThingFactory registerVariableInjection:@"aNestedThing", nil];
    
    [_context start];
    
    TopThing *topThing = [_context objectWithClass:[TopThing class], nil];
    
    XCTAssertNotNil(topThing);
    XCTAssertTrue([topThing isKindOfClass:[TopThing class]]);
    XCTAssertNotNil(topThing.aNestedThing);
    XCTAssertTrue([topThing.aNestedThing isKindOfClass:[NestedThing class]]);
    
}

@end
