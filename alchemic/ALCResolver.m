//
//  ALCResolver.m
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCResolver.h"
#import "ALCLogger.h"
@import ObjectiveC;
#import "ALCMatcher.h"
#import "ALCInstance.h"
#import "ALCResolverPostProcessor.h"

@implementation ALCResolver

-(instancetype) initWithMatcher:(id<ALCMatcher>) dependencyMatcher {
    return [self initWithMatchers:[NSSet setWithObject:dependencyMatcher]];
}

-(instancetype) initWithMatchers:(NSSet *) dependencyMatchers {
    self = [super init];
    if (self) {
        _dependencyMatchers = dependencyMatchers;
        _candidateInstances = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void) resolveUsingModel:(NSDictionary *)model {
    
    if ([_candidateInstances count] > 0) {
        logDependencyResolving(@"Dependency previously resolved");
        return;
    }
    
    logDependencyResolving(@"Searching for candidates using %lu model objects", [model count]);
    [model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *instance, BOOL *stop) {

        // Don't bother adding if already present.
        if ([_candidateInstances containsObject:instance]) {
            return;
        }

        // Run matchers to see if they match. All must accept the candidate object.
        for (id<ALCMatcher> dependencyMatcher in _dependencyMatchers) {
            if (![dependencyMatcher matches:instance withName:name]) {
                return;
            }
        }
        
        logDependencyResolving(@"Adding '%@' %s to candidates", name, class_getName(instance.objectClass));
        [(NSMutableArray *)_candidateInstances addObject:instance];
        
    }];
    
}

-(void) postProcess:(NSSet *) postProcessors {
    for (id<ALCResolverPostProcessor> postProcessor in postProcessors) {
        NSSet *newCandiates = [postProcessor process:self];
        if (newCandiates != nil) {
            _candidateInstances = newCandiates;
        }
    }
}

@end
