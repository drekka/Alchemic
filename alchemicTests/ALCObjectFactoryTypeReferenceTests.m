//
//  ALCObjectFactoryTypeReferenceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface ALCObjectFactoryTypeReferenceTests : XCTestCase

@end

@implementation ALCObjectFactoryTypeReferenceTests {
    ALCObjectFactoryTypeReference *_objectFactoryType;
    id _mockObjectFactory;
}

-(void)setUp {
    _mockObjectFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    _objectFactoryType = [[ALCObjectFactoryTypeReference alloc] initWithFactory:_mockObjectFactory];
}

-(void) testObjectIsNilWhenNotNillable {
    XCTAssertThrowsSpecific(_objectFactoryType.object, AlchemicReferenceObjectNotSetException);
}

-(void) testObjectIsNilWhenNillable {
    _objectFactoryType.nillable = YES;
    XCTAssertNil(_objectFactoryType.object);
}

-(void) testObjectReturnsSetObject {
    _objectFactoryType.object = @"abc";
    XCTAssertEqualObjects(@"abc", _objectFactoryType.object);
}

-(void) testReadyWhenObjectNotSet {
    XCTAssertFalse(_objectFactoryType.isReady);
}

-(void) testReadyWhenObjectNotSetAndNillable {
    _objectFactoryType.nillable = YES;
    XCTAssertTrue(_objectFactoryType.isReady);
}

-(void) testReadyWhenObjectSet {
    _objectFactoryType.object = @"abc";
    XCTAssertTrue(_objectFactoryType.isReady);
}

-(void) testDescription {
    XCTAssertEqualObjects(@" R   ", _objectFactoryType.description);
}

@end
