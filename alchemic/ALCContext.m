//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <objc/runtime.h>

#import "Alchemic.h"
#import "ALCContext.h"
#import "ALCLogger.h"

#import "ALCRuntime.h"

#import "AlchemicAware.h"

#import "ALCInstance.h"
#import "ALCInitialisationStrategyInjector.h"

#import "ALCClassDependencyResolver.h"
#import "ALCProtocolDependencyResolver.h"
#import "ALCNameDependencyResolver.h"

#import "ALCDependency.h"

#import "ALCSimpleDependencyInjector.h"

#import "ALCObjectFactory.h"
#import "ALCSimpleObjectFactory.h"

#import "ALCNSObjectInitStrategy.h"
#import "ALCUIViewControllerInitWithCoderStrategy.h"
#import "ALCUIViewControllerInitWithFrameStrategy.h"

#import "NSDictionary+ALCModel.h"

@implementation ALCContext {
    NSMutableArray *_initialisationStrategies;
    NSMutableArray *_dependencyResolvers;
    NSMutableArray *_dependencyInjectors;
    NSMutableArray *_objectFactories;
    NSMutableDictionary *_model;
    NSMutableDictionary *_objects;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        
        logConfig(@"Initing context");
        
        // Create storage for objects.
        _model = [[NSMutableDictionary alloc] init];
        _objects = [[NSMutableDictionary alloc] init];
        
        _initialisationStrategies = [[NSMutableArray alloc] init];
        [self addInitialisationStrategy:[[ALCNSObjectInitStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithCoderStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithFrameStrategy alloc] init]];
        
        _objectFactories = [[NSMutableArray alloc] init];
        [self addObjectFactory:[[ALCSimpleObjectFactory alloc] initWithContext:self]];
        
        _dependencyResolvers = [[NSMutableArray alloc] init];
        [self addDependencyResolver:[[ALCProtocolDependencyResolver alloc] initWithModel:_model]];
        [self addDependencyResolver:[[ALCClassDependencyResolver alloc] initWithModel:_model]];
        [self addDependencyResolver:[[ALCNameDependencyResolver alloc] initWithModel:_model]];
        
        _dependencyInjectors = [[NSMutableArray alloc] init];
        [self addDependencyInjector:[[ALCSimpleDependencyInjector alloc] init]];
        
    }
    return self;
}

-(void) start {
    
    logRuntime(@"Starting alchemic");
    
    // Set defaults.
    if (self.runtimeInjector == nil) {
        self.runtimeInjector = [[ALCInitialisationStrategyInjector alloc] initWithStrategies:_initialisationStrategies];
    }
    
    // Inject wrappers into the singletons that have registered for dependency injection.
    [_runtimeInjector executeStrategiesOnObjects:_objects withContext:self];
    
    // Now boot up the model.
    [self resolveDependencies];
    [self instantiateObjects];
    [self injectModelDependencies];
    
}

-(void) resolveDependencies {
    logDependencyResolving(@"Resolving dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *description, BOOL *stop){
        logDependencyResolving(@"Resolving dependencies in '%@' (%s)", name, class_getName(description.forClass));
        Class class = description.forClass;
        [ALCRuntime class:class resolveDependenciesWithResolvers:_dependencyResolvers];
    }];
}

-(void) instantiateObjects {
    
    logCreation(@"Instantiating objects ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *description, BOOL *stop) {
        
        if (description.finalObject == nil) { // Allow for pre-built objects.
            
            logCreation(@"Instantiating '%@' (%s)", name, class_getName(description.forClass));
            for (id<ALCObjectFactory> objectFactory in _objectFactories) {
                description.finalObject = [objectFactory createObjectFromObjectDescription:description];
                if (description.finalObject != nil) {
                    break;
                }
            }
            
            if (description.finalObject == nil) {
                @throw [NSException exceptionWithName:@"AlchemicUnableToCreateInstance"
                                               reason:[NSString stringWithFormat:@"Unable to create an instance of %s", class_getName(description.forClass)]
                                             userInfo:nil];
            }
            
        }
    }];
}

