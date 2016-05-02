//
//  ALCMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#pragma mark - Registering

#import "ALCInternalMacros.h"
#import "ALCIsFactory.h"
#import "ALCIsPrimary.h"
#import "ALCIsReference.h"
#import "ALCFactoryName.h"

#define AcRegister(...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _configureClassObjectFactory):(ALCClassObjectFactory *) classObjectFactory { \
    [[Alchemic mainContext] objectFactoryConfig:classObjectFactory, ## __VA_ARGS__, nil]; \
}

#define AcMethod(methodType, methodSelector, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerMethodObjectFactory):(ALCClassObjectFactory *) classObjectFactory { \
    [[Alchemic mainContext] objectFactory:classObjectFactory \
                            factoryMethod:@selector(methodSelector) \
                               returnType:[methodType class], ## __VA_ARGS__, nil]; \
}

// Registers an injection point in the current class.
#define AcInject(variableName, ...) \
+(void) alc_concat(ALCHEMIC_METHOD_PREFIX, _registerObjectFactoryDependency):(ALCClassObjectFactory *) classObjectFactory { \
    [[Alchemic mainContext] objectFactory:classObjectFactory vaiableInjection:alc_toNSString(variableName), ## __VA_ARGS__, nil]; \
}

#pragma mark - Accessing the model

#define AcGet(returnType, ...) [[Alchemic mainContext] objectWithClass:[returnType class], ## __VA_ARGS__, nil]

#pragma mark - Arguments

#define AcArg(argClass, critieria, ...) [ALCArgument argumentWithClass:[argClass class] model:model criteria:criteria, ## __VA_ARGS__, nil]

#pragma mark - Model search Criteria.

#define AcClass(className) [ALCModelSearchCriteria searchCriteriaForClass:[className class]]

#define AcProtocol(protocolName) [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(protocolName)]

#define AcName(objectName) [ALCModelSearchCriteria searchCriteriaForName:objectName]

#pragma mark - Configuring factories

/**
 Tells Alchemic to set a custom name on an object factory.
 */
#define AcFactoryName(factoryName) [ALCFactoryName withName:factoryName]

/**
 When passed to a factory registration, sets the factory to be a factory.

 @discussion Factories create a new instance of an object every time they are accessed.

 @param _objectName the name to set on the registration.
 */
#define AcFactory [ALCIsFactory factoryMacro]

/**
 When passed to a factory registration, sets the factory as a primary factory.

 @discussion This is mainly used for a couple of situations. Firstly where there are a number of candiates and you don't want to use names to define a default. Secondly during unit testing, this can be used to set registrations in unit test code as overrides to the app's instances.
 */
#define AcPrimary [ALCIsPrimary primaryMacro]

/**
 When passed to a factory registration, sets the factory as storing and inject external objects.

 @discussion Can only be used on class factories as it makes no sense when set on method or initializers.
 */
#define AcExternal [ALCIsReference referenceMacro]

#pragma mark - Useful macros

#define AcIgnoreSelectorWarnings(code) \
_Pragma ("clang diagnostic push") \
_Pragma ("clang diagnostic ignored \"-Wselector\"") \
_Pragma ("clang diagnostic ignored \"-Wundeclared-selector\"") \
code \
_Pragma ("clang diagnostic pop")

