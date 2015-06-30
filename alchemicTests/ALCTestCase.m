//
//  ALCTestCase.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>

#import <StoryTeller/StoryTeller.h>

@implementation ALCTestCase

+(void)load {
    [STStoryTeller storyTeller].logger.showMethodDetails = NO;
    [STStoryTeller storyTeller].logger.showTime = NO;
    [STStoryTeller storyTeller].logger.showThreadId = NO;
    [STStoryTeller storyTeller].logger.showKey = YES;
}

- (void)setUp {
    ACInjectDependencies(self);
}

@end
