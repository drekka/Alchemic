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

#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"

#import "ALCDependency.h"

#import "ALCSimpleDependencyInjector.h"
#import "ALCArrayDependencyInjector.h"

#import "ALCObjectFactory.h"
#import "ALCSimpleObjectFactory.h"

#import "ALCNSObjectInitStrategy.h"
#import "ALCUIViewControllerInitWithCoderStrategy.h"
#import "ALCUIViewControllerInitWithFrameStrategy.h"

#import "NSMutableDictionary+ALCModel.h"

@implementation ALCContext {
    
    NSMutableArray *_initialisationStrategies;
    NSMutableArray *_dependencyInjectors;
    NSMutableArray *_objectFactories;
    
    NSMutableDictionary *_model;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        
        logConfig(@"Initing context");
        
        // Create storage for objects.
        _model = [[NSMutableDictionary alloc] init];
        
        _initialisationStrategies = [[NSMutableArray alloc] init];
        [self addInitialisationStrategy:[[ALCNSObjectInitStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithCoderStrategy alloc] init]];
        [self addInitialisationStrategy:[[ALCUIViewControllerInitWithFrameStrategy alloc] init]];
        
        _objectFactories = [[NSMutableArray alloc] init];
        [self addObjectFactory:[[ALCSimpleObjectFactory alloc] initWithContext:self]];
        
        _dependencyInjectors = [[NSMutableArray alloc] init];
        [self addDependencyInjector:[[ALCSimpleDependencyInjector alloc] init]];
        [self addDependencyInjector:[[ALCArrayDependencyInjector alloc] init]];
        
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
    //[_runtimeInjector executeStrategiesOnObjects:_objects withContext:self];
    
    // Now boot up the model.
    [self resolveDependencies];
    [self instantiateObjects];
    [self injectModelDependencies];
    
}

-(void) instantiateObjects {
    
    logCreation(@"Instantiating objects ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *description, BOOL *stop) {
        
        if (description.instantiate && description.finalObject == nil) { // Allow for pre-built objects.
            
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
    logRuntime(@"Injecting dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *description, BOOL *stop) {
        [self injectDependencies:description.finalObject];
    }];
}

-(void) injectDependencies:(id) object {
    logRuntime(@"Injecting dependencies into a %s", class_getName([object class]));
    [ALCRuntime object:object injectUsingDependencyInjectors:_dependencyInjectors];
    if ([object conformsToProtocol:@protocol(AlchemicAware)]) {
        [object didResolveDependencies];
    }
}

#pragma mark - Registering injections

-(void) registerClass:(Class) class injectionPoint:(NSString *) inj, ... {
    va_list args;
    va_start(args, inj);
    NSMutableArray *finalMatchers;
    id matcher = va_arg(args, id);
    while (matcher != nil) {
    
        if (![matcher conformsToProtocol:@protocol(ALCMatcher)]) {
            @throw [NSException exceptionWithName:@"AlchemicUnableNotAMatcher"
                                           reason:[NSString stringWithFormat:@"Passed matcher %s does not conform to the ALCMatcher protocol", class_getName([matcher class])]
                                         userInfo:nil];
        }
        
        if (finalMatchers == nil) {
            finalMatchers = [[NSMutableArray alloc] init];
        }
        [finalMatchers addObject:matcher];
        matcher = va_arg(args, id);
    }
    va_end(args);
    
    [self storeClass:class injectionPoint:inj withMatchers:finalMatchers];
}

-(void) storeClass:(Class) class injectionPoint:(NSString *) inj withMatchers:(NSArray *) matchers {
    [_model objectDescriptionForClass:class name:nil];
    if (![ALCRuntime isClassDecorated:class]) {
        [ALCRuntime decorateClass:class];
    }
    [ALCRuntime class:class addInjection:inj withMatchers:matchers];
}

#pragma mark - Registering classes

-(void) registerClass:(Class)class {
    [self registerClass:class withName:nil];
}

-(void) registerClass:(Class)class withName:(NSString *) name {
    ALCInstance *instance = [_model objectDescriptionForClass:class name:name];
    instance.instantiate = YES;
}

#pragma mark - Registering objects directly

-(void) registerObject:(id) finalObject withName:(NSString *) name {
    logCreation(@"Storing '%@' (%s)", name, class_getName([finalObject class]));
    ALCInstance *description = [_model objectDescriptionForClass:[finalObject class] name:name];
    description.finalObject = finalObject;
}

-(void) resolveDependencies {
    logDependencyResolving(@"Resolving dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *description, BOOL *stop){
        logDependencyResolving(@"Resolving dependencies in '%@' (%s)", name, class_getName(description.forClass));
        Class class = description.forClass;
        [ALCRuntime class:class resolveDependenciesWithModel:_model];
    }];
}

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

-(void) addDependencyInjector:(id<ALCDependencyInjector>) dependencyinjector {
    logConfig(@"Adding dependency injector: %s", class_getName([dependencyinjector class]));
    [_dependencyInjectors insertObject:dependencyinjector atIndex:0];
}

@end
