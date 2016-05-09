//
//  SingletonCircularReferences.m
//  Alchemic
//
//  Created by Derek Clarkson on 9/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

#import "TopThing.h"
#import "AnotherThing.h"

@interface CircularReferences : XCTestCase

@end

@implementation CircularReferences {
    id<ALCContext> _context;
    id<ALCObjectFactory> _topFactory;
    id<ALCObjectFactory> _anotherFactory;
}

-(void) setUp {
    STStartLogging(@"<ALCContext>");
    STStartLogging(@"is [TopThing]");
    STStartLogging(@"is [AnotherThing]");
    _context = [[ALCContextImpl alloc] init];
    _topFactory = [_context registerObjectFactoryForClass:[TopThing class]];
    _anotherFactory = [_context registerObjectFactoryForClass:[AnotherThing class]];
}

-(void) testPropertyToProperty {
    [_context objectFactory:_topFactory vaiableInjection:@"anotherThing", nil];
    [_context objectFactory:_anotherFactory vaiableInjection:@"topThing", nil];

    [_context start];

    TopThing *topThing = _topFactory.instantiation.object;
    XCTAssertNotNil(topThing);

    AnotherThing *anotherThing = _anotherFactory.instantiation.object;
    XCTAssertNotNil(anotherThing);

    XCTAssertEqual(topThing.anotherThing, anotherThing);
    XCTAssertEqual(anotherThing.topThing, topThing);
}

-(void) testInitializerToInitializer {
    AcIgnoreSelectorWarnings(
                           SEL topThingInit =@selector(initWithAnotherThing:);
                           SEL anotherThingInit =@selector(initWithTopThing:);
                           )
    [_context objectFactory:_topFactory initializer:topThingInit, AcClass(AnotherThing), nil];
    [_context objectFactory:_anotherFactory initializer:anotherThingInit, AcClass(TopThing), nil];
    @try {
        [_context start];
    } @catch (ALCException *exception) {
        XCTAssertEqualObjects(@"AlchemicCircularDependency", exception.name);
    } @catch (NSException *exception) {
        XCTFail(@"Un-expected exception %@", exception);
    }
}

-(void) testPropertyToInitializer {
    [_context objectFactory:_topFactory vaiableInjection:@"anotherThing", nil];
    AcIgnoreSelectorWarnings(
                           SEL anotherThingInit =@selector(initWithTopThing:);
                           )
    [_context objectFactory:_anotherFactory
                initializer:anotherThingInit, AcClass(TopThing), nil];

    [_context start];

    TopThing *topThing = _topFactory.instantiation.object;
    XCTAssertNotNil(topThing);

    AnotherThing *anotherThing = _anotherFactory.instantiation.object;
    XCTAssertNotNil(anotherThing);

    XCTAssertEqual(topThing.anotherThing, anotherThing);
    XCTAssertEqual(anotherThing.topThing, topThing);
}

-(void) testInitializerToProperty {
    AcIgnoreSelectorWarnings(
                           SEL topThingInit =@selector(initWithAnotherThing:);
                           )
    [_context objectFactory:_topFactory initializer:topThingInit, AcClass(AnotherThing), nil];
    [_context objectFactory:_anotherFactory vaiableInjection:@"topThing", nil];

    [_context start];

    TopThing *topThing = _topFactory.instantiation.object;
    XCTAssertNotNil(topThing);

    AnotherThing *anotherThing = _anotherFactory.instantiation.object;
    XCTAssertNotNil(anotherThing);

    AnotherThing *nestedAnotherThing = topThing.anotherThing;
    XCTAssertEqual(nestedAnotherThing, anotherThing);
    XCTAssertEqual(anotherThing.topThing, topThing);
}

@end
