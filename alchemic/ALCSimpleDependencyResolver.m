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

/**
 *  The main class for managing the injection of an object. 
 */
@implementation ALCSimpleDependencyResolver

-(void) resolveDependenciesInObject:(id) object usingContext:(ALCContext *) context {
    logObjectResolving(@"Injecting objects into a %s", class_getName([object class]));
}

@end
