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
#import "ALCRuntimeFunctions.h"

#import "AlchemicAware.h"

#import "ALCObjectDescription.h"
#import "ALCInitialisationStrategyInjector.h"

#import "ALCClassDependencyResolver.h"
#import "ALCProtocolDependencyResolver.h"

#import "ALCDependency.h"

#import "ALCSimpleDependencyInjector.h"

#import "ALCObjectFactory.h"
#import "ALCSimpleObjectFactory.h"

#import "ALCNSObjectInitStrategy.h"
#import "ALCUIViewControllerInitWithCoderStrategy.h"
#import "ALCUIViewControllerInitWithFrameStrategy.h"

#import "NSDictionary+ALCModel.h"
#import "NSMutableDictionary+ALCModel.h"

@implementation ALCContext {
    NSMutableArray *_initialisationStrategies;
    NSMutableArray *_dependencyResolvers;
    NSMutableArray *_dependencyInjectors;
    NSMutableArray *_objectFactories;
    NSMutableDictionary *_model;
    NSMutableDictionary *_objects;
}

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
    
    // First we need to connect up all the dependencies.
    [self resolveDependencies];
    
    // Now initiate the objects and finishing injecting dependencies.
    [self instantiateObjects];
    [self injectDependencies];
    
}

-(void) resolveDependencies {
    logDependencyResolving(@"Resolving dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop){
        logDependencyResolving(@"Resolving dependencies in %s", class_getName(description.forClass));
        [description resolveDependenciesUsingResolvers:_dependencyResolvers];
    }];
}

-(void) instantiateObjects {
    logCreation(@"Instantiating objects ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop) {
        if (description.finalObject == nil) { // Allow for pre-built objects.
            logCreation(@"Instantiating %@ (%s)", description.name, class_getName(description.forClass));
            [description instantiateUsingFactories:_objectFactories];
        }
    }];
}

-(void) injectDependencies {
    logDependencyResolving(@"Injecting dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop) {
        logDependencyResolving(@"Injecting dependencies into %@", description.name);
        [description injectDependenciesUsingInjectors:_dependencyInjectors];
    }];
}

#pragma mark - The model

-(void) registerClass:(Class) class withInjectionPoints:(NSString *) injs, ... {
    va_list args;
    va_start(args, injs);
    for (NSString *arg = injs; arg != nil; arg = va_arg(args, NSString *)) {
        [_model registerInjection:arg inClass:class withName:NSStringFromClass(class)];
    }
    va_end(args);
}

-(void) registerClass:(Class) class withName:(NSString *) name withInjectionPoints:(NSString *) injs, ... {
    va_list args;
    va_start(args, injs);
    for (NSString *arg = injs; arg != nil; arg = va_arg(args, NSString *)) {
        [_model registerInjection:arg inClass:class withName:name];
    }
    va_end(args);
}

-(void) registerClass:(Class)class {
    [self registerClass:class withName:NSStringFromClass(class)];
}

-(void) registerClass:(Class)class withName:(NSString *)name {
    [_model objectDescriptionForClass:class name:name];
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
