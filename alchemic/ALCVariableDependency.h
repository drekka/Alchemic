//
//  ALCVariableDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 26/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCDependency.h"
@import ObjectiveC;

@interface ALCVariableDependency : ALCDependency

@property (nonatomic, assign, readonly) Ivar variable;

-(instancetype) initWithContext:(__weak ALCContext *) context
                       variable:(Ivar) variable
                      valueType:(ALCType *) valueType
                       matchers:(NSSet *) dependencyMatchers NS_DESIGNATED_INITIALIZER;

-(void) injectInto:(id) object;

@end
