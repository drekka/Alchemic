//
//  ALCDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCResolvableObject;
@import ObjectiveC;

#import "ALCMatcher.h"
#import "ALCDependency.h"
#import "ALCResolvable.h"

/**
 Container object for information about an injection.
 */
@interface ALCVariableDependency : ALCDependency

@property (nonatomic, assign, readonly) Ivar variable;
@property (nonatomic, assign, readonly) char variableType;
@property (nonatomic, assign, readonly) Class variableClass;
@property (nonatomic, strong, readonly) NSArray *variableProtocols;

-(instancetype) initWithVariable:(Ivar) variable
              inResolvableObject:(__weak ALCResolvableObject *) resolvableObject
                        matchers:(NSSet *) dependencyMatchers;

@end
