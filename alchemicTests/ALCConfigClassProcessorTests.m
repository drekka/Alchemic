//
//  ALCConfigClassProcessorTests.m
//  alchemic
//
//  Created by Derek Clarkson on 19/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
#import <OCMock/OCMock.h>

@interface ALCConfigClassProcessorTests : XCTestCase

@end

@implementation ALCConfigClassProcessorTests

-(void) testCanProcessorConfigClass {
    id mockConfig = OCMProtocolMock(@protocol(ALCConfig));
    ALCConfigClassProcessor *processor = [[ALCConfigClassProcessor alloc] init];
    XCTAssertTrue([processor canProcessClass:mockConfig]);
}


@end
