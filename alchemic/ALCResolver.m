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
        
        // Run matchers to see if they match. All must accept the candidate object.
        BOOL matched = YES;
        for (id<ALCMatcher> dependencyMatcher in _dependencyMatchers) {
            if (![dependencyMatcher matches:instance withName:name]) {
                matched = NO;
                break;
            }
        }
        
        if (matched) {
            logDependencyResolving(@"Adding '%@' %s to candidates", name, class_getName(instance.forClass));
            [(NSMutableArray *)_candidateInstances addObject:instance];
        }
        
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
