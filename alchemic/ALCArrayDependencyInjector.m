//
//  ALCArrayDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 3/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArrayDependencyInjector.h"
#import "ALCVariableDependency.h"
#import "ALCLogger.h"
#import "ALCInstance.h"

@implementation ALCArrayDependencyInjector

-(BOOL) injectObject:(id) finalObject dependency:(ALCVariableDependency *) dependency {
    
    if (![dependency.variableClass isSubclassOfClass:[NSArray class]]) {
        return NO;
    }
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateInstances count]];
    [dependency.candidateInstances enumerateObjectsUsingBlock:^(ALCInstance *instance, BOOL *stop) {
        id value = instance.object;
        if (value != nil) {
            [values addObject:value];
        }
    }];
    
    logDependencyResolving(@"%lu candidates found, %lu have objects associated", [dependency.candidateInstances count], [values count]);
    [self injectObject:finalObject
              variable:dependency.variable
             withValue:values];
    return YES;
}

@end
