//
//  ALCObjectFactoryTypeTemplateTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface ALCObjectFactoryTypeTemplateTests : XCTestCase
@end

@implementation ALCObjectFactoryTypeTemplateTests {
    ALCObjectFactoryTypeTemplate *_factoryType;
}

-(void) setUp {
    _factoryType = [[ALCObjectFactoryTypeTemplate alloc] init];
}

-(void) testWeakThrows {
    XCTAssertThrowsSpecific({_factoryType.weak = YES;}, AlchemicIllegalArgumentException);
}

-(void) testNillableThrows {
    XCTAssertThrowsSpecific({_factoryType.nillable = YES;}, AlchemicIllegalArgumentException);
}

-(void) testReadyAlwaysYes {
    XCTAssertTrue(_factoryType.isReady);
}

-(void) testSetObjectDoesNothing {
    _factoryType.object = @"abc";
    XCTAssertNil(_factoryType.object);
}

-(void) testDescription {
    XCTAssertEqualObjects(@"Template", _factoryType.description);
}


@end
