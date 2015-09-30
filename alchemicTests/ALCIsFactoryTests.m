//
//  ALCIsFactoryTests.m
//  alchemic
//
//  Created by Derek Clarkson on 30/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCIsFactory.h"

@interface ALCIsFactoryTests : XCTestCase

@end

@implementation ALCIsFactoryTests

-(void) testSingeletonIsSingleton {
    XCTAssertEqual([ALCIsFactory factoryMacro], [ALCIsFactory factoryMacro]);
}

-(void) testSingeletonEqualsAllocInit {
    XCTAssertEqual([ALCIsFactory factoryMacro], [[ALCIsFactory alloc] init]);
}

@end
