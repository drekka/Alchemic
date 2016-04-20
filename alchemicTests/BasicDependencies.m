//
//  SingletonToSingleton.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

#import "TopThing.h"
#import "NestedThing.h"
#import "Alchemic+Internal.h"

@interface BasicDependencies : XCTestCase
@end

@implementation BasicDependencies {
    ALCClassObjectFactory *_topThingFactory;
    ALCClassObjectFactory *_nestedThingFactory;
}

-(void) setUp {
    //((STConsoleLogger *)[STStoryTeller storyTeller].logger).addXcodeColours = YES;
    //((STConsoleLogger *)[STStoryTeller storyTeller].logger).messageColour = [UIColor whiteColor];
    //((STConsoleLogger *)[STStoryTeller storyTeller].logger).detailsColour = [UIColor lightGrayColor];
    STStartLogging(@"<ALCContext>");
    STStartLogging(@"is [TopThing]");
    STStartLogging(@"is [NestedThing]");
    [Alchemic initContext];
    _topThingFactory = [[Alchemic mainContext] registerObjectFactoryForClass:[TopThing class]];
    _nestedThingFactory = [[Alchemic mainContext] registerObjectFactoryForClass:[NestedThing class]];
}

-(void) testSimpleDependencyPublicVariable {
    [[Alchemic mainContext] objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", nil];
    [[Alchemic mainContext] start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
    XCTAssertTrue([topThing.aNestedThing isKindOfClass:[NestedThing class]]);
}

-(void) testSimpleDependencyInternalVariable {
    [[Alchemic mainContext] objectFactory:_topThingFactory vaiableInjection:@"_aNestedThing", nil];
    [[Alchemic mainContext] start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
    XCTAssertTrue([topThing.aNestedThing isKindOfClass:[NestedThing class]]);
}

-(void) testSimpleDependencyArrayByClass {
    [[Alchemic mainContext] objectFactory:_topThingFactory vaiableInjection:@"arrayOfNestedThings", AcClass(NestedThing), nil];
    [[Alchemic mainContext] start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.arrayOfNestedThings);
    XCTAssertEqual(1u, topThing.arrayOfNestedThings.count);
    XCTAssertTrue([topThing.arrayOfNestedThings[0] isKindOfClass:[NestedThing class]]);
}

-(void) testSimpleDependencyArrayByProtocol {
    [[Alchemic mainContext] objectFactory:_topThingFactory vaiableInjection:@"arrayOfNestedThings", AcProtocol(NestedProtocol), nil];
    [[Alchemic mainContext] start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.arrayOfNestedThings);
    XCTAssertEqual(1u, topThing.arrayOfNestedThings.count);
    XCTAssertTrue([topThing.arrayOfNestedThings[0] isKindOfClass:[NestedThing class]]);
}

#pragma mark - Search criteria

-(void) testSimpleDependencyPublicVariableNameSearch {
    [[Alchemic mainContext] objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", AcName(@"NestedThing"), nil];
    [[Alchemic mainContext] start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testSimpleDependencyPublicVariableProtocolSearch {
    [[Alchemic mainContext] objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", AcProtocol(NestedProtocol), nil];
    [[Alchemic mainContext] start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testSimpleDependencyPublicVariableClassSearch {
    [[Alchemic mainContext] objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", AcClass(NestedThing), nil];
    [[Alchemic mainContext] start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testDependentObjectDependenciesInjected {
    [[Alchemic mainContext] objectFactory:_topThingFactory vaiableInjection:@"_aNestedThing", nil];
    [[Alchemic mainContext] objectFactory:_nestedThingFactory vaiableInjection:@"aInt", AcInt(5), nil];
    [[Alchemic mainContext] start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertEqual(5, topThing.aNestedThing.aInt);
}


@end

