//
//  ALCResolver.m
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDependency.h"
#import "ALCLogger.h"
@import ObjectiveC;
#import "ALCMatcher.h"
#import "ALCResolvableObject.h"
#import "ALCDependencyPostProcessor.h"

@implementation ALCDependency

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
    
    _candidates = [[NSMutableSet alloc] init];
    [model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCResolvableObject *resolvableObject, BOOL *stop) {

        // Run matchers to see if they match. All must accept the candidate object.
        for (id<ALCMatcher> dependencyMatcher in _dependencyMatchers) {
            if (![dependencyMatcher matches:resolvableObject withName:name]) {
                return;
            }
        }
        [(NSMutableArray *)_candidates addObject:resolvableObject];
        
    }];

    logDependencyResolving(@"Found %lu candidates", [_candidates count]);

}

-(void) postProcess:(NSSet *) postProcessors {
    for (id<ALCDependencyPostProcessor> postProcessor in postProcessors) {
        NSSet *newCandiates = [postProcessor process:self];
        if (newCandiates != nil) {
            _candidates = newCandiates;
        }
    }
}

@end
