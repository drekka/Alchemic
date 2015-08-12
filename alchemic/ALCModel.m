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
#import "ALCClassBuilder.h"
#import "ALCInternalMacros.h"
#import "ALCModelSearchExpression.h"

NS_ASSUME_NONNULL_BEGIN

@interface AllClassesExpression: NSObject<ALCModelSearchExpression>
@end

@implementation AllClassesExpression

-(int) priority {
    return 0;
}

-(id) cacheId {
    return @"AllClassBuilders";
}

-(BOOL) matches:(id<ALCBuilder>)builder {
    return [builder isKindOfClass:[ALCClassBuilder class]];
}

@end


@implementation ALCModel {
    NSMutableSet<id<ALCBuilder>> *_model;
    NSCache *_queryCache;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        STLog(ALCHEMIC_LOG, @"Initing model instance ...");
        _model = [[NSMutableSet alloc] init];
        _queryCache = [[NSCache alloc] init];
    }
    return self;
}

-(NSUInteger) numberBuilders {
    return [_model count];
}

#pragma mark - Updating

-(void) addBuilder:(id<ALCBuilder>) builder {
    [_model addObject:builder];
    [_queryCache removeAllObjects];
}

-(void) removeBuilder:(id<ALCBuilder>) builder {
	[_model removeObject:builder];
	[_queryCache removeAllObjects];
}

#pragma mark - Querying

-(NSSet<id<ALCBuilder>> *) allBuilders {
    return _model;
}

-(NSSet<id<ALCBuilder>> *) buildersForSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions {

    // Quick short cut for single expression queries. Saves building a new set.
    if ([searchExpressions count] == 1) {
        id<ALCModelSearchExpression> searchExpression = [searchExpressions anyObject];
        return [self buildersForSearchExpression:searchExpression];
    }

    NSArray<id<ALCModelSearchExpression>> *sortedSearchExpressions = [self sortedSearchExpressions:searchExpressions];

    NSMutableSet<id<ALCBuilder>> *results;
    for (id<ALCModelSearchExpression> searchExpression in sortedSearchExpressions) {
        NSSet<id<ALCBuilder>> *builders = [self buildersForSearchExpression:searchExpression];
        STLog(ALCHEMIC_LOG, @"Found %lu builders for %@", [builders count], searchExpression);
        if (results == nil) {
            // No results yet to go with the set as a base set.
            results = [NSMutableSet setWithSet:builders];
        } else {
            // Remove any members which are not in the next expression's set.
            STLog(ALCHEMIC_LOG, @"Filtering %lu builders with %@", [builders count], searchExpression);
            [results intersectSet:builders];
        }

        // Opps, run out of builders.
        if ([results count] == 0) {
            STLog(ALCHEMIC_LOG, @"No builders left.");
            break;
        }
    }
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

-(NSSet<ALCClassBuilder *> *) classBuildersFromBuilders:(NSSet<id<ALCBuilder>> *) builders {

    if ([builders count] == 0) {
        return builders;
    }

    STLog(ALCHEMIC_LOG, @"Filtering for class builders ...");
    NSSet<ALCClassBuilder *> *newBuilders = (NSSet<ALCClassBuilder *> *)[builders objectsPassingTest:^BOOL(id<ALCBuilder>  builder, BOOL * stop) {
        return [builder isKindOfClass:[ALCClassBuilder class]];
    }];
    STLog(ALCHEMIC_LOG, @"Returning %lu class builders", [newBuilders count]);
    return newBuilders;
}

#pragma mark - Internal

-(NSSet<id<ALCBuilder>> *) buildersForSearchExpression:(id<ALCModelSearchExpression>) searchExpression {

    // Check the cache
    NSSet<id<ALCBuilder>> *cachedBuilders = [_queryCache objectForKey:searchExpression.cacheId];
    if (cachedBuilders) {
        STLog(ALCHEMIC_LOG, @"Returning cached list of %lu builders for expressions %@", [cachedBuilders count], searchExpression);
        return cachedBuilders;
    }

    // Find the builders that match the expression.
    STLog(ALCHEMIC_LOG, @"Searching for builders based on expressions %@", searchExpression);
    NSSet<id<ALCBuilder>> *builders = [_model objectsPassingTest:^BOOL(id<ALCBuilder> builder, BOOL * stop) {
        if ([searchExpression matches:builder]) {
            STLog(ALCHEMIC_LOG, @"Adding builder '%@' %@", builder.name, builder);
            return YES;
        }
        return NO;
    }];

    // Store and return.
    [_queryCache setObject:builders forKey:searchExpression.cacheId];
    STLog(ALCHEMIC_LOG, @"Returning %li builders", [builders count]);
    return builders;
}

@end

NS_ASSUME_NONNULL_END
