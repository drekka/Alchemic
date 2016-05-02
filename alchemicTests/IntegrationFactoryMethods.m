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

@interface IntegrationFactoryMethods : XCTestCase
@end

@implementation IntegrationFactoryMethods {
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

    AcIgnoreSelectorWarnings(
                           SEL selector = @selector(nestedThingFactoryMethod);
                           )
    [_context objectFactory:_topThingFactory
              factoryMethod:selector
                 returnType:[NestedThing class], nil];
    [_context start];

    [self validateInstanceWithString:@"abc" int:5];
}

-(void) testInstanceFactoryMethodWithStringArg {

    AcIgnoreSelectorWarnings(
                           SEL selector = @selector(nestedThingFactoryMethodWithString:);
                           )
    [_context objectFactory:_topThingFactory
              factoryMethod:selector
                 returnType:[NestedThing class], AcString(@"def"), nil];
    [_context start];

    [self validateInstanceWithString:@"def" int:5];
}

-(void) testInstanceFactoryMethodWithStringAndScalarArg {

    AcIgnoreSelectorWarnings(
                           SEL selector = @selector(nestedThingFactoryMethodWithString:andInt:);
                           )
    [_context objectFactory:_topThingFactory
              factoryMethod:selector
                 returnType:[NestedThing class], AcString(@"def"), AcInt(12), nil];
    [_context start];

    [self validateInstanceWithString:@"def" int:12];
}

-(void) validateInstanceWithString:(NSString *) aString int:(int) aInt {
    NestedThing *thing = [_context objectWithClass:[NestedThing class], nil];
    XCTAssertEqualObjects(aString, thing.aString);
    XCTAssertEqual(aInt, thing.aInt);
}

@end
