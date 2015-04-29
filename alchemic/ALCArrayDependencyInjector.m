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
    
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateInstances count]];
        [dependency.candidateInstances enumerateObjectsUsingBlock:^(ALCInstance *obj, BOOL *stop) {
            [values addObject:obj.finalObject];
        }];

        return [self injectObject:finalObject
                         variable:dependency.variable
                        withValue:[dependency.candidateInstances anyObject]];

    } else {
        if ([dependency.candidateInstances count] > 1) {
            @throw [NSException exceptionWithName:@"AlchemicTooManyObjects"
                                           reason:[NSString stringWithFormat:@"Expected 1 object for dependency %s, found %lu", ivar_getName(dependency.variable), (unsigned long)[dependency.candidateInstances count]]
                                         userInfo:nil];
        }
    }

    return NO;
}

@end
