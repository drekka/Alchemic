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
    BOOL _resolved;
}

@synthesize dependencies = _dependencies;
@synthesize ready = _ready;
@synthesize startsResolvingStack = _startsResolvingStack;

#pragma mark - Setting up

- (void)addDependency:(id<ALCResolvable>)resolvable {
    if (_resolved) {
        @throw [NSException exceptionWithName:@"AlchemicResolved" reason:@"Cannot add dependencies after resolving." userInfo:nil];
    }

    // Store the dependency.
    if (_dependencies == nil) {
        _dependencies = [NSMutableSet set];
    }
    [(NSMutableSet *)_dependencies addObject:resolvable];
}

#pragma mark - Instantiating

-(BOOL)ready {

    if (!_resolved) {
        return NO;
    }

    if (_ready) {
        return YES;
    }

    // Assume ready for purposes of stopped circular ready checking.
    _ready = YES;

    for (id<ALCResolvable> resolvable in _dependencies) {
        if (!resolvable.ready) {
            _ready = NO;
            break;
        }
    }
    return _ready;
}

- (void)instantiate {}

#pragma mark - Resolving

- (void)resolve {
    STLog(ALCHEMIC_LOG, @"Initiating resolve ...");
    [self resolveWithDependencyStack:[NSMutableArray array]];

    // If we are ready, then instantiate.
    if (self.ready) {
        [self instantiate];
    }
}

- (void)resolveWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {
    // Check for circular dependencies first.
    if ([dependencyStack containsObject:self]) {

        [dependencyStack addObject:self];
        @throw [NSException
                exceptionWithName:@"AlchemicCircularDependency"
                reason:[NSString stringWithFormat:@"Circular dependency detected: %@", [dependencyStack componentsJoinedByString:@" -> "]]
                userInfo:nil];
    }

    if (_resolved) {
        STLog(ALCHEMIC_LOG, @"Previously resolved");
        return;
    }

    // Call the override method.
    STLog(ALCHEMIC_LOG, @"Resolving %@", self);
    [self willResolve];

    // Flag that we are resolved so we can abort endless resolution loops.
    _resolved = YES;

    // Resolve dependencies
    if ([_dependencies count] > 0) {

        // If this resolvable is set to start a new stand, then do so, otherwise
        // continue with the current state.
        NSMutableArray *stack = self.startsResolvingStack ? [NSMutableArray array] : dependencyStack;

        [stack addObject:self];
        STLog(ALCHEMIC_LOG, @"Resolving %lu dependencies for %@", [_dependencies count], self);
        for (ALCAbstractResolvable *resolvable in _dependencies) {
            [resolvable resolveWithDependencyStack:stack];
        }
        [stack removeObject:self];
    }

}

- (void)willResolve {}

@end
