//
//  ALCSimpleVariableInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 17/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleVariableInjector.h"
#import "ALCLogger.h"
#import "ALCDependencyInfo.h"

#import <objc/runtime.h>

@implementation ALCSimpleVariableInjector

-(BOOL) injectIntoObject:(id) object dependency:(ALCDependencyInfo *) dependency candidates:(NSArray *) candidates {
    
    logObjectResolving(@"Injecting candidate objects %@", candidates);
    
    if ([candidates count] == 1) {
        object_setIvar(object, dependency.variable, candidates[0]);
        return YES;
    }
    
    return NO;
}

@end
