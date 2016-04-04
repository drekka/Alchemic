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

#import "Alchemic+Internal.h"
#import "TopThing.h"
#import "AnotherThing.h"
#import "ALCInternalMacros.h"

@interface CircularReferences : XCTestCase

@end

@implementation CircularReferences {
    id<ALCObjectFactory> _topFactory;
    id<ALCObjectFactory> _anotherFactory;
}

-(void) setUp {
    STStartLogging(@"<ALCContext>");
    STStartLogging(@"is [TopThing]");
    STStartLogging(@"is [AnotherThing]");
    [Alchemic initContext];
    _topFactory = [[Alchemic mainContext] registerObjectFactoryForClass:[TopThing class]];
    _anotherFactory = [[Alchemic mainContext] registerObjectFactoryForClass:[AnotherThing class]];
}

-(void) testPropertyToProperty {
    [[Alchemic mainContext] registerObjectFactory:_topFactory vaiableInjection:@"anotherThing", nil];
    [[Alchemic mainContext] registerObjectFactory:_anotherFactory vaiableInjection:@"topThing", nil];

    [[Alchemic mainContext] start];

    TopThing *topThing = _topFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);

    AnotherThing *anotherThing = _anotherFactory.objectInstantiation.object;
    XCTAssertNotNil(anotherThing);

    XCTAssertEqual(topThing.anotherThing, anotherThing);
    XCTAssertEqual(anotherThing.topThing, topThing);
}

-(void) testInitializerToInitializer {
    ignoreSelectorWarnings(
                           SEL topThingInit =@selector(initWithAnotherThing:);
                           SEL anotherThingInit =@selector(initWithTopThing:);
                           )
    [[Alchemic mainContext] registerObjectFactory:_topFactory
                                      initializer:topThingInit, AcClass(AnotherThing), nil];
    [[Alchemic mainContext] registerObjectFactory:_anotherFactory
                                      initializer:anotherThingInit, AcClass(TopThing), nil];
    @try {
        [[Alchemic mainContext] start];
    } @catch (ALCException *exception) {
        XCTAssertEqualObjects(@"AlchemicCircularDependency", exception.name);
    } @catch (NSException *exception) {
        XCTFail(@"Un-expected exception %@", exception);
    }

}

@end
