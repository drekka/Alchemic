//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCInstance.h"
@import ObjectiveC;

#import "ALCVariableDependency.h"
#import "ALCRuntime.h"
#import "ALCObjectFactory.h"
#import "ALCLogger.h"

@implementation ALCInstance {
    NSMutableSet *_dependencies;
    NSArray *_initialisationStrategies;
}

-(instancetype) initWithContext:(__weak ALCContext *) context objectClass:(Class) objectClass {
    self = [super initWithContext:context objectClass:objectClass];
    if (self) {
        _initialisationStrategies = @[];
        _dependencies = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark - Adding dependencies

-(void) addDependency:(NSString *) inj, ... {
    
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
    
    [self addDependency:inj withMatchers:finalMatchers];
}

-(void) addDependency:(NSString *) inj withMatchers:(NSSet *) matchers {
    // Create the dependency info to be store.
    Ivar variable = [ALCRuntime class:self.objectClass variableForInjectionPoint:inj];
    [_dependencies addObject:[[ALCVariableDependency alloc] initWithVariable:variable inModelObject:self matchers:matchers]];
}

#pragma mark - Lifecycle

-(void) resolveDependencies {
    
    logDependencyResolving(@"Resolving dependencies for %@", [self description]);
    for (ALCVariableDependency *dependency in _dependencies) {
        [dependency resolveUsingModel:self.context.model];
    }
    
    logRegistration(@"Post processing dependencies for %@", [self description]);
    for (ALCVariableDependency *dependency in _dependencies) {
        [dependency postProcess:self.context.resolverPostProcessors];
    }
}

-(void) instantiateObject {
    
    if (!self.instantiate || self.object != nil) {
        logCreation(@"Not instantiable or object already present.");
        return;
    }
    
    logCreation(@"Instantiating %@", [self description]);
    for (id<ALCObjectFactory> objectFactory in self.context.objectFactories) {
        self.object = [objectFactory createObjectFromInstance:self];
        if (self.objectClass != nil) {
            break;
        }
    }
    
    if (self.object == nil) {
        @throw [NSException exceptionWithName:@"AlchemicUnableToCreateInstance"
                                       reason:[NSString stringWithFormat:@"Unable to create an instance of %@", [self description]]
                                     userInfo:nil];
    }
    
    [self injectDependenciesInto:self.object];    
}

-(void) injectDependenciesInto:(id) object {
    logDependencyResolving(@"Checking %@ for dependencies", [self description]);
    for (ALCVariableDependency *dependency in _dependencies) {
        [dependency injectObject:object usingInjectors:self.context.dependencyInjectors];
    }
}

-(void) addInitStrategy:(id<ALCInitStrategy>) initialisationStrategy {
    _initialisationStrategies = [_initialisationStrategies arrayByAddingObject:initialisationStrategy];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Object '%@' (%s)", self.name, class_getName(self.objectClass)];
}

@end
