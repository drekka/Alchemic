//
//  ALCAbstractResolvable.m
//  alchemic
//
//  Created by Derek Clarkson on 2/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractResolvable.h"
#import "ALCInternalMacros.h"

#import <StoryTeller/StoryTeller.h>

@implementation ALCAbstractResolvable {
    NSMutableSet<ALCResolvableAvailableBlock> *_whenAvailableBlocks;
    NSMutableSet<id<ALCResolvable>> *_watchedResolvables;
    BOOL _resolved;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _watchedResolvables = [NSMutableSet set];
        _whenAvailableBlocks = [NSMutableSet set];
    }
    return self;
}

-(void) executeWhenAvailable:(ALCResolvableAvailableBlock) whenAvailableBlock {
    if (self.available) {
        whenAvailableBlock(self);
    } else {
        [_whenAvailableBlocks addObject:whenAvailableBlock];
    }
}

-(void) watchResolvable:(ALCAbstractResolvable *) resolvable {

    // If the resolvable is not available then add a when available block to it.
    // If it's already available we don't do anything.
    if (!resolvable.available) {
        [_watchedResolvables addObject:resolvable];
        blockSelf;
        [resolvable executeWhenAvailable:^(id<ALCResolvable> availableResolvable) {
            [strongSelf->_watchedResolvables removeObject:availableResolvable];
            [strongSelf checkIfAvailable];
        }];
    }
}

-(BOOL) available {
    return _resolved && [_watchedResolvables count] == 0;
}

-(void) checkIfAvailable {

    if (self.available) {

        // Copy the set so that circular resolving doesn't go into a loop.
        NSSet<ALCResolvableAvailableBlock> *blocks = _whenAvailableBlocks;

        // Clear memory.
        _whenAvailableBlocks = nil;
        _watchedResolvables = nil;

        // Now call the blocks.
        [blocks enumerateObjectsUsingBlock:^(ALCResolvableAvailableBlock block, BOOL * stop) {
            block(self);
        }];

        [self didBecomeAvailable];
    }
}

-(void) didBecomeAvailable {}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {

    // Check for circular dependencies first.
    if ([dependencyStack containsObject:self]) {
        [dependencyStack addObject:self];
        @throw [NSException exceptionWithName:@"AlchemicCircularDependency"
                                       reason:[NSString stringWithFormat:@"Circular dependency detected: %@",
                                               [dependencyStack componentsJoinedByString:@" -> "]]
                                     userInfo:nil];
    }

    if (_resolved) {
        STLog(ALCHEMIC_LOG, @"Previously resolved");
    } else {

        // Flag that we are resolved so we can abort endless resolution loops.
        _resolved = YES;

        // Resolve any resolvables we are dependant on.
        [self resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];

        // If we are now available then execute callbacks.
        [self checkIfAvailable];
    }
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                              dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {}


@end
