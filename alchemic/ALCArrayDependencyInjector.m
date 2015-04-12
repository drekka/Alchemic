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

    if ([ALCRuntime class:dependency.variableClass extends:[NSArray class]]) {
    
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateObjectDescriptions count]];
        [dependency.candidateObjectDescriptions enumerateObjectsUsingBlock:^(ALCInstance *obj, NSUInteger idx, BOOL *stop) {
            [values addObject:obj.finalObject];
        }];

        logRuntime(@"Injecting %s with array of %lu objects", ivar_getName(dependency.variable), [dependency.candidateObjectDescriptions count]);
        object_setIvar(finalObject, dependency.variable, values);
        return YES;

    } else {
        if ([dependency.candidateObjectDescriptions count] > 1) {
            @throw [NSException exceptionWithName:@"AlchemicTooManyObjects"
                                           reason:[NSString stringWithFormat:@"Expected 1 object for dependency %s, found %lu", ivar_getName(dependency.variable), (unsigned long)[dependency.candidateObjectDescriptions count]]
                                         userInfo:nil];
        }
    }

    return NO;
}

@end
