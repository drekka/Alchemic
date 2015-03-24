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
#import "ALCDependencyInfo.h"
#import "NSDictionary+ALCModel.h"

/**
 *  The main class for managing the injection of an object.
 */
@implementation ALCClassDependencyResolver

-(NSDictionary *) resolveDependency:(ALCDependencyInfo *) dependency {
    
    if (dependency.variableClass == nil) {
        return nil;
    }
    
    NSDictionary *objs = [self.model infoObjectsOfClass:dependency.variableClass];
    if ([objs count] == 0) {
        return nil;
    }
    
    // Scan for protocols and exit if not found.
    if ([dependency.variableProtocols count] > 0) {
        for (Protocol *protocol in dependency.variableProtocols) {
            objs = [objs infoObjectsWithProtocol:protocol];
            if ([objs count] == 0) {
                return nil;
            }
        }
    }

    return objs;
    
}

@end
