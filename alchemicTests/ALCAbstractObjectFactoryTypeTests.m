//
//  ALCAbstractObjectFactoryTypeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 21/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import OCMock;

@import Alchemic;
@import Alchemic.Private;

@interface ALCAbstractObjectFactoryTypeTests : XCTestCase

@end

@implementation ALCAbstractObjectFactoryTypeTests {
    id _mockObjectFactory;
    ALCAbstractObjectFactoryType *_factoryType;
}

-(void)setUp {
    _mockObjectFactory = OCMProtocolMock(@protocol(ALCObjectFactory));
    _factoryType = [[ALCAbstractObjectFactoryType alloc] initWithFactory:_mockObjectFactory];
}

-(void) testFactoryType {
    XCTAssertEqual(ALCFactoryTypeSingleton, _factoryType.type);
}

-(void) testSetObjectStrong {
    NSString *obj = @"abc";
    _factoryType.object = obj;
    obj = nil;
    NSString *returnedObj = _factoryType.object;
    XCTAssertEqual(@"abc", returnedObj);
}

-(void) testSetObjectWeak {
    NSObject *obj = [[NSObject alloc] init];
    _factoryType.weak = YES;
    _factoryType.object = obj;
    obj = nil;
    NSObject *returnedObj = _factoryType.object;
    XCTAssertNil(returnedObj);
}

-(void) testSetObjectWhenNillableAndNil {
    _factoryType.nillable = YES;
    _factoryType.object = @"abc";
    XCTAssertEqualObjects(@"abc", _factoryType.object);
    _factoryType.object = nil;
    XCTAssertNil(_factoryType.object);
}

-(void) testSetObjectThrowsWhenNilAndNotNillable {
    XCTAssertThrowsSpecific({_factoryType.object = nil;}, AlchemicNilValueException);
}

-(void) testReadyThrows {
    XCTAssertThrowsSpecific((_factoryType.isReady), NSException);
}

-(void) testObjectPresentWhenNil {
    XCTAssertFalse(_factoryType.objectPresent);
}

-(void) testObjectPresent {
    _factoryType.object = @"abc";
    XCTAssertTrue(_factoryType.objectPresent);
}

-(void) testDescriptionWithType {
    XCTAssertEqualObjects(@"S    ", [_factoryType descriptionWithType:@"XXX"]);
}

-(void) testDescriptionWithTypeNillable {
    _factoryType.nillable = YES;
    XCTAssertEqualObjects(@"S  N ", [_factoryType descriptionWithType:@"XXX"]);
}

-(void) testDescriptionWithTypeWeak {
    _factoryType.weak = YES;
    XCTAssertEqualObjects(@"S   W", [_factoryType descriptionWithType:@"XXX"]);
}

-(void) testDescriptionThrows {
    XCTAssertThrowsSpecific((_factoryType.description), NSException);
}

@end

