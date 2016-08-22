//
//  ALCAspectClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAspectClassProcessor.h"
#import <Alchemic/ALCResolveAspect.h>
#import <Alchemic/ALCContext.h>

@implementation ALCAspectClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return [aClass conformsToProtocol:@protocol(ALCResolveAspect)];
}

-(void) processClass:(Class) aClass withContext:(id<ALCContext>) context {
    id<ALCResolveAspect> aspect = [[aClass alloc] init];
    [context addResolveAspect:aspect];
}

@end
