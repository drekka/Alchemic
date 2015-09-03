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

-(void) watchResolvable:(id<ALCResolvable>) resolvable {
    [_watchedResolvables addObject:resolvable];

    // If the resolvable is not available then add a when available block to it.
    if (!resolvable.available) {

        blockSelf;
        [_whenAvailableBlocks addObject:^(id<ALCResolvable> availableResolvable) {
            [strongSelf->_watchedResolvables removeObject:availableResolvable];
            [strongSelf checkIfAvailable];
        }];
    }
}

-(BOOL) available {
    return [_whenAvailableBlocks count] == 0;
}

-(void) checkIfAvailable {
    if (self.available) {
        [_whenAvailableBlocks enumerateObjectsUsingBlock:^(ALCResolvableAvailableBlock block, BOOL * stop) {
            block(self);
        }];
        _whenAvailableBlocks = nil;
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
