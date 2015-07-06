//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCInitInjector.h>
#import <Alchemic/ALCDependencyPostProcessor.h>
#import <Alchemic/ALCObjectFactory.h>

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
 Strategies are run in reverse order from last registered through to the builtin ones.
 */
-(void) addInitStrategy:(Class __nonnull) initialisationStrategyClass;

-(void) addDependencyPostProcessor:(id<ALCDependencyPostProcessor> __nonnull) postProcessor;

/**
 Adds a ALCObjectFactory to the list of object factories. Factories are checked in reverse order. The last registered object factory is the one asked first for an object.
 */
-(void) addObjectFactory:(id<ALCObjectFactory> __nonnull) objectFactory;

#pragma mark - Lifecycle

-(void) start;

#pragma mark - Manually injecting dependencies

-(void) injectDependencies:(id __nonnull) object;

@end
