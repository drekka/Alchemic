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
#import "ALCInstance.h"

@implementation ALCArrayDependencyInjector

-(BOOL) injectObject:(id) finalObject dependency:(ALCDependency *) dependency {

    if ([dependency.variableClass isSubclassOfClass:[NSArray class]]) {
    
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateInstances count]];
        [dependency.candidateInstances enumerateObjectsUsingBlock:^(ALCInstance *instance, BOOL *stop) {
            id value = instance.finalObject;
            if (value != nil) {
                [values addObject:value];
            }
        }];

        logDependencyResolving(@"%lu candidates found, %lu have objects associated", [dependency.candidateInstances count], [values count]);
        return [self injectObject:finalObject
                         variable:dependency.variable
                        withValue:values];
    }

    return NO;
}

@end
