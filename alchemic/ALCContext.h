//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"
#import "ALCAbstractDependencyInjector.h"
#import "ALCInitInjector.h"
#import "ALCMatcher.h"
#import "ALCResolverPostProcessor.h"
#import "ALCObjectMetadata.h"
#import "NSDictionary+ALCModel.h"

@class ALCInstance;

@interface ALCContext : NSObject

@property (nonatomic, strong, readonly) NSDictionary *model;
@property (nonatomic, strong, readonly) NSSet *resolverPostProcessors;
@property (nonatomic, strong, readonly) NSArray *dependencyInjectors;
@property (nonatomic, strong, readonly) NSSet *objectFactories;

#pragma mark - Configuration

/**
 Specifies the class used to inject init method wrappers into the runtime. Normally this doesn't been to be changed from the default.
 @discussion By default this is AlchemicRuntimeInjector.
 */
@property (nonatomic, strong) id<ALCInitInjector> runtimeInitInjector;

/**
 Adds an additional initialisation strategy to the built in ones.
 Strategies are run in reverse order from last registered through to the builtin ones.
 */
-(void) addInitStrategy:(Class) initialisationStrategyClass;

-(void) addResolverPostProcessor:(id<ALCResolverPostProcessor>) postProcessor;

/**
 Adds a ALCDependencyInjector to the list of injectors.
 */
-(void) addDependencyInjector:(ALCAbstractDependencyInjector *) dependencyinjector;

/**
 Adds a ALCObjectFactory to the list of object factories. Factories are checked in reverse order. The last registered object factory is the one asked first for an object.
 */
-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory;

#pragma mark - Lifecycle

-(void) start;

#pragma mark - Manually injecting dependencies

-(void) injectDependencies:(id) object;

#pragma mark - Registration call backs

-(void) registerAsSingleton:(ALCInstance *) objectInstance;

-(void) registerAsSingleton:(ALCInstance *) objectInstance withName:(NSString *) name;

-(void) registerObject:(id) object withName:(NSString *) name;

/**
 Registers a factory method with it's return data type and matchers for locating the objects for each argument.
 */
-(void) registerFactory:(ALCInstance *) objectInstance
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ...;

-(void) registerFactory:(ALCInstance *) objectInstance
               withName:(NSString *) name
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ...;

@end
