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

#pragma mark - Lifecycle

-(void) resolve {
    
}

#pragma mark - Properties

-(id) value {
    if (super.value == nil) {
        [self instantiate];
        [self injectDependenciesInto:self];
    }
    return super.value;
}

-(id) instantiate {
    
    for (id<ALCObjectFactory> objectFactory in self.context.objectFactories) {
        super.value = [objectFactory createObjectFromBuilder:self];
        if (super.value != nil) {
            break;
        }
    }
    
    if (super.value == nil) {
        @throw [NSException exceptionWithName:@"AlchemicUnableToCreateInstance"
                                       reason:[NSString stringWithFormat:@"Unable to create an instance of %@", [self description]]
                                     userInfo:nil];
    }
    
    return super.value;
}

-(void) injectDependenciesInto:(id) object {
    
    if ([self.dependencies count] == 0) {
        return;
    }
    
    logDependencyResolving(@"Injecting a %s with %lu dependencies from %@", object_getClassName(object), [self.dependencies count], [self description]);
    for (ALCVariableDependency *dependency in self.dependencies) {
        [ALCRuntime injectObject:object variable:dependency.variable withValue:dependency.value];
    }
}

-(void) addInitStrategy:(id<ALCInitStrategy>) initialisationStrategy {
    _initialisationStrategies = [_initialisationStrategies arrayByAddingObject:initialisationStrategy];
}

-(NSString *) debugDescription {
    return [self description];
}

-(NSString *) description {
    return [NSStringFromClass(self.valueType.typeClass) stringByAppendingString:self.singleton ? @" (singleton)" : @""];
}

@end
