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
#import "ALCDependencyPostProcessor.h"
#import "ALCValueResolverManager.h"

@class ALCClassBuilder;

@interface ALCContext : NSObject

@property (nonatomic, strong, readonly) NSDictionary *model;
@property (nonatomic, strong, readonly) NSSet *dependencyPostProcessors;
@property (nonatomic, strong, readonly) NSSet *objectFactories;
@property (nonatomic, strong, readonly) id<ALCValueResolverManager> valueResolverManager;

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

-(void) addDependencyPostProcessor:(id<ALCDependencyPostProcessor>) postProcessor;

/**
 Adds a ALCObjectFactory to the list of object factories. Factories are checked in reverse order. The last registered object factory is the one asked first for an object.
 */
-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory;

#pragma mark - Lifecycle

-(void) start;

#pragma mark - Manually injecting dependencies

-(void) injectDependencies:(id) object;

#pragma mark - Registration call backs

-(void) registerDependencyInClassBuilder:(ALCClassBuilder *) classBuilder qualifiers:(id) firstQualifier, ...;

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder qualifiers:(id) firstQualifier, ...;

-(void) registerObject:(id) object withName:(NSString *) name;

@end
