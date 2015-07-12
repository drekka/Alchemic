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

-(instancetype) initWithContext:(ALCContext *__weak __nonnull)context
                     valueClass:(__unsafe_unretained __nonnull Class) valueClass
                           name:(NSString * __nonnull)name {
    self = [super initWithContext:context valueClass:valueClass name:name];
    if (self) {
        _initialisationStrategies = @[];
        _dependencies = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark - Adding dependencies

-(void) addInjectionPoint:(NSString __nonnull *) inj withQualifiers:(NSSet __nonnull *) qualifiers {

    Ivar variable = [ALCRuntime aClass:self.valueClass variableForInjectionPoint:inj];
    NSSet<ALCQualifier *>* finalQualifiers = qualifiers == nil || [qualifiers count] == 0 ? [ALCRuntime qualifiersForVariable:variable] : qualifiers;
    ALCVariableDependency *dependency = [[ALCVariableDependency alloc] initWithContext:self.context
                                                                              variable:variable
                                                                            qualifiers:finalQualifiers];
    [_dependencies addObject:dependency];
}

#pragma mark - Instantiating

-(void) resolveDependencies {
    ALCContext *strongContext = self.context;
    [_dependencies enumerateObjectsUsingBlock:^(ALCVariableDependency * __nonnull dependency, BOOL * __nonnull stop) {
        [strongContext resolveDependency:dependency];
    }];
}

-(nonnull id) instantiateObject {
    STLog(self.valueClass, @"Creating a %@", NSStringFromClass(self.valueClass));
    ALCContext *strongContext = self.context;
    return [strongContext instantiateObjectFromBuilder:self];
}

-(void) injectObjectDependencies:(id __nonnull) object {
    STLog([object class], @">>> Injecting %lu dependencies into a %s instance", [_dependencies count], object_getClassName(object));
    for (ALCVariableDependency *dependency in _dependencies) {
        [dependency injectInto:object];
    }
}

#pragma mark - Init strategies

-(void) addInitStrategy:(id<ALCInitStrategy> __nonnull) initialisationStrategy {
    _initialisationStrategies = [_initialisationStrategies arrayByAddingObject:initialisationStrategy];
}

-(nonnull NSString *) description {
    return [NSString stringWithFormat:@"Class %@ for type %s", self.factory ? @"factory" : @"builder", class_getName(self.valueClass)];
}

@end
