//
//  ALCSimpleDependencyInjector.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCSimpleDependencyInjector.h"

#import "ALCDependency.h"
@import ObjectiveC;
#import "ALCLogger.h"
#import "ALCInstance.h"

@implementation ALCSimpleDependencyInjector

-(BOOL) injectObject:(id) finalObject dependency:(ALCDependency *) dependency {
    return [self injectObject:finalObject
                     variable:dependency.variable
                    withValue:[dependency.candidateInstances anyObject]];
}

@end
