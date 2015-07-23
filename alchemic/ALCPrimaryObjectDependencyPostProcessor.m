//
//  ALCPrimaryObjectPostProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCPrimaryObjectDependencyPostProcessor.h"
#import <Alchemic/ALCBuilder.h>
#import <Alchemic/ALCInternalMacros.h>
#import <StoryTeller/StoryTeller.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCPrimaryObjectDependencyPostProcessor

-(NSSet<id<ALCBuilder>> *) process:(NSSet<id<ALCBuilder>> *) dependencies {

    // Build a list of primary objects.
    NSMutableSet<id<ALCBuilder>> *primaries = [[NSMutableSet alloc] init];
    for (id<ALCBuilder> candidateBuilder in dependencies) {
        if (candidateBuilder.primary) {
            [primaries addObject:candidateBuilder];
        }
    }
    
    // Replace the list if primaries are present.
    STLog(ALCHEMIC_LOG, @"Primary objects %@", [primaries count] > 0 ? @"detected": @"not found");
    return [primaries count] > 0 ? primaries : dependencies;
}

@end

NS_ASSUME_NONNULL_END