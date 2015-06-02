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
#import "ALCObjectFactory.h"
#import "ALCVariableDependency.h"
#import "ALCLogger.h"
#import "ALCType.h"

@implementation ALCClassBuilder {
    NSArray *_initialisationStrategies;
}

-(instancetype) initWithContext:(ALCContext *__weak)context valueType:(ALCType *)valueType {
    self = [super initWithContext:context valueType:valueType];
    if (self) {
        _initialisationStrategies = @[];
    }
    return self;
}

#pragma mark - Adding dependencies

-(void) addInjectionPoint:(NSString *) inj, ... {
    
    va_list args;
    va_start(args, inj);
    NSMutableSet *finalMatchers;
    id matcher = va_arg(args, id);
    while (matcher != nil) {
        
        [ALCRuntime validateMatcher:matcher];
        
        if (finalMatchers == nil) {
            finalMatchers = [[NSMutableSet alloc] init];
        }
        [finalMatchers addObject:matcher];
        matcher = va_arg(args, id);
    }
    va_end(args);
    
    [self addInjectionPoint:inj withMatchers:finalMatchers];
}

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

#pragma mark - Properties

-(id) value {
    
    id value = super.value;
    if (value != nil) {
        return value;
    }
    
    value = [self instantiate];
    [self injectDependenciesInto:value];
    return value;
}

-(id) instantiate {
    
    // Ignore where another model reference has already created the object.
    id value = super.value;
    if (value != nil) {
        return nil;
    }
    
    logCreation(@"Instantiating %@", self);
    
    ALCContext *strongContext = self.context;
    for (id<ALCObjectFactory> objectFactory in strongContext.objectFactories) {
        id newValue = [objectFactory createObjectFromBuilder:self];
        if (newValue != nil) {

            // Set the value if this is not a factory.
            if (! super.factory) {
                super.value = newValue;
            }
            
            return newValue;
        }
    }
    
    // Trigger an exception if we don't create anything.
    @throw [NSException exceptionWithName:@"AlchemicUnableToCreateInstance"
                                   reason:[NSString stringWithFormat:@"Unable to create an instance of %@", [self description]]
                                 userInfo:nil];
}

-(void) injectDependenciesInto:(id) object {
    
    if ([self.dependencies count] == 0) {
        return;
    }
    
    logDependencyResolving(@"Injecting %2$lu dependencies into a %1$s defined in %3$@", object_getClassName(object), [self.dependencies count], [self description]);
    for (ALCVariableDependency *dependency in self.dependencies) {
        id value = dependency.value;
        logDependencyResolving(@"   %s::%s <- %s",object_getClassName(object) , ivar_getName(dependency.variable), object_getClassName(value));
        [ALCRuntime injectObject:object variable:dependency.variable withValue:value];
    }
}

-(void) addInitStrategy:(id<ALCInitStrategy>) initialisationStrategy {
    _initialisationStrategies = [_initialisationStrategies arrayByAddingObject:initialisationStrategy];
}

-(NSString *) description {
    return [NSStringFromClass(self.valueType.typeClass) stringByAppendingString:self.singleton ? @" (singleton)" : @""];
}

@end
