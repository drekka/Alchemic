//
//  ALCConfigClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import "ALCConfigClassProcessor.h"
#import "AlchemicConfig.h"

@implementation ALCConfigClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return [aClass conformsToProtocol:@protocol(AlchemicConfig)];
}

-(void) processClass:(Class) aClass withContext:(id<ALCContext>) context {
    if ([aClass respondsToSelector:@selector(configureAlchemic:)]) {
        STLog(self, @"Executing +[%@ configureAlchemic:]", NSStringFromClass(aClass));
        [(Class<AlchemicConfig>)aClass configureAlchemic:context];
    }
}

@end
