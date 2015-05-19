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
#import "ALCModelObjectInstance.h"
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
    
    _candidateInstances = [[NSMutableSet alloc] init];
    [model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCModelObjectInstance *instance, BOOL *stop) {

        // Run matchers to see if they match. All must accept the candidate object.
        for (id<ALCMatcher> dependencyMatcher in _dependencyMatchers) {
            if (![dependencyMatcher matches:instance withName:name]) {
                return;
            }
        }
        [(NSMutableArray *)_candidateInstances addObject:instance];
        
    }];

    logDependencyResolving(@"Found %lu candidates", [_candidateInstances count]);

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
