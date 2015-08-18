//
//  ALCMacros.h
//  alchemic
//
//  Created by Derek Clarkson on 23/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCContext.h"
#import "ALCInternalMacros.h"
#import "ALCIsPrimary.h"
#import "ALCIsFactory.h"
#import "ALCWithName.h"

#pragma mark - Defining objects

/**
 Tells Alchemic to set a custom name on a registration.
 */
#define AcWithName(_objectName) [ALCWithName withName:_objectName]

/**
 Defines the class or factory method as a factory.
 
 @discussion Factories create a new instance of an object every time they are accessed.
 
 @param _objectName the name to set on the registration.
 */
#define AcIsFactory [[ALCIsFactory alloc] init]

/**
 When there is more than one candidate object for a dependency, Primary objects are used first. 
 
 @discussion This is mainly used for a couple of situations. Firstly where there are a number of candiates and you don't want to use names to define a default. Secondly during unit testing, this can be used to set registrations in unit test code as overrides to the app's instances.
 */
#define AcIsPrimary [[ALCIsPrimary alloc] init]

#pragma mark - Dependency expressions

#define AcClass(className) [ALCClass withClass:[className class]]

#define AcProtocol(protocolName) [ALCProtocol withProtocol:@protocol(protocolName)]

#define AcName(objectName) [ALCName withName:objectName]

#define AcValue(_value) [ALCConstantValue constantValue:_value]

#define AcArg(argType, valueMacros, ...) [ALCArg argWithType:[argType class] macros:valueMacros, ## __VA_ARGS__, nil]

#pragma mark - Injection

/**
 If you need to manually resolve and inject values into an object, then call this macro passing it the object to be injected.
 
 @param object the object whose dependencies need to be resolved and injected.
 */
#define AcInjectDependencies(object) [[ALCAlchemic mainContext] injectDependencies:object]

#pragma mark - Retrieving values

/**
 Programmatically gets an object from Alchemic.

 @param returnType The type of the object to be retrieved. This can be a NSArray class if multiple objects are expected.
 @param ...        Zero or more macros which define the model search expressions which will find the object.

 @return The found object.
 */
#define AcGet(returnType, ...) [[ALCAlchemic mainContext] getValueWithClass:[returnType class], ## __VA_ARGS__, nil]

/**
 Programmatically invokes a specific method. 
 
 @discussion The method can be a normal instance method registered with AcMethod(...) or an initializer registered with AcInitializer(...). Usually you would use this method rather than an injected value when you need to pass values to the method or initializer which are not available from Alchemic's model or a constant value. In other words, values which are computed just prior to requesting the object from Alchemic. The returned object is checked and injected with dependencies as necessary.
 
 Note that this method can be used to invoke multiple methods or initializers. In this case it is assumed that each one takes the same arguments in the same order and an array of result objects will be returned.

 @param methodLocator A model search macro which is used to locate the method or initializer to call.
 @param ...  zero or more values. These are the actual values, not macros.

 @return either an object or an array of objects if multiple builders are found.
 @throw An exception if a non-method builder is found by the methodLocator argument.
 */
#define AcInvoke(methodLocator, ...) [[ALCAlchemic mainContext] invokeMethodBuilders:methodLocator, ## __VA_ARGS__, nil]

#pragma mark - Registering

/**
 Register a class as a source of objects.
 
 @discussion This is the main macro for setting up objects within Alchemic. It take a number of other macros as 
 */
#define AcRegister(...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
}

#define AcMethod(methodType, methodSel, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerFactoryMethodInClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerClassBuilder:classBuilder selector:@selector(methodSel) returnType:[methodType class], ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define AcInject(variableName, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerDependencyInClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerClassBuilder:classBuilder variableDependency:alc_toNSString(variableName), ## __VA_ARGS__, nil]; \
}

// Registers an initializer for a class.
#define AcInitializer(initializerSel, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerInitializerForClassBuilder):(ALCClassBuilder *) classBuilder { \
	[[ALCAlchemic mainContext] registerClassBuilder:classBuilder initializer:@selector(initializerSel), ## __VA_ARGS__, nil]; \
}

#pragma mark - Callbacks

/**
 Call to add a block which is called after Alchemic has started.

 @param block The block to execute.
 */
#define AcExecuteWhenStarted(block) [[ALCAlchemic mainContext] executeWhenStarted:block]

