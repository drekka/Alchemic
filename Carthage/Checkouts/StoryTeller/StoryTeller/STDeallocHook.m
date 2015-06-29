//
//  STChronicleHook.m
//  StoryTeller
//
//  Created by Derek Clarkson on 19/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "STDeallocHook.h"

@implementation STDeallocHook {
    __nonnull void (^_deallocBlock)(void);
}

-(nonnull instancetype) initWithBlock:(__nonnull void (^)(void)) simpleBlock {
    self = [super init];
    if (self) {
        _deallocBlock = simpleBlock;
    }
    return self;
}

-(void) dealloc {
    _deallocBlock();
}

@end
