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

NS_ASSUME_NONNULL_BEGIN

/**
 The main facade for interacting with the Alchemic model.
 */
@protocol ALCContext <NSObject>

#pragma mark - Lifecycle

/// @name Lifecycle

/**
 Called to start the context.
 
 This resolves all model objects and auto-starts any registered singletons.
 */
-(void) start;

#pragma mark - Registering

/// @name Registering

/**
 Registers a class factory in the model.
 
 @param clazz The class to create the factory for.
 
 @return An instance of ALCClassObjectFactory setup to create a a singleton instance using the default init constructor.
 */
-(ALCClassObjectFactory *) registerObjectFactoryForClass:(Class) clazz;

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
-(void) objectFactory:(ALCClassObjectFactory *) objectFactory setInitializer:(SEL) initializer, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Declares a variable injection for the objects created by a class factory.
 
 @param objectFactory The parent object factory.
 @param variable      The name of the variable. Can be a property name, variable name, or internal variable name.
 @param ... A list of crteria or constant values that define the value to be injected.
 */
-(void) objectFactory:(ALCClassObjectFactory *) objectFactory registerVariableInjection:(NSString *) variable, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Tasks

/// @name Other functions

/**
 Access point for objects which need to have dependencies injected.
 
 @discussion This checks the model against the model. If a class builder is found which matches the class and protocols of the passed object, it is used to inject any listed dependencies into the object.
 
 @param object the object which needs dependencies injected.
 */
-(void) injectDependencies:(id) object;

/**
 returns an object by seaching the model for matching factories and accessing the objects they manage.
 
 @param returnType They type of value to be returned. Used when checking the returned objects from the factories.
 @param ... Model search criteria that defines the object or objects to be returned.
 
 @return An object of the appropriate type. All objects returned are fully resolved and completed.
 */
-(id) objectWithClass:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
