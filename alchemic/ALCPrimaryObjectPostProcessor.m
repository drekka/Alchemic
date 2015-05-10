//
//  ALCPrimaryObjectPostProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCPrimaryObjectPostProcessor.h"
#import "ALCResolver.h"
#import "ALCObjectMetadata.h"
#import "ALCLogger.h"

@implementation ALCPrimaryObjectPostProcessor

-(NSSet *) process:(ALCResolver *) resolver {
    
    // Build a list of primary objects.
    NSMutableSet *primaryInstances = [[NSMutableSet alloc] init];
    for (id<ALCObjectMetadata> candidateInstance in resolver.candidateInstances) {
        if (candidateInstance.primary) {
            [primaryInstances addObject:candidateInstance];
        }
    }
    
    // Replace the list if primaries are present.
    logDependencyResolving(@"Found %lu primary objects", [primaryInstances count]);
    return [primaryInstances count] > 0 ? primaryInstances : nil;
}

@end
