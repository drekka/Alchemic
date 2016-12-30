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
@import OCMock;

@interface ALCObjectFactoryTypeSingletonTests : XCTestCase

@end

@implementation ALCObjectFactoryTypeSingletonTests {
    ALCObjectFactoryTypeSingleton *_objectFactoryType;
    id _mockObjectFactory;
}

-(void)setUp {
    _mockObjectFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    _objectFactoryType = [[ALCObjectFactoryTypeSingleton alloc] initWithFactory:_mockObjectFactory];
}

-(void) testReady {
    XCTAssertTrue(_objectFactoryType.isReady);
}

-(void) testDescription {
    _objectFactoryType.nillable = YES;
    XCTAssertEqualObjects(@"S  N ", _objectFactoryType.description);
}

@end
