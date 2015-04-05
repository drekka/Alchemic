//
//  ALCArrayDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 3/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArrayDependencyInjector.h"
#import "ALCDependency.h"
#import "ALCLogger.h"
#import "ALCRuntime.h"
#import "ALCInstance.h"

@implementation ALCArrayDependencyInjector

-(BOOL) injectObject:(id) finalObject dependency:(ALCDependency *) dependency {

    if ([ALCRuntime class:dependency.resolveUsingClass extends:[NSArray class]]) {
    
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateObjectDescriptions count]];
        [dependency.candidateObjectDescriptions enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *object, BOOL *stop) {
            [values addObject:object.finalObject];
        }];
        logDependencyResolving(@"Injecting %s with array of objects", ivar_getName(dependency.variable));
        object_setIvar(finalObject, dependency.variable, values);
        return YES;
    }

    return NO;
}

@end
