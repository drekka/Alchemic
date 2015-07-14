//
//  ALCSimpleDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleValueStrategy.h"

@import ObjectiveC;

#import <Alchemic/ALCDependency.h>
#import <StoryTeller/StoryTeller.h>

@implementation ALCSimpleValueStrategy

-(BOOL) canResolveValueForDependency:(ALCDependency *) dependency values:(NSSet<id> *) values {
    return YES;
}

-(id) resolveValues:(NSSet<id> *) values {
    
    if ([values count] == 1) {
        return values.anyObject;
    }
    
    @throw [NSException exceptionWithName:@"AlchemicTooManyCandidates"
                                   reason:[NSString stringWithFormat:@"Expecting 1 object, but found %lu", (unsigned long)[values count]]
                                 userInfo:nil];
}

@end
