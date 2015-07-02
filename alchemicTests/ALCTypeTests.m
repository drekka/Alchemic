//
//  ALCTypeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 2/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCType.h"

@interface ALCTypeTests : XCTestCase
@property (nonatomic, strong) id idVar;
@property (nonatomic, strong) NSString *stringVar;
@property (nonatomic, strong) id<NSFastEnumeration, NSCopying> protocolVar;
@end

@implementation ALCTypeTests

-(void) testTypeForInjectionIdProperty {
    ALCType *type = [ALCType typeForInjection:class_getInstanceVariable([self class], "_idVar")
                                      inClass:[self class]];
    XCTAssertEqual(type.typeClass, NULL);
    XCTAssertEqual(0u, [type.typeProtocols count]);
}

-(void) testTypeForInjectionClassProperty {
    ALCType *type = [ALCType typeForInjection:class_getInstanceVariable([self class], "_stringVar")
                                      inClass:[self class]];
    XCTAssertEqual(type.typeClass, [NSString class]);
    XCTAssertEqual(0u, [type.typeProtocols count]);
}

-(void) testTypeForInjectionProtocolProperty {
    ALCType *type = [ALCType typeForInjection:class_getInstanceVariable([self class], "_protocolVar")
                                      inClass:[self class]];
    XCTAssertEqual(type.typeClass, NULL);
    XCTAssertEqual(2u, [type.typeProtocols count]);
    XCTAssertTrue([type.typeProtocols containsObject:@protocol(NSCopying)]);
    XCTAssertTrue([type.typeProtocols containsObject:@protocol(NSFastEnumeration)]);
}

@end
