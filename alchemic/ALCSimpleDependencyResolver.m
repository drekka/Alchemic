//
//  AlchemicObjectInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 20/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <objc/runtime.h>

#import "ALCSimpleDependencyResolver.h"
#import "ALCLogger.h"
#import "ALCClassInfo.h"
#import "ALCContext.h"
#import "ALCDependencyInfo.h"
#import "ALCObjectStore.h"

/**
 *  The main class for managing the injection of an object. 
 */
@implementation ALCSimpleDependencyResolver {
    __weak ALCContext *_context;
}

-(instancetype) initWithContext:(__weak ALCContext *) context {
    self = [super init];
    if (self) {
        _context = context;
    }
    return self;
}

-(BOOL) resolveDependency:(ALCDependencyInfo *) dependency inObject:(id) object withObjectStore:(ALCObjectStore *) objectStore {

    Ivar variable = dependency.variable;
    
    // Skip if something has already been injected.
    if (object_getIvar(object, variable) != nil) {
        return YES;
    }

    // If the dependency info specifies a class, then look for that class.
    
    

    return NO;
}

@end
