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
    NSMutableSet<id<ALCResolvable>> *_unavailableCandidates;
}

-(instancetype) initWithType:(Class)argumentType
               whenAvailable:(nullable ALCWhenAvailableBlock) whenAvailableBlock {
    return nil;
}

-(instancetype) initWithType:(Class) argumentType
           searchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions
               whenAvailable:(nullable ALCWhenAvailableBlock) whenAvailableBlock {
    self = [super initWithType:argumentType whenAvailable:whenAvailableBlock];
    if (self) {
        _searchExpressions = searchExpressions;
        if ([searchExpressions count] == 0) {
            @throw [NSException exceptionWithName:@"AlchemicMissingSearchExpressions"
                                           reason:@"No search expressions passed"
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

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    STLog(self, @"Resolving value source -> %@", self);
    [[ALCAlchemic mainContext] executeOnBuildersWithSearchExpressions:_searchExpressions
                                              processingBuildersBlock:^(ProcessBuiderBlockArgs) {

                                                  NSSet<id<ALCBuilder>> *finalBuilders = builders;
                                                  for (id<ALCDependencyPostProcessor> postProcessor in postProcessors) {
                                                      finalBuilders = [postProcessor process:finalBuilders];
                                                      if ([finalBuilders count] == 0) {
                                                          break;
                                                      }
                                                  }

                                                  STLog(ALCHEMIC_LOG, @"%lu final candidates", [finalBuilders count]);
                                                  self->_candidateBuilders = finalBuilders;
                                              }];

    // If there are no candidates left then error.
    if ([_candidateBuilders count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicNoCandidateBuildersFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve value source -> %@ - no candidate builders found.", [_searchExpressions componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }

    // Add the candidates to the unresolved pool.
    _unavailableCandidates = [_candidateBuilders mutableCopy];

    // Now resolve all candidates and add callback blocks
    for (id<ALCBuilder> candidate in _candidateBuilders) {

        STLog(self, @"Resolving candidate %@", candidate);

        [candidate executeWhenAvailable:^(id<ALCResolvable>  _Nonnull resolvable) {
            [self->_unavailableCandidates removeObject:resolvable];
            if ([self->_unavailableCandidates count] == 0) {
                STLog(self, @"All candidates available, executing when available callback");
                [self nowAvailable];
            }
        }];

        [candidate resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    }

}

-(NSString *) description {
    return [NSString stringWithFormat:@"Model: %@", [_searchExpressions componentsJoinedByString:@", "]];
}

@end

NS_ASSUME_NONNULL_END