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
    ALCType *type = [ALCType typeForClass:[self class] injection:class_getInstanceVariable([self class], "_idVar")];
    XCTAssertEqual(type.forClass, NULL);
    XCTAssertEqual(0u, [type.withProtocols count]);
}

-(void) testTypeForInjectionClassProperty {
    ALCType *type = [ALCType typeForClass:[self class] injection:class_getInstanceVariable([self class], "_stringVar")];
    XCTAssertEqual(type.forClass, [NSString class]);
    XCTAssertEqual(0u, [type.withProtocols count]);
}

-(void) testTypeForInjectionProtocolProperty {
    ALCType *type = [ALCType typeForClass:[self class] injection:class_getInstanceVariable([self class], "_protocolVar")];
    XCTAssertEqual(type.forClass, NULL);
    XCTAssertEqual(2u, [type.withProtocols count]);
    XCTAssertTrue([type.withProtocols containsObject:@protocol(NSCopying)]);
    XCTAssertTrue([type.withProtocols containsObject:@protocol(NSFastEnumeration)]);
}

@end
