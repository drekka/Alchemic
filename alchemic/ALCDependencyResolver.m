//
//  ALCResolver.m
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDependencyResolver.h"
#import "ALCLogger.h"
@import ObjectiveC;
#import "ALCMatcher.h"
#import "ALCObjectInstance.h"
#import "ALCResolverPostProcessor.h"

@implementation ALCDependencyResolver

-(instancetype) initWithMatcher:(id<ALCMatcher>) dependencyMatcher {
    return [self initWithMatchers:[NSSet setWithObject:dependencyMatcher]];
}

-(instancetype) initWithMatchers:(NSSet *) dependencyMatchers {
    self = [super init];
    if (self) {
        _dependencyMatchers = dependencyMatchers;
    }
    return self;
}

-(void) resolveUsingModel:(NSDictionary *)model {
    
    logDependencyResolving(@"Searching for candidates using %lu model objects", [model count]);
    _candidateInstances = [[NSMutableSet alloc] init];
    [model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectInstance *instance, BOOL *stop) {

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
    for (id<ALCDependencyResolverPostProcessor> postProcessor in postProcessors) {
        NSSet *newCandiates = [postProcessor process:self];
        if (newCandiates != nil) {
            _candidateInstances = newCandiates;
        }
    }
}

@end
