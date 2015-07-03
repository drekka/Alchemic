//
//  ALCModel.m
//  Alchemic
//
//  Created by Derek Clarkson on 3/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCModel.h"

@implementation ALCModel {
    NSMutableSet<id<ALCBuilder>> *_model;
    NSCache *_queryCache;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        _model = [[NSMutableSet<id<ALCBuilder>> alloc] init];
        _queryCache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - Updating

-(void) addBuilder:(id<ALCBuilder> __nonnull) builder {

}

#pragma mark - Querying

-(nonnull NSSet<id<ALCBuilder>> *) buildersWithClass:(Class __nonnull) class {
    return nil;
}

#pragma mark - Internal

@end
