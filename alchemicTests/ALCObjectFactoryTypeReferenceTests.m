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

@interface ALCObjectFactoryTypeReferenceTests : XCTestCase

@end

@implementation ALCObjectFactoryTypeReferenceTests {
    ALCObjectFactoryTypeReference *_objectFactoryType;
}

-(void)setUp {
    _objectFactoryType = [[ALCObjectFactoryTypeReference alloc] init];
}

-(void) testObjectThrowsWhenNotReady {
    XCTAssertThrowsSpecific(_objectFactoryType.object, AlchemicReferenceObjectNotSetException, @"");
}

-(void) testObjectReturnsSetObject {
    _objectFactoryType.object = @"abc";
    XCTAssertEqualObjects(@"abc", _objectFactoryType.object);
}

-(void) testReadWhenObjectNotSet {
    XCTAssertFalse(_objectFactoryType.isReady);
}

-(void) testReadWhenObjectSet {
    _objectFactoryType.object = @"abc";
    XCTAssertTrue(_objectFactoryType.isReady);
}

-(void) testDescription {
    XCTAssertEqualObjects(@"Reference", _objectFactoryType.description);
}

@end
