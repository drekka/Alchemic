//
//  ALCVariableDependency.m
//  alchemic
//
//  Created by Derek Clarkson on 26/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependency.h"

@implementation ALCVariableDependency

-(instancetype) initWithContext:(__weak ALCContext *) context
                       variable:(Ivar) variable
                      valueType:(ALCType *) valueType
                       matchers:(NSSet *) dependencyMatchers {
    self = [super initWithContext:context
                        valueType:valueType
                         matchers:dependencyMatchers];
    if (self) {
        _variable = variable;
    }
    return self;
}


@end
