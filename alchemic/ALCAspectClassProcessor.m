//
//  ALCAspectClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAspectClassProcessor.h"
#import "ALCResolveAspect.h"
#import "ALCAbstractAspect.h"
#import "ALCContext.h"

@implementation ALCAspectClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return [aClass conformsToProtocol:@protocol(ALCResolveAspect)]
    && ![[ALCAbstractAspect class] isSubclassOfClass:aClass];
}

-(void) processClass:(Class) aClass withContext:(id<ALCContext>) context {
    id<ALCResolveAspect> aspect = [[aClass alloc] init];
    [context addResolveAspect:aspect];
}

@end
