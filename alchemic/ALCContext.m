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

#import "ALCClassInfo.h"
#import "ALCInitialisationStrategyInjector.h"

#import "ALCSimpleDependencyResolver.h"

#import "ALCObjectFactory.h"
#import "ALCSimpleObjectFactory.h"

#import "ALCNSObjectInitStrategy.h"
#import "ALCUIViewControllerInitWithCoderStrategy.h"
#import "ALCUIViewControllerInitWithFrameStrategy.h"

@implementation ALCContext {
    
    // List of strategies used to inject init methods.
    NSArray *_initialisationStrategies;
    
    // Resolvers.
    NSArray *_dependencyResolvers;
    
    // List of factories for creating objects.
    NSArray *_objectFactories;
    
    // Registry of singletons.
    NSArray *_singletonRegistry;
    
    // Storage for objects created by alchemic.
    NSMutableDictionary *_dependencyStore;
    
    // Registry of classes that have registered dependencies.
    NSMutableDictionary *_injectionRegistry;
    
    
}

-(instancetype) init {
    self = [super init];
    if (self) {

        _initialisationStrategies = [[NSArray alloc] init];
        _objectFactories = [[NSArray alloc] init];
        _dependencyResolvers = [[NSArray alloc] init];
        
        _injectionRegistry = [[NSMutableDictionary alloc] init];
        _dependencyStore = [[NSMutableDictionary alloc] init];
        _singletonRegistry = [[NSArray alloc] init];

        [self addInitialisationStrategy:[[ALCNSObjectInitStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithCoderStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithFrameStrategy alloc] init]];
        
        [self addObjectFactory:[[ALCSimpleObjectFactory alloc] initWithContext:self]];

        [self addDependencyResolver:[[ALCSimpleDependencyResolver alloc] init]];

    }
    return self;
}

-(void) start {
    
    // Set defaults.
    if (self.runtimeInjector == nil) {
        self.runtimeInjector = [[ALCInitialisationStrategyInjector alloc] init];
    }
    
    // Inject wrappers into the classes that have registered for dependency injection.
    [_runtimeInjector executeStrategies:_injectionRegistry.allKeys withContext:self];
    
    // Now initiate any found singletons.
    [self startSingletons];
    
}

-(void) startSingletons {
    
    logCreation(@"Creating singletons");
    [_singletonRegistry enumerateObjectsUsingBlock:^(ALCClassInfo *classInfo, NSUInteger classInfoIdx, BOOL *stopReadingSingletons){
        
        __block id createdObject = nil;
        [_objectFactories enumerateObjectsUsingBlock:^(id<ALCObjectFactory> objectFactory, NSUInteger factoryIdx, BOOL *stopCheckingFactories) {
            createdObject = [objectFactory createObjectFromClassInfo:classInfo];
            if (createdObject) {
                *stopCheckingFactories = YES;
            }
        }];
        
        if (createdObject == nil) {
            // Ok, throw an error.
            @throw [NSException exceptionWithName:@"AlchemicFailedToCreateSingleton"
                                           reason:[NSString stringWithFormat:@"Failed to create a singleton instance of %s", class_getName(classInfo.forClass)]
                                         userInfo:nil];
        }
        
        _dependencyStore[(id<NSCopying>)classInfo.forClass] = createdObject;
    }];
}

-(void) registerClass:(Class) class withInjectionPoints:(NSString *) injs, ... {
    va_list args;
    va_start(args, injs);
    for (NSString *arg = injs; arg != nil; arg = va_arg(args, NSString *)) {
        [self registerInjection: arg inClass:class];
    }
    va_end(args);
}

-(void) registerSingleton:(Class) singletonClass {
    logRegistration(@"Registering singleton: %@", NSStringFromClass(singletonClass));
    _singletonRegistry = [_singletonRegistry arrayByAddingObject:[[ALCClassInfo alloc] initWithClass:singletonClass]];
}

-(void) registerInjection:(NSString *) inj inClass:(Class) class {
    
    NSString *injectionPoint = [ALCRuntime findVariableInClass:class forInjectionPoint:[inj UTF8String]];
    
    NSMutableArray *injectionPoints = [_injectionRegistry objectForKey:class];
    if (injectionPoints == nil) {
        injectionPoints = [[NSMutableArray alloc] init];
        _injectionRegistry[(id<NSCopying>)class] = injectionPoints;
    }
    logRegistration(@"Registering injection %@.%@", NSStringFromClass(class), injectionPoint);
    [injectionPoints addObject:injectionPoint];
    
}

#pragma mark - Configuration

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory {
    logConfig(@"Adding object factory: %s", class_getName([objectFactory class]));
    _objectFactories = [_objectFactories arrayByAddingObject:objectFactory];
}

-(void) addInitialisationStrategy:(id<ALCInitialisationStrategy>) initialisationStrategy {
    logConfig(@"Adding init strategy: %s", class_getName([initialisationStrategy class]));
    _initialisationStrategies = [_initialisationStrategies arrayByAddingObject:initialisationStrategy];
}

-(void) addDependencyResolver:(id<ALCDependencyResolver>) dependencyResolver {
    logConfig(@"Adding dependency resolver: %s", class_getName([dependencyResolver class]));
    _dependencyResolvers = [_dependencyResolvers arrayByAddingObject:dependencyResolver];
}

#pragma mark - Dependency resolution

-(void) resolveDependencies:(id) object {
    logObjectResolving(@"Resolving dependencies in an instance of %s", class_getName([object class]));
}

@end
