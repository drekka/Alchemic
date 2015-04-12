//
//  ALCDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCInstance;
#import <objc/runtime.h>
#import "ALCMatcher.h"

/**
 Container object for information about an injection.
 */
@interface ALCDependency : NSObject

@property (nonatomic, assign, readonly) Ivar variable;
@property (nonatomic, assign, readonly) Class variableClass;
@property (nonatomic, strong, readonly) NSArray *variableProtocols;

@property (nonatomic, strong, readonly) NSArray *candidateObjectDescriptions;

-(instancetype) initWithVariable:(Ivar) variable matchers:(NSArray *) dependencyMatchers;

-(void) resolveUsingModel:(NSDictionary *) model;

-(void) injectObject:(id) finalObject usingInjectors:(NSArray *) injectors;

@end
