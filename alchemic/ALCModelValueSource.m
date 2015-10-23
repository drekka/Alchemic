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
#import "ALCInternalMacros.h"
#import "NSSet+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Sources values from the model.
 */
@implementation ALCModelValueSource

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
    [self.dependencies enumerateObjectsUsingBlock:^(ALCBuilder *builder, BOOL * stop) {
        id value = builder.value;
        [results addObject:value];
    }];
    return results;
}

-(void) willResolve {

    __block NSSet<ALCBuilder *> *candidates;
    [[ALCAlchemic mainContext] buildersWithSearchExpressions:_searchExpressions
                                         processingBuildersBlock:^(ProcessBuiderBlockArgs) {
                                             candidates = builders;
                                         }];

    // Find primary objects.
    NSMutableSet<ALCBuilder *> *primaries = [[NSMutableSet alloc] init];
    for (ALCBuilder *candidateBuilder in candidates) {
        if (candidateBuilder.primary) {
            [primaries addObject:candidateBuilder];
        }
    }

    // Replace the list if primaries are present.
    if ([primaries count] > 0) {
        STLog(ALCHEMIC_LOG, @"%lu primary objects detected", [primaries count]);
        candidates = primaries;
    }

    // If there are no candidates left then error.
    if ([candidates count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicNoCandidateBuildersFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve %@ - no candidate builders found.", self]
                                     userInfo:nil];
    }

    // Add the candidates to the resolvables dependencies.
    STLog(ALCHEMIC_LOG, @"%lu final candidates", [candidates count]);
    for (ALCBuilder *candidateBuilder in candidates) {
        [self addDependency:candidateBuilder];
    }
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Value Source for %@ -> Model search: %@", NSStringFromClass(self.valueClass), [_searchExpressions componentsJoinedByString:@", "]];
}

@end

NS_ASSUME_NONNULL_END