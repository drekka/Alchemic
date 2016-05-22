//
//  ALCConfigClassProcessorTests.m
//  alchemic
//
//  Created by Derek Clarkson on 19/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;
@import XCTest;
@import Alchemic;
@import Alchemic.Private;

#import <OCMock/OCMock.h>

@interface ALCConfigClassProcessorTests : XCTestCase<ALCConfig>

@end

@implementation ALCConfigClassProcessorTests {
    ALCConfigClassProcessor *_processor;
}

-(void) setUp {
    _processor = [[ALCConfigClassProcessor alloc] init];
}

-(void) testCanProcessorConfigClass {
    XCTAssertTrue([_processor canProcessClass:[self class]]);
}

-(void) testCanProcessorIgnoresOtherClass {
    XCTAssertFalse([_processor canProcessClass:[NSString class]]);
}

-(void) testProcessClassWithContext {
    id mockContext = OCMProtocolMock(@protocol(ALCContext));
    [_processor processClass:[self class] withContext:mockContext];
}

+(nullable NSArray<Class> *) scanBundlesWithClasses {
    return nil;
}

@end
