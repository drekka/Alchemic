//
//  ALCClassObjectFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCAbstractObjectFactory.h"

@protocol ALCInjector;
@class ALCClassObjectFactoryInitializer;

/**
 Object factory that can instantiate classes. Can also optionally take a ALCClassObjectFactoryInitializer to define the initializer to use when instantiating an instance.
 */
@interface ALCClassObjectFactory : ALCAbstractObjectFactory

/**
 @brief The ALCClassObjectFactoryInitializer to use when creating objects. If nil, then the default init is used.
 */
@property (nonatomic, strong) ALCClassObjectFactoryInitializer *initializer;

/**
 @brief Adds a variable injection to the factory.
 
 After instantiating an instance using this factory, the completion block will perform all the injections registered via this method.
 
 @param injector    The injector to use to perform the variable injection.
 @param variable     The variable to inject.
 @param variableName The original name of the varibable as specified during registration.
 */
-(void) registerInjection:(id<ALCInjector>) injector forVariable:(Ivar) variable withName:(NSString *) variableName;

/**
 @brief Injects values into the passed object.
 
 @param object The object to be injected.
 */
-(void) injectDependencies:(id) object;

@end
