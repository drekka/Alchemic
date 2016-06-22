//
//  ALCConfigClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCConfigClassProcessor.h>
#import <Alchemic/AlchemicConfig.h>

@implementation ALCConfigClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return [aClass conformsToProtocol:@protocol(AlchemicConfig)];
}

-(void) processClass:(Class) aClass withContext:(id<ALCContext>) context {
    
    STLog(self, @"Found config class %@", NSStringFromClass(aClass));
    
    if ([aClass respondsToSelector:@selector(configureAlchemic:)]) {
        STLog(self, @"Executing configure method");
        [(Class<AlchemicConfig>)aClass configureAlchemic:context];
    }
    
}

@end
