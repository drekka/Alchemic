//
//  ALCAbstractDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractDependencyInjector.h"
#import "ALCLogger.h"

@implementation ALCAbstractDependencyInjector

-(BOOL) injectObject:(id) object dependency:(ALCDependency *) dependency {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

-(void) injectObject:(id) object variable:(Ivar) variable withValue:(id) value {
    logRuntime(@"Injecting %s::%s with a %s",object_getClassName(object) , ivar_getName(variable), object_getClassName(value));
    object_setIvar(object, variable, value);
}

@end
