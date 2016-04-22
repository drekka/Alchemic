//
//  ReferenceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "Alchemic.h"
#import "ALCContextImpl.h"
#import "ALCClassObjectFactory.h"
#import "ALCIsReference.h"

#import "TopThing.h"
#import "NestedThing.h"

@interface ExternalReferences : XCTestCase
@end

@implementation ExternalReferences {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThing;
}

-(void)setUp {
    _context = [[ALCContextImpl alloc] init];
    _topThing = [_context registerObjectFactoryForClass:[TopThing class]];
    [_topThing configureWithOptions:@[[ALCIsReference referenceMacro]]];
}

-(void) testTopReferenceTypeInitiation {

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

    [_context start];

    id extObj = [[TopThing alloc] init];
    [_topThing setObject:extObj];

    XCTAssertTrue(_topThing.ready);
    id object = _topThing.objectInstantiation.object;
    XCTAssertEqual(extObj, object);
}

@end
