//
//  ALCTestCase.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <StoryTeller/StoryTeller.h>
#import "ALCTestCase.h"
#import "ALCModelClassProcessor.h"

@implementation ALCTestCase {
    id _mockAlchemic;
}

+(void)load {
    [STStoryTeller storyTeller].logger.showMethodDetails = YES;
    [STStoryTeller storyTeller].logger.showTime = NO;
    [STStoryTeller storyTeller].logger.showThreadId = NO;
    [STStoryTeller storyTeller].logger.showKey = YES;
}

-(void) setUp {
    [super setUp];
    ACInjectDependencies(self);
}

-(void) tearDown {
    // Stop the mocking.
    _mockAlchemic = nil;
}

-(void) setUpALCContext {
    _context = [[ALCContext alloc] init];
    _mockAlchemic = OCMClassMock([ALCAlchemic class]);
    OCMStub(ClassMethod([_mockAlchemic mainContext])).andReturn(_context);
}

-(void) scanClassIntoContext:(Class __nonnull) aClass {
    NSAssert(self.context != nil, @"Context must be setup first");
    STStartScope(aClass);
    ALCModelClassProcessor *classProcessor = [[ALCModelClassProcessor alloc] init];
    [classProcessor processClass:aClass withContext:self.context];
}

@end
