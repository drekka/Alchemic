//
//  ALCModelValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCModelValueSource.h"
#import "ALCBuilder.h"
#import "ALCAlchemic.h"
#import "ALCContext.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCInternalMacros.h"
#import "NSSet+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Sources values from the model.
 */
@implementation ALCModelValueSource {
    NSSet<id<ALCBuilder>> *_candidateBuilders;
}

hideInitializerImpl(initWithType:(Class)argumentType)

-(instancetype) initWithType:(Class) argumentType
           searchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions {
    self = [super initWithType:argumentType];
    if (self) {
        _searchExpressions = searchExpressions;
        if ([searchExpressions count] == 0) {
            @throw [NSException exceptionWithName:@"AlchemicMissingSearchExpressions"
                                           reason:@"Cannot source values from the model if there are no search expressions to find them."
                                         userInfo:nil];
        }
    }
    return self;
}

-(NSSet<id> *) values {
    NSMutableSet<id> *results = [[NSMutableSet alloc] init];
    [_candidateBuilders enumerateObjectsUsingBlock:^(id<ALCBuilder> builder, BOOL * stop) {
        [results addObject:builder.value];
    }];
    return results;
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                              dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    // Find all candidate builders from the model.
    [self resolveCandidatesWithPostProcessors:postProcessors];

    // resolve and watch them.
    for (id<ALCResolvable> candidate in _candidateBuilders) {
        [self watchResolvable:candidate];
        [candidate resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    }
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Model: %@", [_searchExpressions componentsJoinedByString:@", "]];
}

-(void) resolveCandidatesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {
    STLog(self, @"Resolving value source -> %@", self);
    __block NSSet<id<ALCBuilder>> *finalBuilders;
    [[ALCAlchemic mainContext] executeOnBuildersWithSearchExpressions:_searchExpressions
                                              processingBuildersBlock:^(ProcessBuiderBlockArgs) {
                                                  finalBuilders = builders;
                                              }];

    // Post process the candidates.
    for (id<ALCDependencyPostProcessor> postProcessor in postProcessors) {
        finalBuilders = [postProcessor process:finalBuilders];
        if ([finalBuilders count] == 0) {
            break;
        }
    }

    STLog(ALCHEMIC_LOG, @"%lu final candidates", [finalBuilders count]);
    self->_candidateBuilders = finalBuilders;


    // If there are no candidates left then error.
    if ([_candidateBuilders count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicNoCandidateBuildersFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve value source -> %@ - no candidate builders found.", [_searchExpressions componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }

}

@end

NS_ASSUME_NONNULL_END