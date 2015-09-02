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

-(instancetype) initWithValueSource:(id<ALCValueSource>) valueSource {
    return nil;
}

-(instancetype) initWithVariable:(Ivar)variable
                     valueSource:(id<ALCValueSource>)valueSource {
    self = [super initWithValueSource:valueSource];
    if (self) {
        _variable = variable;
    }
    return self;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {
    // Variable dependencies start a new stack because they are injected after instantiation and therefore break any possible loops.
    STLog(self.valueClass, @"Starting new stack for circular dependency detection");
    [super resolveWithPostProcessors:postProcessors dependencyStack:[NSMutableArray array]];
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