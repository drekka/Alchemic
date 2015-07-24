//
//  ALCMacros.h
//  alchemic
//
//  Created by Derek Clarkson on 23/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCContext.h"
#import "ALCInternalMacros.h"

#pragma mark - Defining objects

/**
 Tells Alchemic to set a custom name on a registration.
 */
#define ACWithName(_objectName) [ALCWithName withName:_objectName]

/**
 Defines the class or factory method as a factory.
 
 @discussion Factories create a new instance of an object every time they are accessed.
 
 @param _objectName the name to set on the registration.
 */
#define ACIsFactory [[ALCIsFactory alloc] init]

/**
 When there is more than one candidate object for a dependency, Primary objects are used first. 
 
 @discussion This is mainly used for a couple of situations. Firstly where there are a number of candiates and you don't want to use names to define a default. Secondly during unit testing, this can be used to set registrations in unit test code as overrides to the app's instances.
 */
#define ACIsPrimary [[ALCIsPrimary alloc] init]

#pragma mark - Dependency expressions

#define ACClass(className) [ALCClass withClass:[className class]]

#define ACProtocol(protocolName) [ALCProtocol withProtocol:@protocol(protocolName)]

#define ACName(objectName) [ALCName withName:objectName]

#define ACValue(_value) [ALCConstantValue constantValue:_value]

#define ACArg(argType, valueMacros, ...) [ALCArg argWithType:[argType class] macros:valueMacros, ## __VA_ARGS__, nil]

#pragma mark - Injection

/**
 If you need to manually resolve and inject values into an object, then call this macro passing it the object to be injected.
 
 @param object the object whose dependencies need to be resolved and injected.
 */
#define ACInjectDependencies(object) [[ALCAlchemic mainContext] injectDependencies:object]

#pragma mark - Registering

/**
 Register a class as a source of objects.
 
 @discussion This is the main macro for setting up objects within Alchemic. It take a number of other macros as 
 */
#define ACRegister(...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
}

#define ACMethod(methodType, methodSel, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerFactoryMethodInClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerMethodBuilder:classBuilder selector:@selector(methodSel) returnType:[methodType class], ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define ACInject(variableName, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerDependencyInClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerDependencyInClassBuilder:classBuilder variable:alc_toNSString(variableName), ## __VA_ARGS__, nil]; \
}

// Registers an initializer for a class.
#define ACInitializer(initializer, initializerSel, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerInitializerForClassBuilder):(ALCClassBuilder *) classBuilder { \
	[[ALCAlchemic mainContext] registerClassInitializer:classBuilder initializer:@selector(initializerSel), ## __VA_ARGS__, nil]; \
}


