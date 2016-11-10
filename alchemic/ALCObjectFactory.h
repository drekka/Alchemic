//
//  ALCObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCInstantiator.h>

@class ALCValue;
@protocol ALCModel;

NS_ASSUME_NONNULL_BEGIN

/**
 Typedef defining the different types of object management that factories can employee.
 */
typedef NS_ENUM(NSUInteger, ALCFactoryType) {
    /**
     Singletons - Factory will only ever create one instance of the object and keep a reference to it so it never goes out of scope. Singletons are automatically created on startup.
     */
    ALCFactoryTypeSingleton,
    /**
     Template - Each time an object is requested, a new one is instantiated. Factories do not keep references to the objects they create.
     */
    ALCFactoryTypeTemplate,
    /**
     Reference - Specifically designed for when the objects are not created by Alchemic. For example UIViewController instances created by storyboards. Setting a reference will automatically inject any dependencies it has declared.
     */
    ALCFactoryTypeReference
};

/**
 Defines a class as a object factory. 
 
 Object factories are classes which can create objects and inject their dependencies. They can represent classes or methods used to create instances.
 */
@protocol ALCObjectFactory <ALCInstantiator>

/**
 The type of the factory. @see ALCFactoryType.
 */
@property (nonatomic, assign, readonly) ALCFactoryType factoryType;

/**
 If the factory is holding a weak reference to the objects it manages.
 */
@property (nonatomic, assign, readonly, getter = isWeak) BOOL weak;

/**
 If the factory can hold a nil value.
 */
@property (nonatomic, assign, readonly, getter = isNillable) BOOL nillable;

/**
 Whether the factory is classified as a Primary factory. 
 
 When searching the model for factories, if primary factories are found in the results, then only those factories will be returned.
 */
@property (nonatomic, assign, readonly, getter = isPrimary) BOOL primary;

/**
 Whether the factory is considered transient.

 Only non-template factories can be transient. This is because templates never store values.
 */
@property (nonatomic, assign, readonly, getter = isTransient) BOOL transient;

/**
 Tells the factory to instantiate an the represented object or return one if it already exists.
 */
@property (nonatomic, strong, readonly) ALCValue *value;

/**
 Configures the factory.

 @param options             A list of options that define the factory configuration. For example, to make it a primary factory.
 @param model A reference to the model in case the configure code needs it.
 */
-(void) configureWithOptions:(NSArray *) options model:(id<ALCModel>) model;

/**
 Sets an object into the factory.
 
 @discussion This is only legal for singleton or reference class factories. Any factory that involves a method such as method factories and class factories with initializers will reject having a value set.
 
 This method is for calling from the main context. It forwards to the storeObject: method and then sends notifications to dependencies that are listen for changes.
 
 @param object The object to store.
 
 */
-(void) storeObject:(nullable id) object;

/**
 Call just before unloading the object factory.
 
 @discussion Usually this is during testing as in an app, the DI framework is typically not unloaded.
 */
-(void) unload;

@end

NS_ASSUME_NONNULL_END
