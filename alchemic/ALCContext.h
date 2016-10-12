//
//  ALCContext.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@protocol ALCDependency;
@protocol ALCObjectFactory;
@class ALCClassObjectFactory;
@class ALCMethodObjectFactory;
@protocol ALCContext;
@protocol ALCResolveAspect;

NS_ASSUME_NONNULL_BEGIN

/**
 The main facade for interacting with the Alchemic model.
 */
@protocol ALCContext <NSObject>

@property (nonatomic, assign, readonly, getter = isStarted) BOOL started;

#pragma mark - Lifecycle

/// @name Lifecycle

/**
 Called to start the context.
 
 This resolves all model objects and auto-starts any registered singletons.
 */
-(void) start;

/**
 Mostly used internal and for testing, this registers a block that will be executed when Alchemic has finished starting. 
 
 If Alchemic has already started, the block is executed immediately on the current thread.

 @param block A simple block.
 */
-(void) executeWhenStarted:(void (^)()) block;

-(void) executeInBackground:(void (^)()) block;

-(void) addResolveAspect:(id<ALCResolveAspect>) resolveAspect;

#pragma mark - Registering

/// @name Registering

/**
 Registers a class factory in the model.
 
 @param aClass The class to create the factory for.
 
 @return An instance of ALCClassObjectFactory setup to create a a singleton instance using the default init constructor.
 */
-(ALCClassObjectFactory *) registerObjectFactoryForClass:(Class) aClass;

/**
 Configures a class object factory,
 
 @param objectFactory The class factory to configure.   
 @param ... The configuration items.
 */
-(void) objectFactoryConfig:(ALCClassObjectFactory *) objectFactory, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Registers a factory method found in the class factory's class.
 
 @param objectFactory The parent class factory.
 @param selector      The selector of the method.
 @param returnType The class of the value that will be returned from the method.
 @param ... A list of items that define the arguments to the method factory, or configure it.
 */
-(void) objectFactory:(ALCClassObjectFactory *) objectFactory
registerFactoryMethod:(SEL) selector
           returnType:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Declares an initializer that will be used to created the instances of objects by the class factory.
 
 @param objectFactory The parent class factory.
 @param initializer   The initializer selector.
 @param ... A list of initializer argument declarations. Factory configuration items are not accepted in this list.
 */
-(void) objectFactory:(ALCClassObjectFactory *) objectFactory initializer:(SEL) initializer, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Declares a variable injection for the objects created by a class factory.
 
 @param objectFactory The parent object factory.
 @param variable      The name of the variable. Can be a property name, variable name, or internal variable name.
 @param ... A list of crteria or constant values that define the value to be injected.
 */
-(void) objectFactory:(ALCClassObjectFactory *) objectFactory registerInjection:(NSString *) variable, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Tasks

/// @name Other functions

/**
 Access point for injecting dependencies into an object without having to store it in the model.
 
 @param object the object which needs dependencies injected.
 @param ... An optional list of search criteria for finding the class build to handle the dependency injections.
 */
-(void) injectDependencies:(id) object, ... NS_REQUIRES_NIL_TERMINATION;

/**
 returns an object by seaching the model for matching factories and accessing the objects they manage.
 
 @param returnType They type of value to be returned. Used when checking the returned objects from the factories.
 @param ... Model search criteria that defines the object or objects to be returned.
 
 @return An object of the appropriate type. All objects returned are fully resolved and completed.
 */
-(nullable id) objectWithClass:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Sets a value on a factory.
 
 Can only be used on factories which represent singletons or references as it makes no sense to set a factory value.
 @param object The object to set. If there are not criteria then the class of this object will be used to find the reference to set. To nil out a stored object, pass AcNil.
 */
-(void) setObject:(id) object, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
