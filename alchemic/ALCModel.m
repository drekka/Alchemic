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

#pragma mark - Updating

-(void) addBuilder:(id<ALCBuilder> __nonnull) builder {
    STLog(builder.valueClass, @"Storing builder for a %@", NSStringFromClass(builder.valueClass));
    [_model addObject:builder];
    [_queryCache removeAllObjects];
}

#pragma mark - Querying

-(nonnull NSSet<id<ALCBuilder>> *) allBuilders {
    return _model;
}

-(nonnull NSSet<ALCClassBuilder *> *) allClassBuilders {
    return [self buildersWithCacheId:[ALCClassBuilder class]
                         searchBlock:^BOOL(id<ALCBuilder> builder) {
                             return [builder isKindOfClass:[ALCClassBuilder class]];
                         }];
}

-(nonnull NSSet<id<ALCBuilder>> *) buildersMatchingQualifiers:(NSSet<ALCQualifier *> __nonnull *) qualifiers {

    NSMutableSet<id<ALCBuilder>> *results;
    for (ALCQualifier *qualifier in qualifiers) {
        if (results == nil) {
            results = [NSMutableSet setWithSet:[self buildersWithCacheId:qualifier.value
                                                             searchBlock:^BOOL(id<ALCBuilder> builder) {
                                                                 return [qualifier matchesBuilder:builder];
                                                             }]];
        } else {
            [results intersectSet:[self buildersWithCacheId:qualifier.value
                                                searchBlock:^BOOL(id<ALCBuilder> builder) {
                                                    return [qualifier matchesBuilder:builder];
                                                }]];
        }
        if ([results count] == 0) {
            break;
        }
    }
    return results;
}

-(nonnull NSSet<ALCClassBuilder *> *) classBuildersFromBuilders:(NSSet<id<ALCBuilder>> __nonnull *) builders {
    return (NSSet<ALCClassBuilder *> *)[builders objectsPassingTest:^BOOL(id<ALCBuilder>  __nonnull builder, BOOL * __nonnull stop) {
        return [builder isKindOfClass:[ALCClassBuilder class]];
    }];
}

#pragma mark - Internal

-(nonnull NSSet<id<ALCBuilder>> *) buildersWithCacheId:(id __nonnull) cacheId searchBlock:(BOOL (^ __nonnull)(id<ALCBuilder> builder)) searchBlock {

    // Check the cache
    NSSet<id<ALCBuilder>> *cachedBuilders = [_queryCache objectForKey:cacheId];
    if (cachedBuilders) {
        STLog(ALCHEMIC_LOG, @"Cached list of builders being returned.");
        return cachedBuilders;
    }

    // Find the builders that match the qualifier.
    NSSet<id<ALCBuilder>> *builders = [_model objectsPassingTest:^BOOL(id<ALCBuilder>  __nonnull builder, BOOL * __nonnull stop) {
        if (searchBlock(builder)) {
            STLog(ALCHEMIC_LOG, @"Adding builder for a %@", NSStringFromClass(builder.valueClass));
            return YES;
        }
        return NO;
    }];

    // Store and return.
    [_queryCache setObject:builders forKey:cacheId];
    STLog(ALCHEMIC_LOG, @"Returning %li builders.", [builders count]);
    return builders;
}

@end
