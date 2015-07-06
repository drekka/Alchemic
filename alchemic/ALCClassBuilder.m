//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassBuilder.h"

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCRuntime.h"
#import "ALCVariableDependency.h"
#import "ALCClassBuilder.h"
#import <Alchemic/ALCObjectFactory.h>
#import <Alchemic/ALCContext.h>
#import "ALCContext+Internal.h"

@implementation ALCClassBuilder {
    NSArray<id<ALCInitStrategy>> *_initialisationStrategies;
    NSMutableSet<ALCVariableDependency*> *_dependencies;
}

-(instancetype) initWithContext:(ALCContext *__weak)context
                     valueClass:(__unsafe_unretained Class) valueClass
                           name:(NSString * __nonnull)name {
    self = [super initWithContext:context valueClass:valueClass name:name];
    if (self) {
        _initialisationStrategies = @[];
        _dependencies = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark - Adding dependencies

-(void) addInjectionPoint:(NSString *) inj withQualifiers:(NSSet *) qualifiers {

    Ivar variable = [ALCRuntime class:self.valueClass variableForInjectionPoint:inj];
    NSSet<ALCQualifier *>* finalQualifiers = qualifiers == nil || [qualifiers count] == 0 ? [ALCRuntime qualifiersForVariable:variable] : qualifiers;
    ALCVariableDependency *dependency = [[ALCVariableDependency alloc] initWithContext:self.context
                                                                              variable:variable
                                                                            qualifiers:finalQualifiers];
    [_dependencies addObject:dependency];
}

#pragma mark - Instantiating

-(id) value {
    id returnValue = super.value;
    if (returnValue == nil) {
        returnValue = [self instantiate];
        [self injectDependenciesInto:returnValue];
    }
    return returnValue;
}

-(id) resolveValue {
    ALCContext *strongContext = self.context;
    return [strongContext instantiateObjectFromBuilder:self];
}

-(void) injectDependenciesInto:(id) object {
    STLog(self, @"Injecting dependencies into a %s", [object class]);
    for (ALCVariableDependency *dependency in _dependencies) {
        [dependency injectInto:object];
    }
}

-(void) addInitStrategy:(id<ALCInitStrategy>) initialisationStrategy {
    _initialisationStrategies = [_initialisationStrategies arrayByAddingObject:initialisationStrategy];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Class builder for %s%@", class_getName(self.valueClass), self.factory ? @" (factory)" : @""];
}

@end
