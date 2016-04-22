//
//  MethodFactories.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>

#import "ALCContextImpl.h"
#import "ALCClassObjectFactory.h"
#import "ALCMethodObjectFactory.h"
#import "ALCInstantiation.h"

#import "TopThing.h"
#import "NestedThing.h"

@interface MethodSingletons : XCTestCase
@end

@implementation MethodSingletons {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThingFactory;
}

-(void) setUp {
    STStartLogging(@"[Alchemic]");
    STStartLogging(@"[TopThing]");
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
}

-(void) testInstanceFactoryMethod {

    ignoreSelectorWarnings(
                           SEL selector = @selector(factoryMethodWithString:);
                           )
    ALCMethodObjectFactory *methodFactory = [_context objectFactory:_topThingFactory
                                                      factoryMethod:selector
                                                         returnType:[TopThing class], AcString(@"abc"), nil];
    [_context start];

    XCTAssertTrue(_topThingFactory.ready);
    XCTAssertTrue(methodFactory.ready);

    id value = methodFactory.objectInstantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqual(@"abc", ((TopThing *)value).aString);
}

-(void) testInstanceFactoryMethodWithScalar {

    ignoreSelectorWarnings(
                           SEL selector = @selector(factoryMethodWithString:andInt:);
                           )
    ALCMethodObjectFactory *methodFactory = [_context objectFactory:_topThingFactory
                                                      factoryMethod:selector
                                                         returnType:[TopThing class], AcString(@"abc"), AcInt(5), nil];
    [_context start];

    XCTAssertTrue(_topThingFactory.ready);
    XCTAssertTrue(methodFactory.ready);

    id value = methodFactory.objectInstantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqualObjects(@"abc", ((TopThing *) value).aString);
    XCTAssertEqual(5, ((TopThing *) value).aInt);
}

@end
