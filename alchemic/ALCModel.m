//
//  ALCModel.m
//  Alchemic
//
//  Created by Derek Clarkson on 3/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCModel.h"
#import "ALCRuntime.h"
#import "ALCInternalMacros.h"
#import "ALCModelSearchExpression.h"
#import "ALCName.h"
#import "ALCBuilder.h"
#import "ALCBuilderType.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModel {
    NSMutableDictionary<NSString *, ALCBuilder *> *_model;
    NSCache *_queryCache;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        STLog(ALCHEMIC_LOG, @"Initing model instance ...");
        _queryCache = [[NSCache alloc] init];
        _model = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSUInteger) numberBuilders {
    return [_model count];
}

#pragma mark - Updating

-(void) addBuilder:(ALCBuilder *) builder {
    if (_model[builder.name]) {
        @throw [NSException exceptionWithName:@"AlchemicDuplicateName"
                                       reason:[NSString stringWithFormat:@"Builder names must be unique. Duplicate name: %@ found on builder %@ and builder %@", builder.name, builder, _model[builder.name]]
                                     userInfo:nil];
    }
    _model[builder.name] = builder;
}

-(void) removeBuilder:(ALCBuilder *) builder {
    [_model removeObjectForKey:builder.name];
}

-(void) builderDidChangeName:(NSString *) oldName newName:(NSString  *) newName {
    ALCBuilder *builder = _model[oldName];
    [_model removeObjectForKey:oldName];
    _model[newName] = builder;
}

#pragma mark - Querying

-(NSSet<ALCBuilder *> *) allBuilders {
    return [NSSet setWithArray:_model.allValues];
}

-(NSSet<ALCBuilder *> *) buildersForSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions {

    // Quick short cut for single expression queries. Saves building a new set.
    if ([searchExpressions count] == 1) {
        id<ALCModelSearchExpression> searchExpression = [searchExpressions anyObject];
        return [self buildersForSearchExpression:searchExpression];
    }

    NSArray<id<ALCModelSearchExpression>> *sortedSearchExpressions = [self sortedSearchExpressions:searchExpressions];

    NSMutableSet<ALCBuilder *> *results;
    for (id<ALCModelSearchExpression> searchExpression in sortedSearchExpressions) {
        NSSet<ALCBuilder *> *builders = [self buildersForSearchExpression:searchExpression];
        if (results == nil) {
            // No results yet to go with the set as a base set.
            results = [NSMutableSet setWithSet:builders];
        } else {
            // Remove any members which are not in the next expression's set.
            [results intersectSet:builders];
        }

        // Opps, run out of builders.
        if ([results count] == 0) {
            STLog(ALCHEMIC_LOG, @"No builders left.");
            break;
        }
    }
    STLog(ALCHEMIC_LOG, @"Found %lu builders for %@", [results count], searchExpressions);
    return results;
}

-(NSArray *) sortedSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions {
    NSArray *results = [searchExpressions.allObjects sortedArrayUsingComparator:^NSComparisonResult(id<ALCModelSearchExpression> exp1, id<ALCModelSearchExpression> exp2) {
        if (exp1.priority > exp2.priority) {
            return NSOrderedAscending;
        }
        if (exp1.priority < exp2.priority) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return results;
}

-(NSSet<ALCBuilder *> *) classBuildersFromBuilders:(NSSet<ALCBuilder *> *) builders {

    if ([builders count] == 0) {
        return builders;
    }

    STLog(ALCHEMIC_LOG, @"Filtering for class builders ...");
    NSSet<ALCBuilder *> *newBuilders = [builders objectsPassingTest:^BOOL(ALCBuilder *builder, BOOL * stop) {
        return builder.isClassBuilder;
    }];
    STLog(ALCHEMIC_LOG, @"Returning %lu class builders", [newBuilders count]);
    return newBuilders;
}

#pragma mark - Internal

-(NSSet<ALCBuilder *> *) buildersForSearchExpression:(id<ALCModelSearchExpression>) searchExpression {

    // Check for a name query first.
    if ([searchExpression isKindOfClass:[ALCName class]]) {
        ALCName *nameExpression = (ALCName *)searchExpression;
        ALCBuilder *builder = _model[nameExpression.aName];
        if (builder == nil) {
            return [NSSet set];
        }
        STLog(ALCHEMIC_LOG, @"Found builder with name: %@ -> %@", nameExpression.aName, builder);
        return [NSSet setWithObject:builder];
    }

    // Check the cache
    NSSet<ALCBuilder *> *cachedBuilders = [_queryCache objectForKey:searchExpression.cacheId];
    if (cachedBuilders) {
        STLog(ALCHEMIC_LOG, @"Returning cached list of %lu builders for expressions %@", [cachedBuilders count], searchExpression);
        return cachedBuilders;
    }

    // Find the builders that match the expression.
    STLog(ALCHEMIC_LOG, @"Searching for builders based on expressions %@", searchExpression);
    NSMutableSet<ALCBuilder *> *builders = [NSMutableSet set];
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *key, ALCBuilder *builder, BOOL *stop) {
        if ([searchExpression matches:builder]) {
            STLog(ALCHEMIC_LOG, @"Adding builder '%@' %@", builder.name, builder);
            [builders addObject:builder];
        }
    }];

    // Store and return.
    [_queryCache setObject:builders forKey:searchExpression.cacheId];
    return builders;
}

-(NSString *) description {
    return [_model description];
}

@end

NS_ASSUME_NONNULL_END
