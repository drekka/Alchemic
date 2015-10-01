//
//  ALCIsPrimaryTests.m
//  alchemic
//
//  Created by Derek Clarkson on 30/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCIsPrimary.h"

@interface ALCIsPrimaryTests : XCTestCase

@end

@implementation ALCIsPrimaryTests

-(void) testSingeletonIsSingleton {
    XCTAssertEqual([ALCIsPrimary primaryMacro], [ALCIsPrimary primaryMacro]);
}

-(void) testSingeletonEqualsAllocInit {
    XCTAssertEqual([ALCIsPrimary primaryMacro], [[ALCIsPrimary alloc] init]);
}

@end
