//
//  ALCSimpleDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleValueProcessor.h"

@import ObjectiveC;

#import "ALCDependency.h"
#import "ALCVariableDependency.h"
#import "ALCLogger.h"
#import "ALCResolvableObject.h"
#import "ALCRuntime.h"

@implementation ALCSimpleValueProcessor

+(BOOL) canResolveClass:(Class)class {
    return ! [ALCRuntime class:class isKindOfClass:[NSArray class]];
}

-(id) resolveCandidateValues:(ALCDependency *) dependency {

    ALCResolvableObject *instance = [dependency.candidates anyObject];
    id object = instance.object;
    
    if (object == nil) {
        @throw [NSException exceptionWithName:@"AlchemicNilObject"
                                       reason:[NSString stringWithFormat:@"Dependency %s has not created an object", ivar_getName(((ALCVariableDependency *)dependency).variable)]
                                     userInfo:nil];
    }

    return object;
}

-(void) validateCandidates:(ALCDependency *)dependency {

    if ([dependency.candidates count] > 1) {
        
        NSMutableArray *candidates = [[NSMutableArray alloc] initWithCapacity:[dependency.candidates count]];
        for (id<ALCResolvable> modelObject in dependency.candidates) {
            [candidates addObject:[modelObject description]];
        }
        
        @throw [NSException exceptionWithName:@"AlchemicTooManyCandidates"
                                       reason:[NSString stringWithFormat:@"Expecting 1 object for %@, but found %lu:%@", dependency, [dependency.candidates count], [candidates componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }

}

@end
