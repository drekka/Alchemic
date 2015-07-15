//
//  ALCModelValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCModelValueSource.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCContext+Internal.h"
#import <Alchemic/ALCBuilder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Sources values from the model.
 */
@implementation ALCModelValueSource {
    __weak ALCContext *_context;
    NSSet<id<ALCBuilder>> *_candidateBuilders;
}

@synthesize values = _values;

-(instancetype) initWithContext:(ALCContext __weak *) context
              searchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions {
    self = [super init];
    if (self) {
        _searchExpressions = searchExpressions;
        _context = context;
        if ([searchExpressions count] == 0) {
            @throw [NSException exceptionWithName:@"AlchemicMissingSearchExpressions"
                                           reason:[NSString stringWithFormat:@"No search expressions passed"]
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

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {

    STLog(self, @"Resolving %@", self);
    STStartScope(self);
    ALCContext *strongContext = _context;
    [strongContext executeOnBuildersWithSearchExpressions:_searchExpressions
                                  processingBuildersBlock:^(ProcessBuiderBlockArgs) {

                                      NSSet<id<ALCBuilder>> *finalBuilders = builders;
                                      for (id<ALCDependencyPostProcessor> postProcessor in postProcessors) {
                                          finalBuilders = [postProcessor process:finalBuilders];
                                          if ([finalBuilders count] == 0) {
                                              break;
                                          }
                                      }

                                      STLog(ALCHEMIC_LOG, @"Found %lu candidates", [finalBuilders count]);
                                      self->_candidateBuilders = finalBuilders;
                                  }];

    // If there are no candidates left then error.
    if ([_candidateBuilders count] == 0) {

        NSMutableArray<NSString *> *expressionDescs = [[NSMutableArray alloc] initWithCapacity:[_searchExpressions count]];
        [_searchExpressions enumerateObjectsUsingBlock:^(NSObject<ALCModelSearchExpression> *searchExpression, BOOL * stop) {
            [expressionDescs addObject:[searchExpression description]];
        }];

        @throw [NSException exceptionWithName:@"AlchemicNoCandidateBuildersFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve value using %@ - no candidate builders found.", [expressionDescs componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }
}

@end

NS_ASSUME_NONNULL_END