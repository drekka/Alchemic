//
//  ALCModelObjectInjectorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

#import "XCTestCase+Alchemic.h"

@interface ALCModelObjectInjectorTests : XCTestCase

@end

@implementation ALCModelObjectInjectorTests {
    ALCModelObjectInjector *_injector;
}

-(void)setUp {
    _injector = [[ALCModelObjectInjector alloc] initWithObjectClass:[NSString class] criteria:AcClass(NSString)];
}

-(void) testInitWithObjectClassCriteria {
    XCTAssertEqual([NSString class], _injector.objectClass);
    ALCModelSearchCriteria *injCriteria = _injector.criteria;
    XCTAssertEqualObjects(@"class NSString", injCriteria.description);
}

-(void) testIsReadyWhenFactoriesReady {
    id<ALCObjectFactory> factory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([factory isReady]).andReturn(YES);

    [self setVariable:@"_resolvedFactories" inObject:_injector value:@[factory]];

    XCTAssertTrue(_injector.isReady);
}

-(void) testIsReadyWhenFactoriesNotReady {
    id<ALCObjectFactory> factory = OCMProtocolMock(@protocol(ALCObjectFactory));
    OCMStub([factory isReady]).andReturn(NO);

    [self setVariable:@"_resolvedFactories" inObject:_injector value:@[factory]];

    XCTAssertFalse(_injector.isReady);
}

-(void) testIsReadyWhenNoFactories {
    [self setVariable:@"_resolvedFactories" inObject:_injector value:@[]];
    XCTAssertFalse(_injector.isReady);
}

-(void) testResolveWithStackModel {
    
}


@end
