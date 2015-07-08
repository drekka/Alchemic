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
    [STStoryTeller storyTeller].logger.showKey = NO;
    ((STConsoleLogger *)[STStoryTeller storyTeller].logger).addXcodeColours = YES;
    ((STConsoleLogger *)[STStoryTeller storyTeller].logger).messageColour = [UIColor redColor];
    ((STConsoleLogger *)[STStoryTeller storyTeller].logger).lineDetailsColour = [UIColor colorWithRed:0.3 green:0.8 blue:0.8 alpha:1.0];
}

-(void) tearDown {
    // Stop the mocking.
    _mockAlchemic = nil;
    [[STStoryTeller storyTeller] reset];
}

-(void) setUpALCContextWithClasses:(NSArray<Class> __nonnull *) classes {

    // Set context up with minimal objects from runtime.
    _context = [[ALCContext alloc] init];
    _mockAlchemic = OCMClassMock([ALCAlchemic class]);
    OCMStub(ClassMethod([_mockAlchemic mainContext])).andReturn(_context);

    NSSet<ALCRuntimeScanner *> *scanners = [NSSet setWithArray:@[
                                                                 //[ALCRuntimeScanner modelScanner],
                                                                 [ALCRuntimeScanner dependencyPostProcessorScanner],
                                                                 [ALCRuntimeScanner objectFactoryScanner],
                                                                 //[ALCRuntimeScanner initStrategyScanner],
                                                                 [ALCRuntimeScanner resourceLocatorScanner]
                                                                 ]];
    [ALCRuntime scanRuntimeWithContext:_context runtimeScanners:scanners];

    ALCRuntimeScanner *modelScanner = [ALCRuntimeScanner modelScanner];
    [classes enumerateObjectsUsingBlock:^(Class  __nonnull aClass, NSUInteger idx, BOOL * __nonnull stop) {
        modelScanner.processor(self.context, aClass);
    }];
    
    [_context start];

}

@end
