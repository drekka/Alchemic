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

-(nonnull NSSet<id<ALCBuilder>> *) buildersWithClass:(Class __nonnull) class {
    STLog(ALCHEMIC_LOG, @"Querying for builders for class: %@ ...", NSStringFromClass(class));
    return [self buildersWithCacheId:class
                      includeIfBlock:^BOOL(id<ALCBuilder> builder) {
                          return [ALCRuntime class:builder.valueClass isKindOfClass:class];
                      }];
}

-(nonnull NSSet<id<ALCBuilder>> *) buildersWithProtocol:(Protocol __nonnull *) protocol {
    STLog(ALCHEMIC_LOG, @"Querying for builders for protocol: %@ ...", NSStringFromProtocol(protocol));
    return [self buildersWithCacheId:protocol
                      includeIfBlock:^BOOL(id<ALCBuilder> builder) {
                          return [ALCRuntime class:builder.valueClass conformsToProtocol:protocol];
                      }];
}

-(nonnull NSSet<id<ALCBuilder>> *) buildersWithName:(NSString __nonnull *) name {
    STLog(ALCHEMIC_LOG, @"Querying for builders with name: %@ ...", name);
    return [self buildersWithCacheId:name
                      includeIfBlock:^BOOL(id<ALCBuilder> builder) {
                          return [name isEqualToString:builder.name];
                      }];
}

#pragma mark - Internal

-(nonnull NSSet<id<ALCBuilder>> *) buildersWithCacheId:(id __nonnull) cacheId
                                        includeIfBlock:(BOOL (^)(id<ALCBuilder> builder)) includeIfBlock {

    // Check the cache
    NSSet<id<ALCBuilder>> *cachedBuilders = [_queryCache objectForKey:cacheId];
    if (cachedBuilders) {
        STLog(ALCHEMIC_LOG, @"Cached list of builders being returned.");
        return cachedBuilders;
    }

    // Find the objects.
    NSMutableSet<id<ALCBuilder>> *builders = [[NSMutableSet<id<ALCBuilder>> alloc]  init];
    for (id<ALCBuilder> builder in _model) {
        if (includeIfBlock(builder)) {
            STLog(ALCHEMIC_LOG, @"Adding builder for a %@", NSStringFromClass(builder.valueClass));
            [builders addObject:builder];
        }
    }

    // Store and return.
    [_queryCache setObject:builders forKey:cacheId];
    STLog(ALCHEMIC_LOG, @"Returning %li builders.", [builders count]);
    return builders;
}

@end
