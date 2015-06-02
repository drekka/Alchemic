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
#import "ALCLogger.h"
#import "ALCRuntime.h"
#import "ALCType.h"
#import "ALCBuilder.h"

@implementation ALCSimpleValueProcessor

+(BOOL) canResolveValueForDependency:(ALCDependency *)dependency {
    return ! [dependency.valueType.typeClass isKindOfClass:[NSArray class]];
}

-(id) resolveCandidateValues:(NSSet *) candidates {
    
    id<ALCBuilder> object = [candidates anyObject];
    
    if (object == nil) {
        @throw [NSException exceptionWithName:@"AlchemicNilObject"
                                       reason:[NSString stringWithFormat:@"Dependency resolved to a nil"]
                                     userInfo:nil];
    }
    
    return object.value;
}

-(void) validateCandidates:(NSSet *)candidates {
    
    if ([candidates count] > 1) {
        
        NSMutableArray *candidateDescriptions = [[NSMutableArray alloc] initWithCapacity:[candidates count]];
        for (id<ALCBuilder> builder in candidates) {
            [candidateDescriptions addObject:[builder description]];
        }
        
        @throw [NSException exceptionWithName:@"AlchemicTooManyCandidates"
                                       reason:[NSString stringWithFormat:@"Expecting 1 object, but found %lu: %@", [candidates count], [candidateDescriptions componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }
    
}

@end
