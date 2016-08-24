//
//  ALCAspectClassProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface ALCAspectClassProcessorTests : XCTestCase

@end

@implementation ALCAspectClassProcessorTests {
    ALCAspectClassProcessor *_processor;
}

-(void)setUp {
    _processor = [[ALCAspectClassProcessor alloc] init];

}

-(void) testCanProcessClassFindsAspect {
    XCTAssertTrue([_processor canProcessClass:[ALCUserDefaultsAspect class]]);
}

-(void) testCanProcessClassWhenNotAnAspect {
    XCTAssertFalse([_processor canProcessClass:[NSObject class]]);
}

-(void) testProcessClassWithContextAddsAspect {
    id mockContext = OCMProtocolMock(@protocol(ALCContext));
    OCMExpect([mockContext addResolveAspect:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isKindOfClass:[ALCUserDefaultsAspect class]];
    }]]);
    
    [_processor processClass:[ALCUserDefaultsAspect class] withContext:mockContext];
    
    OCMVerifyAll(mockContext);
}

@end
