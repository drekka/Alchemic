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

#import "ALCClassInfo.h"
#import "ALCInitialisationStrategyInjector.h"

#import "ALCObjectInjector.h"
#import "ALCSimpleObjectInjector.h"

#import "ALCClassDependencyResolver.h"
#import "ALCProtocolDependencyResolver.h"
#import "ALCDependencyInfo.h"

#import "ALCObjectFactory.h"
#import "ALCSimpleObjectFactory.h"

#import "ALCNSObjectInitStrategy.h"
#import "ALCUIViewControllerInitWithCoderStrategy.h"
#import "ALCUIViewControllerInitWithFrameStrategy.h"

@implementation ALCContext {
    NSMutableArray *_initialisationStrategies;
    NSMutableArray *_dependencyResolvers;
    NSMutableArray *_objectInjectors;
    NSMutableArray *_objectFactories;
    NSMutableDictionary *_model;
    NSMutableDictionary *_objects;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        
        logConfig(@"Initing context");

        _initialisationStrategies = [[NSMutableArray alloc] init];
        [self addInitialisationStrategy:[[ALCNSObjectInitStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithCoderStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithFrameStrategy alloc] init]];
        
        _objectFactories = [[NSMutableArray alloc] init];
        [self addObjectFactory:[[ALCSimpleObjectFactory alloc] initWithContext:self]];

        _objectInjectors = [[NSMutableArray alloc] init];
        [self addObjectInjector:[[ALCSimpleObjectInjector alloc] init]];

        _dependencyResolvers = [[NSMutableArray alloc] init];
        [self addDependencyResolver:[[ALCProtocolDependencyResolver alloc] initWithModel:_model]];
        [self addDependencyResolver:[[ALCClassDependencyResolver alloc] initWithModel:_model]];
        
        // Create storage for objects.
        _model = [[NSMutableDictionary alloc] init];
        _objects = [[NSMutableDictionary alloc] init];
        
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
    
    // Now initiate any found singletons.
    [self instantiateObjects];
    
}

-(void) connectDependencies {
    logRegistration(@"Connecting dependencies ...");
}

-(void) instantiateObjects {
    logCreation(@"Instantiating objects ...");
        [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCClassInfo *info, BOOL *stop) {
            if (_objects[name] == nil) {
                logCreation(@"--- Instantiating a %s", class_getName(info.forClass));
                _objects[name] = [self objectForClassInfo:info];
            }
        }];
}

#pragma mark - The model

-(void) registerClass:(Class) class withInjectionPoints:(NSString *) injs, ... {
    va_list args;
    va_start(args, injs);
    for (NSString *arg = injs; arg != nil; arg = va_arg(args, NSString *)) {
        [self registerInjection:arg inClass:class withName:NSStringFromClass(class)];
    }
    va_end(args);
}

-(void) registerClass:(Class) class withName:(NSString *) name withInjectionPoints:(NSString *) injs, ... {
    va_list args;
    va_start(args, injs);
    for (NSString *arg = injs; arg != nil; arg = va_arg(args, NSString *)) {
        [self registerInjection:arg inClass:class withName:name];
    }
    va_end(args);
}

-(void) registerClass:(Class)class {
    [self registerClass:class withName:NSStringFromClass(class)];
}

-(void) registerClass:(Class)class withName:(NSString *)name {
    [self createInfoForClass:class withName:name];
}

-(void) registerInjection:(NSString *) inj inClass:(Class) class {
    [self registerInjection:inj inClass:class withName:NSStringFromClass(class)];
}

-(void) registerInjection:(NSString *) inj inClass:(Class) class withName:(NSString *)name {
    ALCClassInfo *info = [self infoForClass:class name:name];
    Ivar variable = [ALCRuntime variableInClass:class forInjectionPoint:[inj UTF8String]];
    ALCDependencyInfo *dependencyInfo = [[ALCDependencyInfo alloc] initWithVariable:variable parentClass:class];
    [info addDependency:dependencyInfo];
}

-(ALCClassInfo *) createInfoForClass:(Class) forClass withName:(NSString *) name {
    if (_model[name] != nil) {
        @throw [NSException exceptionWithName:@"AlchemicDuplicateObjectName"
                                       reason:[NSString stringWithFormat:@"Cannot register more than one object with name: %@", name]
                                     userInfo:nil];
    }
    logRegistration(@"Registering: %@ (%s)", name, class_getName(forClass));
    return [self infoForClass:forClass name:name];
}

-(ALCClassInfo *) infoForClass:(Class) forClass name:(NSString *) name {
    ALCClassInfo *info = _model[name];
    if (info == nil) {
        info = [[ALCClassInfo alloc] initWithClass:forClass name:name];
        _model[name] = info;
    }
    return info;
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

-(id) objectForClassInfo:(ALCClassInfo *) classInfo {
    __block id createdObject = nil;
    for (id<ALCObjectFactory> objectFactory in _objectFactories) {
        createdObject = [objectFactory createObjectFromClassInfo:classInfo];
        if (createdObject) {
            return createdObject;
        }
    }
    return nil;
}

#pragma mark - Configuration

-(void) addObjectInjector:(id<ALCObjectInjector>) objectInjector {
    logConfig(@"Adding object injector: %s", class_getName([objectInjector class]));
    [_objectInjectors addObject:objectInjector];
}

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
