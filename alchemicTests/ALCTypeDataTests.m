//
//  ALCDataTypeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 15/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface ALCTypeDataTests : XCTestCase

@end

@implementation ALCTypeDataTests

-(void) testDescriptionForScalar {
    ALCTypeData *type = [[ALCTypeData alloc] init];
    type.scalarType = "i";
    XCTAssertEqualObjects(@"Scalar i", type.description);
}

-(void) testDescriptionForClass {
    ALCTypeData *type = [[ALCTypeData alloc] init];
    type.objcClass = [NSString class];
    XCTAssertEqualObjects(@"NSString", type.description);
}

-(void) testDescriptionForClassWithProtocols {
    ALCTypeData *type = [[ALCTypeData alloc] init];
    type.objcClass = [NSString class];
    type.objcProtocols = @[@protocol(NSCopying), @protocol(NSObject)];
    XCTAssertEqualObjects(@"NSString<NSCopying,NSObject>", type.description);
}

-(void) testDescriptionForProtocols {
    ALCTypeData *type = [[ALCTypeData alloc] init];
    type.objcProtocols = @[@protocol(NSCopying)];
    XCTAssertEqualObjects(@"<NSCopying>", type.description);
}

@end
