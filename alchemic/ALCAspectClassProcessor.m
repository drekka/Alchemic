//
//  ALCAspectClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAspectClassProcessor.h"
#import <Alchemic/ALCResolveAspect.h>

@implementation ALCAspectClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return [aClass conformsToProtocol:@protocol(ALCResolveAspect)];
}

-(void) processClass:(Class) aClass withContext:(id<ALCContext>) context model:(id<ALCModel>) model {
    
    
    if ([aClass respondsToSelector:@selector(configureAlchemic:)]) {
        STLog(self, @"Executing +[%@ configureAlchemic:]", NSStringFromClass(aClass));
        [(Class<AlchemicConfig>)aClass configureAlchemic:context];
    }
}

@end
