//
//  ALCPrimaryObjectPostProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCPrimaryObjectDependencyPostProcessor.h"
#import "ALCDependency.h"
#import "ALCBuilder.h"

@implementation ALCPrimaryObjectDependencyPostProcessor

-(NSSet *) process:(NSSet *) dependencies {

    // Build a list of primary objects.
    NSMutableSet *primaries = [[NSMutableSet alloc] init];
    for (id<ALCBuilder> candidateBuilder in dependencies) {
        if (candidateBuilder.primary) {
            [primaries addObject:candidateBuilder];
        }
    }
    
    // Replace the list if primaries are present.
    return [primaries count] > 0 ? primaries : dependencies;
}

@end
