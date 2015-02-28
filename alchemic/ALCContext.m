//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCContext.h"
#import "ALCLogger.h"
#import "ALCRuntime.h"
#import <objc/runtime.h>
#import "ALCClassInfo.h"
#import "ALCObjectFactory.h"
#import "ALCSimpleObjectFactory.h"
#import "ALCInitialisationStrategyInjector.h"
#import "ALCSimpleObjectInjector.h"
#import "ALCNSObjectInitialisationStrategy.h"
#import "ALCUIViewControllerInitWithCoderInitStrategy.h"
#import "ALCUIViewControllerInitWithFrameInitialisationStrategy.h"

@implementation ALCContext {
    
    // Injectors
    id<ALCInitialisationInjector> _runtimeInjector;
    id<ALCObjectInjector> _objectInjector;
    
    // Registry of classes that have registered dependencies.
    NSMutableDictionary *_injectionRegistry;
    
    // Registry of singletons.
    NSMutableArray *_singletonRegistry;
    
    // Storage for objects created by alchemic.
    NSMutableDictionary *_dependencyStore;
    
    // List of factories for creating objects.
    NSMutableArray *_objectFactories;
    
}

-(void) start {
    
    // Set defaults.
    if (_runtimeInjectorClass == NULL) {
        _runtimeInjectorClass = [ALCInitialisationStrategyInjector class];
    }
    if (_objectInjectorClass == NULL) {
        _objectInjectorClass = [ALCSimpleObjectInjector class];
    }
    
    // Create runtime injector instance and add strategies for handling various inits.
    _runtimeInjector = [[(Class)self.runtimeInjectorClass alloc] init];
    [_runtimeInjector addInitWrapperStrategy:[[ALCNSObjectInitialisationStrategy alloc] init]];
    [_runtimeInjector addInitWrapperStrategy:[[ALCUIViewControllerInitWithCoderInitStrategy alloc] init]];
    [_runtimeInjector addInitWrapperStrategy:[[ALCUIViewControllerInitWithFrameInitialisationStrategy alloc] init]];

    // Create object injector for injecting dependencies into objects.
    _objectInjector = [[(Class)self.objectInjectorClass alloc] init];
    
    // Create factories.
    [_objectFactories addObject:[[ALCSimpleObjectFactory alloc] init]];
    
    // Inject wrappers into the runtime.
    [_runtimeInjector addHooksToClasses:_injectionRegistry.allKeys withContext:self];
    
    // Now initiate any found singletons.
    [self startSingletons];
    
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _injectionRegistry = [[NSMutableDictionary alloc] init];
        _dependencyStore = [[NSMutableDictionary alloc] init];
        _singletonRegistry = [[NSMutableArray alloc] init];
        _objectFactories = [[NSMutableArray alloc] init];
    }
    return self;
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

-(void) registerSingleton:(Class) singleton {
    logRegistration(@"Registering singleton: %@", NSStringFromClass(singleton));
    [_singletonRegistry addObject:[[ALCClassInfo alloc] initWithClass:singleton]];
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

-(void) resolveDependencies:(id) object {
    logClassProcessing(@"Being asked to resolve dependencies for a %s", class_getName([object class]));
}

@end
