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
#import "ALCValueSource.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCVariableDependency

-(instancetype) initWithValueClass:(Class) valueClass
							  valueSource:(id<ALCValueSource>) valueSource NS_UNAVAILABLE {
	return nil;
}

-(instancetype) initWithVariable:(Ivar)variable
                             valueSource:(id<ALCValueSource>)valueSource {
    self = [super initWithValueSource:valueSource];
    if (self) {
        _variable = variable;
        STLog(self.valueSource.valueClass, @"Created variable dependency: %@", self);
    }
    return self;
}

-(void) validateWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {
	// Ignore dependency checking when a variable dependency as these are injected later and do not trigger circular dependencies.
}

-(void) injectInto:(id) object {
    STLog([object class], @"Injecting %@.%s with a %@", NSStringFromClass([object class]), ivar_getName(self.variable), [ALCRuntime aClassDescription:self.valueSource.valueClass]);
    [ALCRuntime object:object injectVariable:self.variable withValue:self.value];
}

-(NSString *) description {
    NSString *desc = [super description];
    return [NSString stringWithFormat:@"%s = %@", ivar_getName(_variable), desc];
}

@end

NS_ASSUME_NONNULL_END