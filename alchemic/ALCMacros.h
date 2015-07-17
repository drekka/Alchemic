//
//  ALCMacros.h
//  alchemic
//
//  Created by Derek Clarkson on 23/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCContext.h>
#import "ALCContext+Internal.h"

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

#pragma mark - Dependencies

/**
 Used when we want to locate dependencies based on a class.
 
 @param _className the name of the class to search for.
 */
#define ACClass(_className) [ALCClass withClass:[_className class]]

/**
 Used to search for dependencies based on a protocol that a class implements.
 
 @param _ProtocolName the name of the protocol.
 */
#define ACProtocol(_protocolName) [ALCProtocol withProtocol:@protocol(_protocolName)]

/**
 Used to search for builders based on the names given to them.
 
 @param _objectName The name to search on.
 */
#define ACName(_objectName) [ALCName withName:_objectName]

/**
 Used to search for builders based on the names given to them.

 @param _objectName The name to search on.
 */
#define ACValue(_value) [ALCConstantValue constantValueWithValue:_value]

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
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerClassBuilder:classBuilder, ## __VA_ARGS__, nil]; \
}

#define ACMethod(returnTypeClass, selectorSig, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerMethodBuilder:classBuilder selector:@selector(selectorSig) returnType:[returnTypeClass class], ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define ACInject(variableName, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerDependencyInClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerDependencyInClassBuilder:classBuilder variable:_alchemic_toNSString(variableName), ## __VA_ARGS__, nil]; \
}
