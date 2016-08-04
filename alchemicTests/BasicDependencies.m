//
//  SingletonToSingleton.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

@import Alchemic;
@import Alchemic.Private;
@import StoryTeller;

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
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
    _nestedThingFactory = [_context registerObjectFactoryForClass:[NestedThing class]];
}

-(void)tearDown {
    [_topThingFactory unload];
    [_nestedThingFactory unload];
}

-(void) testSimpleDependencyPublicVariable {
    [_context objectFactory:_topThingFactory registerInjection:@"aNestedThing", nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
    XCTAssertTrue([topThing.aNestedThing isKindOfClass:[NestedThing class]]);
}

-(void) testSimpleDependencyInternalVariable {
    [_context objectFactory:_topThingFactory registerInjection:@"_aNestedThing", nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
    XCTAssertTrue([topThing.aNestedThing isKindOfClass:[NestedThing class]]);
}

-(void) testSimpleDependencyArrayByClass {
    [_context objectFactory:_topThingFactory registerInjection:@"arrayOfNestedThings", AcClass(NestedThing), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.arrayOfNestedThings);
    XCTAssertEqual(1u, topThing.arrayOfNestedThings.count);
    XCTAssertTrue([topThing.arrayOfNestedThings[0] isKindOfClass:[NestedThing class]]);
}

-(void) testSimpleDependencyArrayByProtocol {
    [_context objectFactory:_topThingFactory registerInjection:@"arrayOfNestedThings", AcProtocol(NestedProtocol), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.arrayOfNestedThings);
    XCTAssertEqual(1u, topThing.arrayOfNestedThings.count);
    XCTAssertTrue([topThing.arrayOfNestedThings[0] isKindOfClass:[NestedThing class]]);
}

#pragma mark - Search criteria

-(void) testSimpleDependencyPublicVariableNameSearchUsingDefaultName {
    [_context objectFactory:_topThingFactory registerInjection:@"aNestedThing", AcName(@"NestedThing"), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testSimpleDependencyPublicVariableNameSearchUsingCustomName {
    [_context objectFactoryConfig:_nestedThingFactory, [ALCFactoryName withName:@"abc"], nil];
    [_context objectFactory:_topThingFactory registerInjection:@"aNestedThing", AcName(@"abc"), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testSimpleDependencyPublicVariableProtocolSearch {
    [_context objectFactory:_topThingFactory registerInjection:@"aNestedThing", AcProtocol(NestedProtocol), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testSimpleDependencyPublicVariableClassSearch {
    [_context objectFactory:_topThingFactory registerInjection:@"aNestedThing", AcClass(NestedThing), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNotNil(topThing.aNestedThing);
}

-(void) testDependentObjectDependenciesInjected {
    [_context objectFactory:_topThingFactory registerInjection:@"_aNestedThing", nil];
    [_context objectFactory:_nestedThingFactory registerInjection:@"aInt", AcInt(5), nil];
    [_context start];
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertEqual(5, topThing.aNestedThing.aInt);
}

#pragma mark - Transients

-(void) testTransientDependency {

    [_context objectFactoryConfig:_nestedThingFactory, AcReference, AcNillable, nil];
    [_context objectFactory:_topThingFactory registerInjection:@"aNestedThing", AcTransient, AcNillable, nil];
    [_context start];

    // Validate initial setup
    TopThing *topThing = _topThingFactory.instantiation.object;
    XCTAssertNotNil(topThing);
    XCTAssertNil(topThing.aNestedThing);

    // Now set a value.
    NestedThing *nt = [[NestedThing alloc] init];
    [_nestedThingFactory setObject:nt];

    XCTAssertNotNil(topThing.aNestedThing);
    XCTAssertEqual(nt, topThing.aNestedThing);

    // Now nil it out again.
    [_nestedThingFactory setObject:nil];
    XCTAssertNil(topThing.aNestedThing);

    // Now set a new value.
    NestedThing *nt2 = [[NestedThing alloc] init];
    [_nestedThingFactory setObject:nt2];

    XCTAssertNotNil(topThing.aNestedThing);
    XCTAssertEqual(nt2, topThing.aNestedThing);
    XCTAssertNotEqual(nt, topThing.aNestedThing);

}

@end

