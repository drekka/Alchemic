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
#import "ALCClassInfo.h"
#import "ALCContext.h"
#import "ALCDependencyInfo.h"
#import "ALCObjectStore.h"
#import "ALCRuntime.h"

/**
 *  The main class for managing the injection of an object.
 */
@implementation ALCClassDependencyResolver

-(NSArray *) resolveDependency:(ALCDependencyInfo *) dependency inObject:(id) object withObjectStore:(ALCObjectStore *) objectStore {
    
    // If the dependency info specifies a class, then look for that class.
    if (dependency.variableClass == nil) {
        return nil;
    }
    
    logObjectResolving(@"Retrieving objects of class %s", class_getName(dependency.variableClass));
    NSArray *objs = [objectStore objectsOfClass:dependency.variableClass];
    if ([objs count] == 0) {
        logObjectResolving(@"No objects found");
        return nil;
    }
    
    // Scan for protocols and exit if not found.
    if ([dependency.variableProtocols count] > 0) {
        objs = [ALCRuntime filterObjects:objs forProtocols:dependency.variableProtocols];
    }

    return objs;
    
}

@end
