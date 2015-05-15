//
//  ALCArrayDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 3/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArrayObjectResolver.h"
#import "ALCVariableDependencyResolver.h"
#import "ALCLogger.h"
#import "ALCObjectInstance.h"

@implementation ALCArrayObjectResolver

-(BOOL) injectObject:(id) finalObject dependency:(ALCVariableDependencyResolver *) dependency {
    
    if (![dependency.variableClass isSubclassOfClass:[NSArray class]]) {
        return NO;
    }
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[dependency.candidateInstances count]];
    [dependency.candidateInstances enumerateObjectsUsingBlock:^(ALCObjectInstance *instance, BOOL *stop) {
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
