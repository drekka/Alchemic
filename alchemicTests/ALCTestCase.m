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
#import "ALCPrimaryObjectDependencyPostProcessor.h"
#import "ALCRuntime.h"
#import "ALCRuntimeScanner.h"

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

    // Set context up with minimal objects from runtime.
    _context = [[ALCContext alloc] init];
    NSSet<ALCRuntimeScanner *> *scanners = [NSSet setWithArray:@[
                                                                 //[ALCRuntimeScanner modelScanner],
                                                                 [ALCRuntimeScanner dependencyPostProcessorScanner],
                                                                 [ALCRuntimeScanner objectFactoryScanner],
                                                                 //[ALCRuntimeScanner initStrategyScanner],
                                                                 [ALCRuntimeScanner resourceLocatorScanner]
                                                                 ]];
    [ALCRuntime scanRuntimeWithContext:_context runtimeScanners:scanners];
    [_context start];

    _mockAlchemic = OCMClassMock([ALCAlchemic class]);
    OCMStub(ClassMethod([_mockAlchemic mainContext])).andReturn(_context);
}

-(void) scanClassIntoContext:(Class __nonnull) aClass {
    NSAssert(self.context != nil, @"Context must be setup first");
    STStartScope(aClass);
    ALCRuntimeScanner *modelScanner = [ALCRuntimeScanner modelScanner];
    modelScanner.processor(self.context, aClass);
}

@end
