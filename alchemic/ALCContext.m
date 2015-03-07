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
    
    // Storage for objects created by alchemic.
    NSMutableDictionary *_dependencyStore;
    
    // Registry of classes that have registered dependencies.
    NSMutableDictionary *_classRegistry;
    
}

-(instancetype) init {
    self = [super init];
    if (self) {
        
        _initialisationStrategies = @[];
        [self addInitialisationStrategy:[[ALCNSObjectInitStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithCoderStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithFrameStrategy alloc] init]];
        
        _objectFactories = @[];
        [self addObjectFactory:[[ALCSimpleObjectFactory alloc] initWithContext:self]];

        _dependencyResolvers = @[];
        [self addDependencyResolver:[[ALCSimpleDependencyResolver alloc] init]];

        _classRegistry = [[NSMutableDictionary alloc] init];
        _dependencyStore = [[NSMutableDictionary alloc] init];

    }
    return self;
}

-(void) start {
    
    // Set defaults.
    if (self.runtimeInjector == nil) {
        self.runtimeInjector = [[ALCInitialisationStrategyInjector alloc] initWithStrategies:_initialisationStrategies];
    }
    
    // Inject wrappers into the singletons that have registered for dependency injection.
    [_runtimeInjector executeStrategiesOnClasses:_classRegistry withContext:self];
    
    // Now initiate any found singletons.
    [self startSingletons];
    
}

-(void) startSingletons {
    
    logCreation(@"Creating singletons");
    [_classRegistry enumerateKeysAndObjectsUsingBlock:^(Class classKey, ALCClassInfo *classInfo, BOOL *stopReadingSingletons) {
        
        if (!classInfo.isSingleton) {
            return;
        }
        
        logCreation(@"Creating singleton %s", class_getName(classInfo.forClass));
        
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
    ALCClassInfo *info = [self infoForClass:singletonClass];
    info.isSingleton = YES;
}

-(void) registerInjection:(NSString *) inj inClass:(Class) class {
    ALCClassInfo *info = [self infoForClass:class];
    NSString *injectionPoint = [ALCRuntime findVariableInClass:class forInjectionPoint:[inj UTF8String]];
    [info addInjectionPoint:injectionPoint];
    logRegistration(@"Registering injection %@.%@", NSStringFromClass(class), injectionPoint);
}

-(ALCClassInfo *) infoForClass:(Class) forClass {
    ALCClassInfo *info = _classRegistry[forClass];
    if (info == nil) {
        info = [[ALCClassInfo alloc] initWithClass:forClass];
        _classRegistry[(id<NSCopying>) forClass] = info;
    }
    return info;
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
