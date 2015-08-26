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
#import "NSObject+ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCModelValueSource ()
@property (nonatomic, assign) BOOL available;
@end

/**
 Sources values from the model.
 */
@implementation ALCModelValueSource {
    NSSet<id<ALCBuilder>> *_candidateBuilders;
}

@synthesize available = _available;

-(void) dealloc {
    [self kvoRemoveWatchAvailableFromResolvableSet:_candidateBuilders];
}

-(instancetype) initWithType:(Class) argumentType {
    return nil;
}

-(instancetype) initWithType:(Class) argumentType searchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions {
    self = [super initWithType:argumentType];
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
                                                  [self kvoRemoveWatchAvailableFromResolvableSet:self->_candidateBuilders];
                                                  self->_candidateBuilders = finalBuilders;
                                              }];

    // If there are no candidates left then error.
    if ([_candidateBuilders count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicNoCandidateBuildersFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve value source -> %@ - no candidate builders found.", [_searchExpressions componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }

    // Now resolve all candidates
    for (id<ALCBuilder> candidate in _candidateBuilders) {
        STLog(self, @"Resolving candidate %@", candidate);
        [candidate resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    }

    // Start watching the builders.
    [self kvoWatchAvailableInResolvableSet:_candidateBuilders];
    _available = [self candidatesAvailable];

}

-(void) observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString *,id> *)change context:(nullable void *)context {
    if (!self.available && [self candidatesAvailable]) {
        STLog(self.valueClass, @"Candidates available, triggering KVO.");
        self.available = YES; // Trigger KVO.
    }
}

-(BOOL) candidatesAvailable {
    for (id<ALCBuilder> builder in _candidateBuilders) {
        if (!builder.available) {
            return NO;
        }
    }
    return YES;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Model: %@", [_searchExpressions componentsJoinedByString:@", "]];
}

@end

NS_ASSUME_NONNULL_END