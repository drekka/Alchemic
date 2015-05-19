//
//  ALCResolver.h
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCMatcher.h"

@interface ALCDependency : NSObject

@property (nonatomic, strong, readonly) NSSet *candidates;
@property (nonatomic, strong) NSSet *dependencyMatchers;

-(instancetype) initWithMatchers:(NSSet *) dependencyMatchers;

-(instancetype) initWithMatcher:(id<ALCMatcher>) dependencyMatcher;

-(void) resolveUsingModel:(NSDictionary *) model;

-(void) postProcess:(NSSet *) postProcessors;

@end
