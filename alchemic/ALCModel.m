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
#import "ALCInternal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModel {
    NSMutableSet<id<ALCBuilder>> *_model;
    NSCache *_queryCache;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        STLog(ALCHEMIC_LOG, @"Initing model instance ...");
        _model = [[NSMutableSet<id<ALCBuilder>> alloc] init];
        _queryCache = [[NSCache alloc] init];
    }
    return self;
}

-(NSUInteger) numberBuilders {
    return [_model count];
}

#pragma mark - Updating

-(void) addBuilder:(id<ALCBuilder>) builder {
    STLog(builder.valueClass, @"Storing builder for a %@", NSStringFromClass(builder.valueClass));
    [_model addObject:builder];
    [_queryCache removeAllObjects];
}

#pragma mark - Querying

-(NSSet<id<ALCBuilder>> *) allBuilders {
    return _model;
}

-(NSSet<ALCClassBuilder *> *) allClassBuilders {
    return [self buildersForQualifier:[ALCQualifier qualifierWithValue:@"AllClassBuilders"]
                          searchBlock:^BOOL(id<ALCBuilder> builder) {
                              return [builder isKindOfClass:[ALCClassBuilder class]];
                          }];
}

-(NSSet<id<ALCBuilder>> *) buildersForQualifiers:(NSSet<ALCQualifier *> *) qualifiers {

    // Quick short cut for single qualifier queries. Saves building a new set.
    if ([qualifiers count] == 1) {
        ALCQualifier *qualifier = [qualifiers anyObject];
        return [self buildersForQualifier:qualifier
                              searchBlock:^BOOL(id<ALCBuilder> builder) {
                                  return [qualifier matchesBuilder:builder];
                              }];
    }

    NSArray<ALCQualifier *> *sortedQualifiers = [self prioritizeQualifiersInSet:qualifiers];


    NSMutableSet<id<ALCBuilder>> *results;
    for (ALCQualifier *qualifier in sortedQualifiers) {
        NSSet<id<ALCBuilder>> *builders = [self buildersForQualifier:qualifier
                                                         searchBlock:^BOOL(id<ALCBuilder> builder) {
                                                             return [qualifier matchesBuilder:builder];
                                                         }];
        STLog(ALCHEMIC_LOG, @"Found %lu builders for qualifier %@", [builders count], qualifier);
        if (results == nil) {
            // No results yet to go with the set as a base set.
            results = [NSMutableSet setWithSet:builders];
        } else {
            // Remove any members which are not in the next qualifiers set.
            STLog(ALCHEMIC_LOG, @"Filtering builders with qualifier %@", [builders count], qualifier);
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

-(NSArray *) prioritizeQualifiersInSet:(NSSet<ALCQualifier *> *) qualifiers {
    NSArray *results = [qualifiers.allObjects sortedArrayUsingComparator:^NSComparisonResult(ALCQualifier __nonnull *qualifier1, ALCQualifier __nonnull *qualifier2) {
        int v1Weight = [self qualifierSortingWeight:qualifier1];
        int v2Weight = [self qualifierSortingWeight:qualifier2];
        if (v1Weight < v2Weight) {
            return NSOrderedAscending;
        }
        if (v1Weight > v2Weight) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return results;
}

-(int) qualifierSortingWeight:(ALCQualifier *) qualifier {
    id value = qualifier.value;
    if ([ALCRuntime objectIsAClass:value]) {
        return 0;
    }
    if ([ALCRuntime objectIsAProtocol:value]) {
        return 1;
    }
    return -1;
}

-(NSSet<ALCClassBuilder *> *) classBuildersFromBuilders:(NSSet<id<ALCBuilder>> *) builders {
    STLog(ALCHEMIC_LOG, @"Filtering for class builders ...");
    NSSet<ALCClassBuilder *> *newBuilders = (NSSet<ALCClassBuilder *> *)[builders objectsPassingTest:^BOOL(id<ALCBuilder>  builder, BOOL * stop) {
        return [builder isKindOfClass:[ALCClassBuilder class]];
    }];
    STLog(ALCHEMIC_LOG, @"Returning %lu class builders", [newBuilders count]);
    return newBuilders;
}

#pragma mark - Internal

-(NSSet<id<ALCBuilder>> *) buildersForQualifier:(ALCQualifier *) qualifier searchBlock:(BOOL (^)(id<ALCBuilder> builder)) searchBlock {

    STLog(ALCHEMIC_LOG, @"Searching for builders with: %@", qualifier);

    // Check the cache
    NSSet<id<ALCBuilder>> *cachedBuilders = [_queryCache objectForKey:qualifier.value];
    if (cachedBuilders) {
        STLog(ALCHEMIC_LOG, @"Returning cached list of %lu builders", [cachedBuilders count]);
        return cachedBuilders;
    }

    // Find the builders that match the qualifier.
    STLog(ALCHEMIC_LOG, @"Searching for builders for %@", qualifier);
    NSSet<id<ALCBuilder>> *builders = [_model objectsPassingTest:^BOOL(id<ALCBuilder>  builder, BOOL * stop) {
        if (searchBlock(builder)) {
            STLog(ALCHEMIC_LOG, @"Adding builder '%@' '%@", builder.name, NSStringFromClass(builder.valueClass));
            return YES;
        }
        return NO;
    }];

    // Store and return.
    [_queryCache setObject:builders forKey:qualifier.value];
    STLog(ALCHEMIC_LOG, @"Returning %li builders", [builders count]);
    return builders;
}

@end

NS_ASSUME_NONNULL_END
