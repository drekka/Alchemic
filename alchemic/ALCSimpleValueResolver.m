//
//  ALCSimpleDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleValueResolver.h"

@import ObjectiveC;

#import "ALCDependency.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCType.h"

@implementation ALCSimpleValueResolver

-(BOOL) canResolveValueForDependency:(ALCDependency *)dependency candidates:(NSSet *)candidates {
    return YES;
}

-(id) resolveCandidateValues:(NSSet<id<ALCBuilder>> *) candidates {
    
    if ([candidates count] == 1) {
        return [[candidates anyObject] value];
    }
    
    NSMutableArray<NSString *> *candidateDescriptions = [[NSMutableArray alloc] initWithCapacity:[candidates count]];
    for (id<ALCBuilder> builder in candidates) {
        [candidateDescriptions addObject:[builder description]];
    }
    
    @throw [NSException exceptionWithName:@"AlchemicTooManyCandidates"
                                   reason:[NSString stringWithFormat:@"Expecting 1 object, but found %lu: %@", [candidates count], [candidateDescriptions componentsJoinedByString:@", "]]
                                 userInfo:nil];
}

@end
