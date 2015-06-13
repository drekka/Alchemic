//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassBuilder.h"
@import ObjectiveC;

#import "ALCRuntime.h"
#import "ALCLogger.h"
#import "ALCType.h"
#import "ALCVariableDependency.h"
#import "ALCClassBuilder.h"

@implementation ALCClassBuilder {
    NSArray<id<ALCInitStrategy>> *_initialisationStrategies;
}

-(instancetype) initWithContext:(ALCContext *__weak)context valueType:(ALCType *)valueType {
    self = [super initWithContext:context valueType:valueType];
    if (self) {
        _initialisationStrategies = @[];
    }
    return self;
}

#pragma mark - Adding dependencies

-(void) addInjectionPoint:(NSString *) inj withMatchers:(NSSet *) matchers {
    Class objClass = self.valueType.typeClass;
    Ivar variable = [ALCRuntime class:objClass variableForInjectionPoint:inj];
    ALCType *type = [ALCType typeForInjection:variable inClass:objClass];
    ALCVariableDependency *dependency = [[ALCVariableDependency alloc] initWithContext:self.context
                                                                              variable:variable
                                                                             valueType:type
                                                                              matchers:matchers];
    [self addDependency:dependency];
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

    logCreation(@"   instantiating instance using %@", self);
    ALCContext *strongContext = self.context;
    for (id<ALCObjectFactory> objectFactory in strongContext.objectFactories) {
        id newValue = [objectFactory createObjectFromBuilder:self];
        if (newValue != nil) {
            return newValue;
        }
    }
    
    // Trigger an exception if we don't create anything.
    @throw [NSException exceptionWithName:@"AlchemicUnableToCreateInstance"
                                   reason:[NSString stringWithFormat:@"Unable to create an instance of %@", [self description]]
                                 userInfo:nil];
}

-(void) injectDependenciesInto:(id) object {
    for (ALCVariableDependency *dependency in self.dependencies) {
        [dependency injectInto:object];
    }
}

-(void) addInitStrategy:(id<ALCInitStrategy>) initialisationStrategy {
    _initialisationStrategies = [_initialisationStrategies arrayByAddingObject:initialisationStrategy];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Class builder for %s%@", class_getName(self.valueType.typeClass), self.isFactory ? @" (factory)" : @""];
}

@end
