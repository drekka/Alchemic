//
//  ALCIsExternalTests.m
//  alchemic
//
//  Created by Derek Clarkson on 30/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCIsExternal.h"

@interface ALCIsExternalTests : XCTestCase

@end

@implementation ALCIsExternalTests

-(void) testSingeletonIsSingleton {
    XCTAssertEqual([ALCIsExternal externalMacro], [ALCIsExternal externalMacro]);
}

-(void) testSingeletonEqualsAllocInit {
    XCTAssertEqual([ALCIsExternal externalMacro], [[ALCIsExternal alloc] init]);
}

@end
