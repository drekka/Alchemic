//
//  ALCObjectFactoryTypeSingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface ALCObjectFactoryTypeSingletonTests : XCTestCase

@end

@implementation ALCObjectFactoryTypeSingletonTests {
    ALCObjectFactoryTypeSingleton *_objectFactoryType;
}

-(void)setUp {
    _objectFactoryType = [[ALCObjectFactoryTypeSingleton alloc] init];
}

-(void) testReady {
    XCTAssertTrue(_objectFactoryType.ready);
}

-(void) testDescription {
    XCTAssertEqualObjects(@"Singleton", _objectFactoryType.description);
}

@end
