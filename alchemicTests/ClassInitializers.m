//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

@import StoryTeller;

@import Alchemic;
@import Alchemic.Private;

#import "TopThing.h"
#import "NestedThing.h"

@interface ClassInitializers : XCTestCase
@end

@implementation ClassInitializers {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThingFactory;
    ALCClassObjectFactory *_nestedThingFactory;
}

-(void) setUp {
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
    _nestedThingFactory = [_context registerObjectFactoryForClass:[NestedThing class]];
}

-(void) testInitializer {
    
    AcIgnoreSelectorWarnings(
                             SEL initSel = @selector(initWithNoArgs);
                             )
    [_context objectFactory:_topThingFactory initializer:initSel, nil];
    [_context start];
    
    XCTAssertTrue(_topThingFactory.isReady);
    
    id value = _topThingFactory.instantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqualObjects(@"abc", ((NestedThing *)value).aString);
}

-(void) testInitializerWithString {
    
    [_context objectFactory:_topThingFactory initializer:@selector(initWithString:), AcString(@"abc"), nil];
    [_context start];
    
    XCTAssertTrue(_topThingFactory.isReady);
    
    id value = _topThingFactory.instantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqual(@"abc", ((TopThing *)value).aString);
}

-(void) testInitializerWithStringAndScalar {
    
    AcIgnoreSelectorWarnings(
                             SEL selector = @selector(initWithString:andInt:);
                             )
    [_context objectFactory:_topThingFactory
             initializer:selector, AcString(@"abc"), AcInt(5), nil];
    [_context start];
    
    XCTAssertTrue(_topThingFactory.isReady);
    
    id value = _topThingFactory.instantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqual(@"abc", ((TopThing *)value).aString);
    XCTAssertEqual(5, ((TopThing *)value).aInt);
}

-(void) testInitializerWithArray {
    AcIgnoreSelectorWarnings(
                             SEL selector = @selector(initWithNestedThings:);
                             )
    ALCType *type = [ALCType typeWithClass:[NSArray class]];
    id<ALCValueSource> source = [ALCModelValueSource valueSourceWithCriteria:AcClass(NestedThing)];
    ALCMethodArgumentDependency *arg = [ALCMethodArgumentDependency dependencyWithType:type valueSource:source];
    [_context objectFactory:_topThingFactory initializer:selector, arg, nil];
    [_context start];
    
}

@end
