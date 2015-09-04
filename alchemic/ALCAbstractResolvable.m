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
    NSMutableSet<id<ALCResolvable>> *_pendingResolvables;
    BOOL _resolved;
}

#pragma mark - Lifecycle

-(instancetype)init {
    self = [super init];
    if (self) {
        _pendingResolvables = [NSMutableSet set];
        _whenAvailableBlocks = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Setting up

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
        [_pendingResolvables addObject:resolvable];
        blockSelf;
        [resolvable executeWhenAvailable:^(id<ALCResolvable> availableResolvable) {
            [strongSelf->_pendingResolvables removeObject:availableResolvable];
            [strongSelf checkIfAvailable];
        }];
    }
}

#pragma mark - Starting

-(BOOL) available {
    return _resolved && [_pendingResolvables count] == 0;
}

-(void) checkIfAvailable {

    // If the pending resolvables list is nil then we are already available.
    if (_pendingResolvables == nil) {
        return;
    }

    STLog(ALCHEMIC_LOG, @"checking if %@ can become available ...", self);

    // If any of the pending resolvables are not part of a loop back to this one then we cannot become available.
    for (ALCAbstractResolvable *resolvable in _pendingResolvables) {
        if (! [resolvable canBecomeAvailableWithInitiatingResolvable:self]) {
            return;
        }
    }

    // If we are here then we can become available.
    STLog(ALCHEMIC_LOG, @"Resolvable is available, calling %lu when available blocks", [_whenAvailableBlocks count]);

    // Copy the set so that circular resolving doesn't go into a loop and clear memory.
    NSSet<ALCResolvableAvailableBlock> *blocks = _whenAvailableBlocks;
    _whenAvailableBlocks = nil;
    _pendingResolvables = nil; // This indicates that the resolvable has run this code. See above.

    // Call the when available blocks and the override method.
    [blocks enumerateObjectsUsingBlock:^(ALCResolvableAvailableBlock block, BOOL * stop) {
        block(self);
    }];
    [self didBecomeAvailable];
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
        return;
    }

    // Flag that we are resolved so we can abort endless resolution loops.
    _resolved = YES;

    // Resolve any resolvables we are dependant on.
    [self resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];

    // Check if we can become available.
    [self checkIfAvailable];
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                              dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {}

-(BOOL) canBecomeAvailableWithInitiatingResolvable:(ALCAbstractResolvable *) originatingResolvable {

    // IF we have arrived back to the original then there is a loop of
    // pending resolvables and we can allow this one to become available.
    if (originatingResolvable == self) {
        return YES;
    }

    // Now continue testing.
    // If any of the pending resolvables report NO then there are dependencies
    // which are not cused by a loop and not available at this time.
    for (ALCAbstractResolvable *resolvable in _pendingResolvables) {
        if (! [resolvable canBecomeAvailableWithInitiatingResolvable:originatingResolvable]) {
            return NO;
        }
    }

    // There are no further pending resolvables from here and this one is not available for some reason so say NO.
    return NO;
    
}

@end
