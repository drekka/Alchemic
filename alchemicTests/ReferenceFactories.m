//
//  ReferenceFactories.m
//  alchemic
//
//  Created by Derek Clarkson on 18/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

@import StoryTeller;

@import Alchemic;
@import Alchemic.Private;

#import "XCTestCase+Alchemic.h"
#import "TopThing.h"
#import "NestedThing.h"

@interface ReferenceFactories : XCTestCase
@end

@implementation ReferenceFactories {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThingFactory;
}

-(void) setUp {
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
}

-(void) testAcessingUnsetReferenceThrows {
    
    [_context objectFactoryConfig:_topThingFactory, AcReference, nil];
    
    [_context start];
    
    XCTAssertFalse(_topThingFactory.isReady);

    XCTAssertThrowsSpecific(self->_topThingFactory.instantiation.object, AlchemicReferenceObjectNotSetException);
}

-(void) testSettingReferenceBringsFactoryOnline {
    
    [_context objectFactoryConfig:_topThingFactory, AcReference, nil];
    [_context start];
    
    id extObj = [[TopThing alloc] init];
    [_topThingFactory setObject:extObj];
    
    XCTAssertTrue(_topThingFactory.isReady);
    id object = _topThingFactory.instantiation.object;
    XCTAssertEqual(extObj, object);
}

-(void) testSettingInitializerOnReferenceFactoryThrowsException {
    [_context objectFactoryConfig:_topThingFactory, AcReference, nil];
    XCTAssertThrowsSpecific(([self->_context objectFactory:self->_topThingFactory initializer:@selector(initWithNoArgs), nil]), AlchemicIllegalArgumentException);
}

-(void) testSettingFactoryWithInitializerToReferenceTypeThrowsException {
    [_context objectFactory:_topThingFactory initializer:@selector(initWithNoArgs), nil];
    XCTAssertThrowsSpecific(([self->_context objectFactoryConfig:self->_topThingFactory, AcReference, nil]), AlchemicIllegalArgumentException);
}

-(void) testSettingMethodFactoryAsReferenceTypeThrowsException {
    XCTAssertThrowsSpecific(([self->_context objectFactory:self->_topThingFactory registerFactoryMethod:@selector(nestedThingFactoryMethod) returnType:[NestedThing class], AcReference, nil]), AlchemicIllegalArgumentException);
}

@end
