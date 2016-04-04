//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <StoryTeller/StoryTeller.h>

#import "ALCContext.h"
#import "ALCContextImpl.h"
#import "ALCObjectFactory.h"
#import "ALCClassObjectFactory.h"
#import "ALCInstantiation.h"
#import "TopThing.h"
#import "ALCConstants.h"
#import "ALCInternalMacros.h"

@interface Instantiations : XCTestCase
@end

@implementation Instantiations {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThingFactory;
}

-(void) setUp {
    STStartLogging(@"[TopThing]");
    STStartLogging(@"[Alchemic]");
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
}

-(void) testSimpleInstantiation {

    [_context start];

    XCTAssertTrue(_topThingFactory.ready);

    id value = _topThingFactory.objectInstantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
}

-(void) testInitializerInstantiationObject {

    [_context registerObjectFactory:_topThingFactory
                        initializer:@selector(initWithString:), AcString(@"abc"), nil];
    [_context start];

    XCTAssertTrue(_topThingFactory.ready);

    id value = _topThingFactory.objectInstantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqual(@"abc", ((TopThing *)value).aString);
}

-(void) testInitializerInstantiationObjectAndScalar {

    ignoreSelectorWarnings(
                           SEL selector = @selector(initWithString:andInt:);
    )
    [_context registerObjectFactory:_topThingFactory
                        initializer:selector, AcString(@"abc"), AcInt(5), nil];
    [_context start];

    XCTAssertTrue(_topThingFactory.ready);

    id value = _topThingFactory.objectInstantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqual(@"abc", ((TopThing *)value).aString);
    XCTAssertEqual(5, ((TopThing *)value).aInt);
}

@end
