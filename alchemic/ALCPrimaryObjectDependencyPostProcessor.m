//
//  ALCPrimaryObjectPostProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCPrimaryObjectDependencyPostProcessor.h"
#import "ALCDependency.h"
#import "ALCResolvable.h"

@implementation ALCPrimaryObjectDependencyPostProcessor

-(NSSet *) process:(ALCDependency *) resolver {
    
    // Build a list of primary objects.
    NSMutableSet *primaries = [[NSMutableSet alloc] init];
    for (id<ALCResolvable> candidateResolvable in resolver.candidates) {
        if (candidateResolvable.primary) {
            [primaries addObject:candidateResolvable];
        }
    }
    
    // Replace the list if primaries are present.
    return [primaries count] > 0 ? primaries : nil;
}

@end
