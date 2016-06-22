//
//  ALCConfigClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCConfigClassProcessor.h>
#import <Alchemic/ALCConfig.h>

@implementation ALCConfigClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return [aClass conformsToProtocol:@protocol(ALCConfig)];
}

-(void) processClass:(Class) aClass withContext:(id<ALCContext>) context {
    
    STLog(self, @"Found config class %@", NSStringFromClass(aClass));
    
    if ([aClass respondsToSelector:@selector(configure:)]) {
        STLog(self, @"Executing configure method");
        [(Class<ALCConfig>)aClass configure:context];
    }
    
}

@end
