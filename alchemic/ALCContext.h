//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"
#import "ALCInitInjector.h"
#import "ALCMatcher.h"
#import "ALCResolverPostProcessor.h"
#import "ALCModelObject.h"
#import "NSDictionary+ALCModel.h"
#import "ALCCandidateValueResolverFactory.h"

@class ALCModelObjectInstance;

@interface ALCContext : NSObject

@property (nonatomic, strong, readonly) NSDictionary *model;
@property (nonatomic, strong, readonly) NSSet *resolverPostProcessors;
@property (nonatomic, strong, readonly) NSSet *objectFactories;
@property (nonatomic, strong, readonly) id<ALCCandidateValueResolverFactory> objectResolverFactory;

#pragma mark - Configuration

@property (nonatomic, strong) Class objectResolverFactoryClass;

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

-(void) addResolverPostProcessor:(id<ALCDependencyResolverPostProcessor>) postProcessor;

/**
 Adds a ALCObjectFactory to the list of object factories. Factories are checked in reverse order. The last registered object factory is the one asked first for an object.
 */
-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory;

#pragma mark - Lifecycle

-(void) start;

#pragma mark - Manually injecting dependencies

-(void) injectDependencies:(id) object;

#pragma mark - Registration call backs

-(void) registerAsSingleton:(ALCModelObjectInstance *) objectInstance;

-(void) registerAsSingleton:(ALCModelObjectInstance *) objectInstance withName:(NSString *) name;

-(void) registerObject:(id) object withName:(NSString *) name;

/**
 Registers a factory method with it's return data type and matchers for locating the objects for each argument.
 */
-(void) registerFactory:(ALCModelObjectInstance *) objectInstance
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ...;

-(void) registerFactory:(ALCModelObjectInstance *) objectInstance
               withName:(NSString *) name
        factorySelector:(SEL) factorySelector
             returnType:(Class) returnTypeClass, ...;

@end