-(void) injectModelDependencies {
    logDependencyResolving(@"Injecting dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *description, BOOL *stop) {
        logDependencyResolving(@"Injecting dependencies into '%@'", name);
        [ALCRuntime object:description.finalObject injectUsingDependencyInjectors:_dependencyInjectors];
    }];
}

-(void) injectDependencies:(id) object {
    logDependencyResolving(@"Resolving dependencies for a %s", class_getName([object class]));
    [ALCRuntime class:[object class] resolveDependenciesWithResolvers:_dependencyResolvers];
    logDependencyResolving(@"Injecting dependencies into a %s", class_getName([object class]));
    [ALCRuntime object:object injectUsingDependencyInjectors:_dependencyInjectors];
}

#pragma mark - Declaring injections

-(void) registerClass:(Class) class injectionPoints:(NSString *) injs, ... {
    va_list args;
    va_start(args, injs);
    for (NSString *inj = injs; inj != nil; inj = va_arg(args, NSString *)) {
        [self registerClass:class injectionPoint:inj qualifier:nil];
    }
    va_end(args);
}

-(void) registerClass:(Class) class injectionPoint:(NSString *) inj withQualifier:(NSString *) qualifier {
    [self registerClass:class injectionPoint:inj qualifier:qualifier];
}

-(void) registerClass:(Class) class injectionPoint:(NSString *) inj qualifier:(NSString *) qualifier {
    if (![ALCRuntime isClassDecorated:class]) {
        [ALCRuntime decorateClass:class];
    }
    [ALCRuntime class:class addInjection:inj withQualifier:qualifier];
}

#pragma mark - Registering classes

-(void) registerClass:(Class)class {
    [self objectDescriptionForClass:class withQualifier:NSStringFromClass(class)];
}

-(void) registerClass:(Class)class withName:(NSString *) name {
    [self objectDescriptionForClass:class withQualifier:name];
}

-(ALCInstance *) objectDescriptionForClass:(Class) class withQualifier:(NSString *) qualifier {
    ALCInstance *description = _model[qualifier];
    if (description == nil) {
        logRegistration(@"Creating info for '%2$s' (%1$@)", qualifier, class_getName(class));
        [ALCRuntime decorateClass:class];
        description = [[ALCInstance alloc] initWithClass:class];
        _model[qualifier] = description;
    }
    return description;
}

#pragma mark - Registering objects directly

-(void) registerObject:(id) finalObject withName:(NSString *) name {
    logCreation(@"Storing '%@' (%s)", name, class_getName([finalObject class]));
    ALCInstance *description = [self objectDescriptionForClass:[finalObject class] withQualifier:name];
    description.finalObject = finalObject;
}

#pragma mark - Objects

-(void) addObject:(id) object {
    [self addObject:object withName:NSStringFromClass([object class])];
}

-(void) addObject:(id) object withName:(NSString *)name {
    if (_objects[name] != nil) {
        @throw [NSException exceptionWithName:@"AlchemicDuplicateObjectName"
                                       reason:[NSString stringWithFormat:@"Cannot register more than one object with name: %@", name]
                                     userInfo:nil];
    }
    _objects[name] = object;
}

#pragma mark - Retrieving objects

-(id) objectWithName:(NSString *) name {
    return ((ALCInstance *)_model[name]).finalObject;
}

#pragma mark - Configuration

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory {
    logConfig(@"Adding object factory: %s", class_getName([objectFactory class]));
    [_objectFactories insertObject:objectFactory atIndex:0];
}

-(void) addInitialisationStrategy:(id<ALCInitialisationStrategy>) initialisationStrategy {
    logConfig(@"Adding init strategy: %s", class_getName([initialisationStrategy class]));
    [_initialisationStrategies insertObject:initialisationStrategy atIndex:0];
}

-(void) addDependencyResolver:(id<ALCDependencyResolver>) dependencyResolver {
    logConfig(@"Adding dependency resolver: %s", class_getName([dependencyResolver class]));
    [_dependencyResolvers insertObject:dependencyResolver atIndex:0];
}

-(void) addDependencyInjector:(id<ALCDependencyInjector>) dependencyinjector {
    logConfig(@"Adding dependency injector: %s", class_getName([dependencyinjector class]));
    [_dependencyInjectors insertObject:dependencyinjector atIndex:0];
}

@end
