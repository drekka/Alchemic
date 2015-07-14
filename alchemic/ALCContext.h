//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCInitInjector;
@protocol ALCDependencyPostProcessor;
@protocol ALCObjectFactory;

@class ALCClassBuilder;

@interface ALCContext : NSObject

#pragma mark - Configuration

/**
 Specifies the class used to inject init method wrappers into the runtime. Normally this doesn't been to be changed from the default.
 @discussion By default this is AlchemicRuntimeInjector.
 */
@property (nonatomic, strong) id<ALCInitInjector> __nonnull runtimeInitInjector;

/**
 Adds an additional initialisation strategy to the built in ones.
 Strategies are run in reverse order from last registered through to the builtin ones when attempting to instantiate an object.
 
 @param initialisationStrategyClass the class to be added.
 */
-(void) addInitStrategy:(Class __nonnull) initialisationStrategyClass;

/**
 Adds an dependency post processor.
 
 @discussion dependency post processors are executed after depedencies have been resolve and before their values are accessed for injection.
 */
-(void) addDependencyPostProcessor:(id<ALCDependencyPostProcessor> __nonnull) postProcessor;

/**
 Adds a ALCObjectFactory to the list of object factories. 
 
 @discussion Factories are checked in reverse order. The last registered object factory is the one asked first for an object.
 
 @param objectFactory the factory to add.
 */
-(void) addObjectFactory:(id<ALCObjectFactory> __nonnull) objectFactory;

#pragma mark - Lifecycle

/**
 Starts the context.
 
 @discussion After scanning the runtime for Alchemic registrations, this called to start the context. This involves resolving all dependencies, instantiating all registered singletons and finally injecting any dependencies of those singletons.
 */
-(void) start;

#pragma mark - Dependencies

/**
 Access point for objects which need to have dependencies injected. 
 
 @discussion This checks the model against the model. If a class builder is found which matches the class and protocols of the passed object, it is used to inject any listed dependencies into the object.
 
 @param object the object which needs dependencies injected.
 */
-(void) injectDependencies:(id __nonnull) object;

@end
