//
//  ALCPrimaryObjectPostProcessor.m
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCPrimaryObjectPostProcessor.h"
#import "ALCDependencyResolver.h"
#import "ALCModelObject.h"

@implementation ALCPrimaryObjectPostProcessor

-(NSSet *) process:(ALCDependencyResolver *) resolver {
    
    // Build a list of primary objects.
    NSMutableSet *primaryInstances = [[NSMutableSet alloc] init];
    for (id<ALCModelObject> candidateInstance in resolver.candidateInstances) {
        if (candidateInstance.primary) {
            [primaryInstances addObject:candidateInstance];
        }
    }
    
    // Replace the list if primaries are present.
    return [primaryInstances count] > 0 ? primaryInstances : nil;
}

@end
