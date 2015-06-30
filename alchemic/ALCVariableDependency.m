//
//  ALCVariableDependency.m
//  alchemic
//
//  Created by Derek Clarkson on 26/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependency.h"
#import "ALCRuntime.h"
#import <StoryTeller/StoryTeller.h>

@implementation ALCVariableDependency

-(instancetype) initWithContext:(__weak ALCContext *) context
                       variable:(Ivar) variable
                      valueType:(ALCType *) valueType
                       matchers:(NSSet<id<ALCMatcher>> *) dependencyMatchers {
    self = [super initWithContext:context
                        valueType:valueType
                         matchers:dependencyMatchers];
    if (self) {
        _variable = variable;
    }
    return self;
}

-(void) injectInto:(id) object {
    id value = self.value;
    STLog([object class], @"   Injecting %s::%s <- %s",object_getClassName(object) , ivar_getName(self.variable), object_getClassName(value));
    [ALCRuntime injectObject:object variable:self.variable withValue:value];
}

-(NSString *) description {
    NSString *desc = [super description];
    return [NSString stringWithFormat:@"%2$s = %1$@", desc, ivar_getName(_variable)];
}

@end