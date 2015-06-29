//
//  ALCTestCase.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "Alchemic.h"
#import <StoryTeller/StoryTeller.h>
#import <StoryTeller/STLogger.h>

@implementation ALCTestCase

+(void)load {
    [StoryTeller storyTeller].logAll = YES;
    [StoryTeller storyTeller].logger.showMethodDetails = NO;
    [StoryTeller storyTeller].logger.showTime = NO;
    [StoryTeller storyTeller].logger.showThreadId = NO;
    [StoryTeller storyTeller].logger.showKey = YES;
}

- (void)setUp {
    injectDependencies(self);
}

@end
