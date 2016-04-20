//
//  ReferenceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "Alchemic.h"
//#import "ALCContext.h"
#import "ALCContextImpl.h"
//#import "ALCObjectFactory.h"
//#import "ALCClassObjectFactory.h"
//#import "ALCModelSearchCriteria.h"
//#import "ALCDependency.h"
//#import "ALCModelDependency.h"
//#import "ALCInstantiation.h"
//#import "ALCException.h"

#import "TopThing.h"
#import "NestedThing.h"

@interface ExternalReferences : XCTestCase
@end

@implementation ExternalReferences {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThing;
    ALCClassObjectFactory *_nestedThing;
}

-(void)setUp {
    _context = [[ALCContextImpl alloc] init];
    _topThing = [_context registerObjectFactoryForClass:[TopThing class]];
    _nestedThing = [_context registerObjectFactoryForClass:[NestedThing class]];
    _nestedThing.factoryType = ALCFactoryTypeReference;
}

-(void) testTopReferenceTypeInitiation {
    _topThing.factoryType = ALCFactoryTypeReference;

    [_context start];

    XCTAssertFalse(_topThing.ready);
    @try {
        __unused id object = _topThing.objectInstantiation.object;
        XCTFail(@"Exception not thrown getting reference type");
    }
    @catch (ALCException *exception) {
        XCTAssertEqualObjects(@"AlchemicReferencedObjectNotSet", exception.name);
    }
    @catch (NSException *exception) {
        XCTFail(@"Un-expected exception %@", exception);
    }

}

-(void) testTopReferenceTypeSet {
    _topThing.factoryType = ALCFactoryTypeReference;

    [_context start];

    id extObj = [[TopThing alloc] init];
    [_topThing setObject:extObj];

    XCTAssertTrue(_topThing.ready);
    id object = _topThing.objectInstantiation.object;
    XCTAssertEqual(extObj, object);
}

@end
