//
//  AlchemicObjectInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 20/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <objc/runtime.h>

#import "ALCClassDependencyResolver.h"
#import "ALCLogger.h"
#import "ALCContext.h"
#import "ALCDependency.h"
#import "NSDictionary+ALCModel.h"

/**
 *  The main class for managing the injection of an object.
 */
@implementation ALCClassDependencyResolver

-(NSDictionary *) resolveDependencyWithClass:(Class) aClass
                                   protocols:(NSArray *) protocols
                                        name:(NSString *) name {
    
    if (aClass == nil) {
        return nil;
    }
    
    NSDictionary *objs = [self.model objectDescriptionsForClass:aClass];
    if ([objs count] == 0) {
        return nil;
    }
    
    // Scan for protocols and exit if not found.
    if ([protocols count] > 0) {
        for (Protocol *protocol in protocols) {
            objs = [objs objectDescriptionsWithProtocol:protocol];
            if ([objs count] == 0) {
                return nil;
            }
        }
    }
    
    return objs;
    
}

@end
