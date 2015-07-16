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

-(nonnull instancetype) initWithVariable:(nonnull Ivar)variable
                             valueSource:(nonnull id<ALCValueSource>)valueSource {
    self = [super initWithValueClass:[ALCRuntime iVarClass:variable]
                         valueSource:valueSource];
    if (self) {
        STLog(self.valueClass, @"Registering variable dependency: %s from source: %@", ivar_getName(variable), valueSource);
        _variable = variable;
    }
    return self;
}

-(void) injectInto:(id) object {
    STLog([object class], @"Injecting -[%s %s] with a %s",object_getClassName(object), ivar_getName(self.variable), object_getClassName(self.valueClass));
    [ALCRuntime object:object injectVariable:self.variable withValue:self.value];
}

-(NSString *) description {
    NSString *desc = [super description];
    return [NSString stringWithFormat:@"%2$s = %1$@", desc, ivar_getName(_variable)];
}

@end
