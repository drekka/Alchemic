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
@property (nonatomic, assign) id idVar;
@end

@implementation ALCTypeTests

-(void) testTypeForInjectionInClassIdProperty {
    ALCType *type = [ALCType typeForInjection:class_getInstanceVariable([self class], "idVar")
                                      inClass:[self class]];
    XCTAssertEqual(type.typeClass, NULL);
}

@end
