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

#import "ALCObjectStore.h"

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
    ALCObjectStore *_objectStore;
    NSMutableDictionary *_classRegistry;
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
        [self addDependencyResolver:[[ALCProtocolDependencyResolver alloc] initWithContext:self]];
        [self addDependencyResolver:[[ALCClassDependencyResolver alloc] initWithContext:self]];
        
        _classRegistry = [[NSMutableDictionary alloc] init];
        _objectStore = [[ALCObjectStore alloc] initWithContext:self];
        
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
    [_runtimeInjector executeStrategiesOnClasses:_classRegistry withContext:self];
    
    // Now initiate any found singletons.
    [self startSingletons];
    
}

-(void) startSingletons {
    logCreation(@"Creating singletons");
    [_objectStore instantiateSingletons];
}

#pragma mark - Registration

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
    [_objectStore addLazyInstantionForClass:info];
}

-(void) registerInjection:(NSString *) inj inClass:(Class) class {
    ALCClassInfo *info = [self infoForClass:class];
    Ivar variable = [ALCRuntime variableInClass:class forInjectionPoint:[inj UTF8String]];
    ALCDependencyInfo *dependencyInfo = [[ALCDependencyInfo alloc] initWithVariable:variable inClass:class];
    [info addDependency:dependencyInfo];
}

#pragma mark - Configuration

-(ALCClassInfo *) infoForClass:(Class) forClass {
    ALCClassInfo *info = _classRegistry[forClass];
    if (info == nil) {
        info = [[ALCClassInfo alloc] initWithClass:forClass];
        _classRegistry[(id<NSCopying>) forClass] = info;
    }
    return info;
}

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

#pragma mark - Dependency resolution

-(void) resolveDependencies:(id) object {
    
    Class objClass = [object class];
    ALCClassInfo *info = [self infoForClass:objClass];

    logObjectResolving(@"Resolving dependencies in an instance of %s", class_getName(objClass));
    [info.dependencies enumerateObjectsUsingBlock:^(ALCDependencyInfo *dependencyInfo, NSUInteger idx, BOOL *stop) {

        Ivar variable = dependencyInfo.variable;

        // Skip if something has already been injected.
        if (object_getIvar(object, variable) != nil) {
            logObjectResolving(@"Variable %s already resolved", ivar_getName(variable));
            return;
        }

        logObjectResolving(@"Resolving %s", ivar_getName(variable));
        NSArray *candidates = nil;
        for (id<ALCDependencyResolver> resolver in [_dependencyResolvers reverseObjectEnumerator]) {
            candidates = [resolver resolveDependency:dependencyInfo inObject:object withObjectStore:_objectStore];
            if (candidates != nil) {
                break;
            }
        }
        
        // Ok, throw an error.
        if (candidates == nil) {
            @throw [NSException exceptionWithName:@"AlchemicDependencyNotFound"
                                           reason:[NSString stringWithFormat:@"Unable resolve dependency: %s::%s", class_getName(objClass), ivar_getName(dependencyInfo.variable)]
                                         userInfo:nil];
        }
        
        // Call the injectors.
        for (id<ALCObjectInjector> injector in [_objectInjectors reverseObjectEnumerator]) {
            if ([injector inject:object dependency:dependencyInfo withCandidates:candidates]) {
                break;
            }
        }
        
    }];
    
    // Let the object know everything is resolved.
    if ([object conformsToProtocol:@protocol(AlchemicAware)]) {
        logObjectResolving(@"Calling %s::didResolveDependencies", class_getName(objClass));
        [object didResolveDependencies];
    }

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

@end
