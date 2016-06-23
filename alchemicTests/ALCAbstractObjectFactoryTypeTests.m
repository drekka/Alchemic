//
//  ALCAbstractObjectFactoryTypeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 21/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

@import Alchemic;
@import Alchemic.Private;

@interface ALCAbstractObjectFactoryTypeTests : XCTestCase

@end

@implementation ALCAbstractObjectFactoryTypeTests {
    ALCAbstractObjectFactoryType *_factoryType;
}

-(void)setUp {
    _factoryType = [[ALCAbstractObjectFactoryType alloc] init];
}

-(void) testFactoryType {
    XCTAssertEqual(ALCFactoryTypeSingleton, _factoryType.type);
}

-(void) testStrongObjectStorage {
    NSString *obj = @"abc";
    _factoryType.object = obj;
    NSString *returnedObj = _factoryType.object;
    XCTAssertEqual(obj, returnedObj);
}

-(void) testWeakObjectStorage {
    NSObject *obj = [[NSObject alloc] init];
    _factoryType.weak = YES;
    _factoryType.object = obj;
    obj = nil;
    NSObject *returnedObj = _factoryType.object;
    XCTAssertNil(returnedObj);
}

-(void) testReadThrows {
    @try {
        __unused BOOL ready = _factoryType.ready;
        XCTFail(@"Exception not thrown");
    }
    @catch (NSException *e) {
        XCTAssertEqualObjects(NSInvalidArgumentException, e.name);
    }
}

@end

