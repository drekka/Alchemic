//
//  STGenericMatcher.m
//  StoryTeller
//
//  Created by Derek Clarkson on 26/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "STCompareMatcher.h"

@implementation STCompareMatcher {
    BOOL (^ __nonnull _compareBlock)(__nonnull id key);
}

@synthesize nextMatcher = _nextMatcher;

-(nonnull instancetype) initWithCompare:(BOOL (^ __nonnull)(__nonnull id key)) compareBlock {
    self = [super init];
    if (self) {
        _compareBlock = [compareBlock copy];
    }
    return self;
}

-(BOOL) matches:(id __nonnull) key {
    return _compareBlock(key)
    && (self.nextMatcher == nil ? YES : [self.nextMatcher matches:key]);
}

@end
