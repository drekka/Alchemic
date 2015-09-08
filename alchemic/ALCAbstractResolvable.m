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
    NSMutableSet<id<ALCResolvable>> *_dependenciesNotAvailable;
    BOOL _resolved;
}

@synthesize dependencies = _dependencies;
@synthesize available = _available;

-(instancetype) init {
    self = [super init];
    if (self) {
        _whenAvailableBlocks = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Setting up

-(void) addDependency:(id<ALCResolvable>)resolvable {

    if (_resolved) {
        @throw [NSException exceptionWithName:@"AlchemicResolved"
                                       reason:@"Cannot add dependencies after resolving."
                                     userInfo:nil];
    }

    // Store the dependency.
    if (_dependencies == nil) {
        _dependencies = [NSMutableSet set];
        _dependenciesNotAvailable = [NSMutableSet set];
    }
    [(NSMutableSet *) _dependencies addObject:resolvable];

    // If the resolvable is not available then add a when available block to it.
    // If it's already available we don't do anything.
    if (!resolvable.available) {
        [_dependenciesNotAvailable addObject:resolvable];
        blockSelf;
        [(ALCAbstractResolvable *)resolvable executeWhenAvailable:^(id<ALCResolvable> availableResolvable) {
            [strongSelf->_dependenciesNotAvailable removeObject:availableResolvable];
            [strongSelf checkIfAvailable];
        }];
    }
}

-(void) executeWhenAvailable:(ALCResolvableAvailableBlock) whenAvailableBlock {
    if (_whenAvailableBlocks == nil) {
        whenAvailableBlock(self);
    } else {
        [_whenAvailableBlocks addObject:whenAvailableBlock];
    }
}

#pragma mark - Checking availability

-(void) checkIfAvailable {

    if (!_resolved) {
        @throw [NSException exceptionWithName:@"AlchemicNotResolved"
                                       reason:@"Cannot check availability when resolving has not occurred."
                                     userInfo:nil];
    }

    // Loop through the list of unavailable dependencies we are still waiting on and check to see if we are unavailable because one or more of them form a loop.
    _available = YES;
    for (ALCAbstractResolvable *resolvable in _dependenciesNotAvailable) {
        _available = [resolvable checkAvailabilityWithInProgress:[NSMutableSet setWithObject:self]];
        if (!_available) {
            return;
        }
    }

    // All previously unavailable dependecies are now available.
    STLog(ALCHEMIC_LOG, @"Resolvable is available, calling %lu when available blocks", [_whenAvailableBlocks count]);

    // Copy the blocks to a seperate set for processing.
    // Otherwise we can get into a loop when there are circular dependencies.
    NSMutableSet<ALCResolvableAvailableBlock> *blocks = _whenAvailableBlocks;
    _whenAvailableBlocks = nil;
    _dependenciesNotAvailable = nil;

    // Call the when available blocks.
    [blocks enumerateObjectsUsingBlock:^(ALCResolvableAvailableBlock block, BOOL * stop) {
        block(self);
    }];

    [self didBecomeAvailable];
}

-(BOOL) checkAvailabilityWithInProgress:(NSMutableSet<id<ALCResolvable>> *) inProgress {

    // If we are in the in progress set then we are regarded as available.
    if ([inProgress containsObject:self]) {
        return YES;
    }

    // If any of the resolvables dependencies say no, then return NO.
    for (ALCAbstractResolvable *resolvable in _dependenciesNotAvailable) {
        [inProgress addObject:self];
        if (![resolvable checkAvailabilityWithInProgress:inProgress]) {
            return NO;
        }
        [inProgress removeObject:self];
    }

    // Otherwise 
    return YES;
}

-(void) didBecomeAvailable {}

#pragma mark - Resolving

-(void) resolve {
    [self resolveWithDependencyStack:[NSMutableArray array]];
}

-(void) resolveWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {

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
        return;
    }

    // Call the override method.
    [self willResolve];

    // Flag that we are resolved so we can abort endless resolution loops.
    _resolved = YES;

    // If there is nothing to resolve then just exit.
    if ([_dependencies count] > 0) {
        // Resolve any resolvables we are dependant on.
        for (ALCAbstractResolvable *resolvable in _dependencies) {
            [resolvable resolveWithDependencyStack:dependencyStack];
        }
    }

    // Call the override point.
    [self didResolve];

    // Check if we can become available.
    [self checkIfAvailable];
}

-(void) willResolve {}

-(void) didResolve {}

@end
