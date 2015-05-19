//
//  ALCArrayDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 3/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArrayValueProcessor.h"
#import "ALCVariableDependency.h"
#import "ALCLogger.h"
#import "ALCResolvable.h"
#import "ALCRuntime.h"

@implementation ALCArrayValueProcessor

+(BOOL) canResolveClass:(Class)class {
    return ! [ALCRuntime class:class isKindOfClass:[NSArray class]];
}

-(id) resolveCandidateValues:(ALCDependency *)dependency {

    if ([dependency.candidates count] == 1) {
        id value = ((id<ALCResolvable>)[dependency.candidates anyObject]).object;
        return  [value isKindOfClass:[NSArray class]] ? value : @[value];
    }
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[dependency.candidates count]];
    [dependency.candidates enumerateObjectsUsingBlock:^(id<ALCResolvable> modelObject, BOOL *stop) {
        id value = modelObject.object;
        if (value != nil) {
            [values addObject:value];
        }
    }];
    return values;
    
}

-(void) validateCandidates:(ALCDependency *)dependency {
    // Nothing to do here.
}

@end
