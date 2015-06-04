//
//  ALCArrayDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 3/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArrayValueResolver.h"
#import "ALCLogger.h"
#import "ALCRuntime.h"
#import "ALCBuilder.h"
#import "ALCDependency.h"
#import "ALCType.h"

@implementation ALCArrayValueResolver

-(BOOL) canResolveValueForDependency:(ALCDependency *)dependency candidates:(NSSet *)candidates {
    Class typeClass = dependency.valueType.typeClass;
    return (typeClass == NULL && [candidates count] > 1)
    || [ALCRuntime class:typeClass isKindOfClass:[NSArray class]];
}

-(id) resolveCandidateValues:(NSSet *) candidates {

    if ([candidates count] == 1) {
        id value = ((id<ALCBuilder>)[candidates anyObject]).value;
        return  [value isKindOfClass:[NSArray class]] ? value : @[value];
    }
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[candidates count]];
    [candidates enumerateObjectsUsingBlock:^(id<ALCBuilder> builder, BOOL *stop) {
        id value = builder.value;
        if (value != nil) {
            [values addObject:value];
        }
    }];
    return values;
    
}

@end
