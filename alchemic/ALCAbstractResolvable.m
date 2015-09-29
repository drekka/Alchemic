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
    NSMutableSet<ALCDependencyReadyBlock> *_whenCanInjectBlocks;
}

@synthesize resolved = _resolved;
@synthesize dependencies = _dependencies;
@synthesize ready = _ready;
@synthesize startsResolvingStack = _startsResolvingStack;

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
    }
    [(NSMutableSet *) _dependencies addObject:resolvable];
}

-(void) whenReadyDo:(ALCDependencyReadyBlock) block {

    if (_ready) {
        @throw [NSException exceptionWithName:@"AlchemicAlreadyCanInject"
                                       reason:@"Builder is already ready to instantiate. Cannot add when ready to inject block."
                                     userInfo:nil];
    }

    if (_whenCanInjectBlocks == nil) {
        _whenCanInjectBlocks = [NSMutableSet set];
    }
    [_whenCanInjectBlocks addObject:block];
}

#pragma mark - Injection status

-(BOOL) setInitialStatus {

    return [self checkStatusUsingBlock:^BOOL(ALCAbstractResolvable *dependency) {

        // If the dependeny cannot inject then get it to tell us when it can inject.
        if ( ! [dependency setInitialStatus]) {
            [dependency whenReadyDo:^(ALCDependencyReadyBlockArgs) {
                [self checkStatus];
            }];
            return NO;
        }
        return YES;
    }];
}

-(BOOL) checkStatus {

    if ([self checkStatusUsingBlock:^BOOL(ALCAbstractResolvable *dependency) {
        return [dependency checkStatus];
    }]) {
        // Resolvable can inject. If there are blocks, execute them. This will resolve out to nils if there are none
        [self resolvableIsNowReady];
    }
    return self.ready;
}

-(void) resolvableIsNowReady {

    // Copy the blocks to a seperate set for processing.
    // Otherwise we can get into a loop when there are circular dependencies.
    NSMutableSet<ALCDependencyReadyBlock> *blocks = _whenCanInjectBlocks;
    _whenCanInjectBlocks = nil;

    // Call the blocks.
    [blocks enumerateObjectsUsingBlock:^(ALCDependencyReadyBlock dependencyReadyBlock, BOOL * stop) {
        dependencyReadyBlock(self);
    }];

    [self instantiate];
}

-(BOOL) checkStatusUsingBlock:(BOOL (^)(ALCAbstractResolvable *dependency)) canDependencyInjectBlock {

    // If we can already inject or we are being resolved then say we can inject.
    if (self.ready) {
        return YES;
    }

    // Set this dependency as available so a loop back in the dependencies will not cause an endless loop.
    _ready = YES;

    // Check all dependencies with the block and switch to NO if any are not ready.
    BOOL dependenciesCanInject = YES;
    for (ALCAbstractResolvable *dependency in _dependencies) {
        dependenciesCanInject = canDependencyInjectBlock(dependency) ? dependenciesCanInject : NO;
    }

    _ready = dependenciesCanInject;
    return self.ready;
}

#pragma mark - Instantiating

-(void) instantiate {}

#pragma mark - Resolving

-(void) resolve {
    STLog(ALCHEMIC_LOG, @"Initiating resolve ...");
    [self resolveWithDependencyStack:[NSMutableArray array]];
    if ([self setInitialStatus]) {
        [self instantiate];
    }
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
    STLog(ALCHEMIC_LOG, @"Resolving %@", self);
    [self willResolve];

    // Flag that we are resolved so we can abort endless resolution loops.
    _resolved = YES;

    // Resolve dependencies
    if ([_dependencies count] > 0) {
        // If this resolvable is set to start a new stand, then do so, otherwise continue with the current state.
        NSMutableArray *stack = self.startsResolvingStack ? [NSMutableArray array] : dependencyStack;
        [stack addObject:self];
        STLog(ALCHEMIC_LOG, @"Resolving %lu dependencies for %@", [_dependencies count], self);
        for (ALCAbstractResolvable *resolvable in _dependencies) {
            [resolvable resolveWithDependencyStack:stack];
        }
        [stack removeObject:self];
    }

    // Call the override point.
    [self didResolve];
}

-(void) willResolve {}

-(void) didResolve {}

@end
