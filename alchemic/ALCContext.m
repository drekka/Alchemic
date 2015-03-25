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
    [self connectDependencies];
    
    // Now initiate the objects.
    [self instantiateObjects];
    
    // And inject the dependencies.
    [self injectDependencies];
    
}

-(void) connectDependencies {
    logRegistration(@"Connecting dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop){
        logDependencyResolving(@"Resolving dependencies in %s", class_getName(description.forClass));
        [description resolveDependenciesUsingResolvers:_dependencyResolvers];
    }];
}

-(void) instantiateObjects {
    logCreation(@"Instantiating objects ...");
        [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *description, BOOL *stop) {
            if (description.finalObject == nil) {
                logCreation(@"Instantiating a %s", class_getName(description.forClass));
                [description instantiateUsingFactories:_objectFactories];
            }
        }];
}

-(void) injectDependencies {
    logCreation(@"Injecting dependencies into objects ...");
    [_objects enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCObjectDescription *decription, BOOL *stop) {
        
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
    [_objectFactories addObject:objectFactory];
}

-(void) addInitialisationStrategy:(id<ALCInitialisationStrategy>) initialisationStrategy {
    logConfig(@"Adding init strategy: %s", class_getName([initialisationStrategy class]));
    [_initialisationStrategies addObject:initialisationStrategy];
}

-(void) addDependencyResolver:(id<ALCDependencyResolver>) dependencyResolver {
    logConfig(@"Adding dependency resolver: %s", class_getName([dependencyResolver class]));
    [_dependencyResolvers addObject:dependencyResolver];
}

@end
