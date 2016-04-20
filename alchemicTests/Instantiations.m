//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <StoryTeller/StoryTeller.h>

#import <Alchemic/Alchemic.h>

//#import "Alchemic.h"
//#import "ALCContext.h"
#import "ALCContextImpl.h"
//#import "ALCObjectFactory.h"
#import "ALCClassObjectFactory.h"
//#import "ALCInstantiation.h"
//#import "ALCConstants.h"
//#import "ALCInternalMacros.h"
//#import "ALCArgument.h"
//#import "ALCMAcros.h"
//#import "ALCModelSearchCriteria.h"

#import "TopThing.h"
#import "NestedThing.h"

@interface Instantiations : XCTestCase
@end

@implementation Instantiations {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThingFactory;
    ALCClassObjectFactory *_nestedThingFactory;
}

-(void) setUp {
    STStartLogging(@"[TopThing]");
    STStartLogging(@"[Alchemic]");
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
    _nestedThingFactory = [_context registerObjectFactoryForClass:[NestedThing class]];
}

-(void) testSimpleInstantiation {

    [_context start];

    XCTAssertTrue(_topThingFactory.ready);

    id value = _topThingFactory.objectInstantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
}

-(void) testInitializerInstantiationObject {

    [_context objectFactory:_topThingFactory
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
    [_context objectFactory:_topThingFactory
                        initializer:selector, AcString(@"abc"), AcInt(5), nil];
    [_context start];

    XCTAssertTrue(_topThingFactory.ready);

    id value = _topThingFactory.objectInstantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqual(@"abc", ((TopThing *)value).aString);
    XCTAssertEqual(5, ((TopThing *)value).aInt);
}

-(void) testInitializerInstantiationArray {
    ignoreSelectorWarnings(
                           SEL selector = @selector(initWithNestedThings:);
                           )
    [_context objectFactory:_topThingFactory
                        initializer:selector, AcArgument([NSArray class], AcClass(NestedThing), nil), nil];
    [_context start];

}

@end
