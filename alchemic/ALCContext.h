//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"
#import "ALCDependencyInjector.h"
#import "ALCInitialisationInjector.h"
#import "ALCDependencyInjector.h"
#import "ALCMatcher.h"
#import "ALCResolverPostProcessor.h"

@class ALCInstance;

@interface ALCContext : NSObject

#pragma mark - Configuration

/**
 Specifies the class used to inject init method wrappers into the runtime. Normally this doesn't been to be changed from the default.
 @discussion By default this is AlchemicRuntimeInjector.
 */
@property (nonatomic, strong) id<ALCInitialisationInjector> runtimeInitInjector;

/**
 Adds an additional initialisation strategy to the built in ones.
 Strategies are run in reverse order from last registered through to the builtin ones.
 */
-(void) addInitialisationStrategy:(Class) initialisationStrategyClass;

-(void) addResolverPostProcessor:(id<ALCResolverPostProcessor>) postProcessor;

/**
 Adds a ALCDependencyInjector to the list of injectors.
 */
-(void) addDependencyInjector:(id<ALCDependencyInjector>) dependencyinjector;

/**
 Adds a ALCObjectFactory to the list of object factories. Factories are checked in reverse order. The last registered object factory is the one asked first for an object.
 */
-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory;

#pragma mark - Lifecycle

-(void) start;

#pragma mark - Registering classes

-(void) addInstance:(ALCInstance *) instance;

#pragma mark - Manually injecting dependencies

-(void) injectDependencies:(id) object;

@end
