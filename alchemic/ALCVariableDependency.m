//
//  ALCVariableDependency.m
//  alchemic
//
//  Created by Derek Clarkson on 26/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependency.h"
#import <StoryTeller/StoryTeller.h>
#import "NSObject+Builder.h"
#import "ALCValueSource.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCVariableDependency

hideInitializerImpl(initWithValueSource:(id<ALCValueSource>) valueSource)

-(instancetype) initWithVariable:(Ivar)variable
                     valueSource:(id<ALCValueSource>)valueSource {
    self = [super initWithValueSource:valueSource];
    if (self) {
        self.valueSource.startsResolvingStack = YES;
        _variable = variable;
    }
    return self;
}

-(void) injectInto:(id) object {
    STLog([object class], @"Injecting %@.%s with a %@", NSStringFromClass([object class]), ivar_getName(self.variable), [ALCRuntime aClassDescription:self.valueSource.valueClass]);
    [object injectVariable:self.variable withValue:self.value];
}

-(NSString *) description {
    NSString *desc = [super description];
    return [NSString stringWithFormat:@"%s = %@", ivar_getName(_variable), desc];
}

@end

NS_ASSUME_NONNULL_END