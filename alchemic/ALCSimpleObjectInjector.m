//
//  ALCSimpleObjectInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 18/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleObjectInjector.h"
#import "ALCDependencyInfo.h"
#import <objc/runtime.h>
#import "ALCLogger.h"
#import "NSObject+Alchemic.h"

@implementation ALCSimpleObjectInjector

-(BOOL) inject:(id)object dependency:(ALCDependencyInfo *)dependency withCandidates:(NSArray *)candidates {
    
    id value = candidates[0];
    [self resolveProxy:&value];
    logObjectResolving(@"Injecting a %s object into %s::%s", class_getName([value class]), class_getName(dependency.inClass), ivar_getName(dependency.variable));
    object_setIvar(object, dependency.variable, value);
    return YES;
}

@end
