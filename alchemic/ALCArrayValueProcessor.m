//
//  ALCArrayDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 3/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArrayValueProcessor.h"
#import "ALCLogger.h"
#import "ALCResolvable.h"
#import "ALCRuntime.h"
#import "ALCBuilder.h"
#import "ALCDependency.h"
#import "ALCType.h"

@implementation ALCArrayValueProcessor

+(BOOL) canResolveValueForDependency:(ALCDependency *)dependency {
    return ! [ALCRuntime class:dependency.valueType.typeClass isKindOfClass:[NSArray class]];
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

-(void) validateCandidates:(NSSet *) candidates {
    // Nothing to do here.
}

@end
