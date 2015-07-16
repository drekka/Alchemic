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
#define ACAsName(_objectName) [ALCAsName asNameWithName:_objectName]

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
#define ACWithClass(_className) [ALCQualifier qualifierWithValue:[_className class]]

/**
 Used to search for dependencies based on a protocol that a class implements.
 
 @param _ProtocolName the name of the protocol.
 */
#define ACWithProtocol(_protocolName) [ALCQualifier qualifierWithValue:@protocol(_protocolName)]

/**
 Used to search for builders based on the names given to them.
 
 @param _objectName The name to search on.
 */
#define ACWithName(_objectName) [ALCQualifier qualifierWithValue:_objectName]

/**
 Used to search for builders based on the names given to them.

 @param _objectName The name to search on.
 */
#define ACWithValue(_value) [ALCConstantValue constantValueWithValue:_value]

/**
 When defining a method which builds an object, this tells the builder what class is expected to be returned from the method.
 
 @discussion The class declared by this macro is used for searching when resolving dependencies.
 
 _returnType The class that is to be returned.
 */
#define ACReturnType(_returnType) [ALCReturnType returnTypeWithClass:[_returnType class]]

/**
 The selector of a method in the classes that will be used to build objects.

 @discussion In the ACRegister(...) macro, the rest of the ACWith... arguments must match the arguments to this selector, in order. This allows Alchemic to then locate the dependencies for those arguments. If an argument needs more than one ACWith... to locate the dependency, they should be wrapped in an Objective-C array.

 @param _methodSelector the selector to call when a value is needed.
 */
#define ACSelector(_methodSelector) [ALCMethodSelector methodSelector:@selector(_methodSelector)]

/**
 When declaring a dependency in a class, this defines the name of the variable that the value will be injected into.
 
 @param _variableName the name of the variable. If a property is the target, this can either be the name of the property or the variable behind the property.
 */
#define ACIntoVariable(_variableName) [ALCIntoVariable intoVariableWithName:_alchemic_toNSString(_variableName)]

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

#define ACMethod(returnType, selector, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerMethodBuilder:classBuilder, ACReturnType(returnType), ACSelector(selector), ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define ACInject(variableName, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerDependencyInClassBuilder):(ALCClassBuilder *) classBuilder { \
[[ALCAlchemic mainContext] registerDependencyInClassBuilder:classBuilder, ACIntoVariable(variableName), ## __VA_ARGS__, nil]; \
}
