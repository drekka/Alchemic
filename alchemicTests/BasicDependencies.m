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

@interface BasicDependencies : XCTestCase
@end

@implementation BasicDependencies {
    id<ALCContext> _context;
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
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
    _nestedThingFactory = [_context registerObjectFactoryForClass:[NestedThing class]];
}

-(void) testSimpleDependencyPublicVariable {
    [_context objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", nil];
    [_context start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
    XCTAssertTrue([topThing.aNestedThing isKindOfClass:[NestedThing class]]);
}

-(void) testSimpleDependencyInternalVariable {
    [_context objectFactory:_topThingFactory vaiableInjection:@"_aNestedThing", nil];
    [_context start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
    XCTAssertTrue([topThing.aNestedThing isKindOfClass:[NestedThing class]]);
}

-(void) testSimpleDependencyArrayByClass {
    [_context objectFactory:_topThingFactory vaiableInjection:@"arrayOfNestedThings", AcClass(NestedThing), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.arrayOfNestedThings);
    XCTAssertEqual(1u, topThing.arrayOfNestedThings.count);
    XCTAssertTrue([topThing.arrayOfNestedThings[0] isKindOfClass:[NestedThing class]]);
}

-(void) testSimpleDependencyArrayByProtocol {
    [_context objectFactory:_topThingFactory vaiableInjection:@"arrayOfNestedThings", AcProtocol(NestedProtocol), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.arrayOfNestedThings);
    XCTAssertEqual(1u, topThing.arrayOfNestedThings.count);
    XCTAssertTrue([topThing.arrayOfNestedThings[0] isKindOfClass:[NestedThing class]]);
}

#pragma mark - Search criteria

-(void) testSimpleDependencyPublicVariableNameSearchUsingDefaultName {
    [_context objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", AcName(@"NestedThing"), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testSimpleDependencyPublicVariableNameSearchUsingCustomName {
    [_context objectFactoryConfig:_nestedThingFactory, [ALCFactoryName withName:@"abc"], nil];
    [_context objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", AcName(@"abc"), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testSimpleDependencyPublicVariableProtocolSearch {
    [_context objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", AcProtocol(NestedProtocol), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testSimpleDependencyPublicVariableClassSearch {
    [_context objectFactory:_topThingFactory vaiableInjection:@"aNestedThing", AcClass(NestedThing), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testDependentObjectDependenciesInjected {
    [_context objectFactory:_topThingFactory vaiableInjection:@"_aNestedThing", nil];
    [_context objectFactory:_nestedThingFactory vaiableInjection:@"aInt", AcInt(5), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.objectInstantiation.object;
    XCTAssertEqual(5, topThing.aNestedThing.aInt);
}


@end

