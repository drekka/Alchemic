//
//  STFilterMatcher.m
//  StoryTeller
//
//  Created by Derek Clarkson on 26/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "STFilterMatcher.h"

@implementation STFilterMatcher {
    __nullable id (^ __nonnull _filterBlock)(__nonnull id key);
}

@synthesize nextMatcher = _nextMatcher;

-(nonnull instancetype) initWithFilter:(__nullable id (^ __nonnull)(__nonnull id key)) filterBlock {
    self = [super init];
    if (self) {
        _filterBlock = [filterBlock copy];
    }
    return self;
}

-(BOOL) matches:(id __nonnull) key {
    NSAssert(_nextMatcher != NULL, @"Must have a next matcher");
    return [self.nextMatcher matches:_filterBlock(key)];
}



@end
