//
//  ReferenceFactories.m
//  alchemic
//
//  Created by Derek Clarkson on 18/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <StoryTeller/StoryTeller.h>

#import <Alchemic/Alchemic.h>

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
    STStartLogging(@"[TopThing]");
    STStartLogging(@"[Alchemic]");
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
}

-(void) testAcessingUnsetReferenceThrows {
    
    [_topThingFactory configureWithOptions:@[AcReference] customOptionHandler:^(id option) {
        XCTFail();
    }];
    
    [_context start];
    
    XCTAssertFalse(_topThingFactory.ready);
    
    [self executeBlockWithException:[AlchemicReferencedObjectNotSetException class] block:^{
        __unused id object = self->_topThingFactory.instantiation.object;
    }];
}

-(void) testSettingReferenceBringsFactoryOnline {
    
    [_topThingFactory configureWithOptions:@[AcReference] customOptionHandler:^(id option) {
        XCTFail();
    }];
    
    [_context start];
    
    id extObj = [[TopThing alloc] init];
    [_topThingFactory setObject:extObj];
    
    XCTAssertTrue(_topThingFactory.ready);
    id object = _topThingFactory.instantiation.object;
    XCTAssertEqual(extObj, object);
}

-(void) testSettingFactoryWithInitializerThrowsException {
    [_context objectFactory:_topThingFactory setInitializer:@selector(initWithNoArgs), nil];
    
    [self executeBlockWithException:[AlchemicReferencedObjectNotSetException class] block:^{
        [self->_topThingFactory configureWithOptions:@[AcReference] customOptionHandler:^(id option) {
            XCTFail();
        }];
    }];
}

@end
