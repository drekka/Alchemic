//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDependencyResolver.h"
#import "ALCInitialisationInjector.h"
#import "ALCObjectFactory.h"
#import "ALCObjectInjector.h"
@class ALCClassInfo;

@interface ALCContext : NSObject

#pragma mark - Configuration

/**
 Specifies the class used to inject dependencies into the runtime. Normally this doesn't been to be changed from the default.
 @discussion By default this is AlchemicRuntimeInjector.
 */
@property (nonatomic, strong) id<ALCInitialisationInjector> runtimeInjector;

/**
 Adds an additional initialisation strategy to the built in ones.
 Strategies are run in reverse order from last registered through to the builtin ones.
 */
-(void) addInitialisationStrategy:(id<ALCInitialisationStrategy>) initialisationStrategy;

/**
 Adds an onjector to the list of injectors.
 These are run in reverse order with the last registered getting the first chance to make an injection.
 @param objectInjector the injector to add.
 */
-(void) addObjectInjector:(id<ALCObjectInjector>) objectInjector;

/**
 Adds a ALCDependencyResolver to the list of resolvers. Resolvers are checked in reverse order so the last added will be checked first.
 */
-(void) addDependencyResolver:(id<ALCDependencyResolver>) dependencyResolver;

/**
 Adds a ALCObjectFactory to the list of object factories. Factories are checked in reverse order. The last registered object factory is the one asked first for an object.
 */
-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory;

#pragma mark - Lifecycle

-(void) start;

#pragma mark - Registration

-(void) registerClass:(Class) class;

-(void) registerClass:(Class) class withName:(NSString *) name;

-(void) registerInjection:(NSString *) inj inClass:(Class) class;

-(void) registerInjection:(NSString *) inj inClass:(Class) class withName:(NSString *) name;

-(void) registerClass:(Class) class withInjectionPoints:(NSString *) injs, ...;

-(void) registerClass:(Class) class withName:(NSString *) name withInjectionPoints:(NSString *) injs, ...;

@end
