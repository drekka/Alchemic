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

@interface FactoryMethods : XCTestCase
@end

@implementation FactoryMethods {
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
                           SEL selector = @selector(nestedThingFactoryMethod);
                           )
    [_context objectFactory:_topThingFactory
              factoryMethod:selector
                 returnType:[NestedThing class], nil];
    [_context start];

    NestedThing *thing = [_context objectWithClass:[NestedThing class], nil];
    XCTAssertEqualObjects(@"abc", thing.aString);
    XCTAssertEqual(5, thing.aInt);
}

-(void) testInstanceFactoryMethodWithStringArg {

    ignoreSelectorWarnings(
                           SEL selector = @selector(nestedThingFactoryMethodWithString:);
                           )
    [_context objectFactory:_topThingFactory
              factoryMethod:selector
                 returnType:[NestedThing class], AcString(@"def"), nil];
    [_context start];

    NestedThing *thing = [_context objectWithClass:[NestedThing class], nil];
    XCTAssertEqualObjects(@"def", thing.aString);
    XCTAssertEqual(5, thing.aInt);
}

-(void) testInstanceFactoryMethodWithStringAndScalarArg {

    ignoreSelectorWarnings(
                           SEL selector = @selector(nestedThingFactoryMethodWithString:andInt:);
                           )
    [_context objectFactory:_topThingFactory
              factoryMethod:selector
                 returnType:[NestedThing class], AcString(@"def"), AcInt(12), nil];
    [_context start];

    NestedThing *thing = [_context objectWithClass:[NestedThing class], nil];
    XCTAssertEqualObjects(@"def", thing.aString);
    XCTAssertEqual(12, thing.aInt);
}

@end
