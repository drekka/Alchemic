//
//  ALCDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCModelObjectInstance;
@import ObjectiveC;

#import "ALCMatcher.h"
#import "ALCDependencyResolver.h"
#import "ALCModelObject.h"

/**
 Container object for information about an injection.
 */
@interface ALCVariableDependencyResolver : ALCDependencyResolver

@property (nonatomic, assign, readonly) Ivar variable;
@property (nonatomic, assign, readonly) char variableType;
@property (nonatomic, assign, readonly) Class variableClass;
@property (nonatomic, strong, readonly) NSArray *variableProtocols;

-(instancetype) initWithVariable:(Ivar) variable inModelObject:(__weak ALCModelObjectInstance *) modelObject matchers:(NSSet *) dependencyMatchers;

-(void) injectObject:(id) object usingInjectors:(NSArray *) injectors;

@end
