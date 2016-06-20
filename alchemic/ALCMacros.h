//
//  ALCMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCFactoryName.h>
#import <Alchemic/ALCFlagMacros.h>
#import <Alchemic/ALCMethodArgument.h>
#import <Alchemic/ALCModelSearchCriteria.h>
#import <Alchemic/ALCClassObjectFactory.h>
#import <Alchemic/ALCContext.h>
#import <Alchemic/ALCStringMacros.h>

#pragma mark - registration

/**
 Shortcut macro for registering and configuring a class factory.

 @param ... A list of configuration items.
 */
#define AcRegister(...) \
+(void) alc_methodName(configureClassObjectFactory_, __LINE__):(ALCClassObjectFactory *) classObjectFactory { \
[[Alchemic mainContext] objectFactoryConfig:classObjectFactory, ## __VA_ARGS__, nil]; \
}

/**
 A short cut macro that adds an initializer to a class factory.

 @param initializerSelector The initializer selector.
 @param ...                 Arguments for the initializer, if any.
 */
#define AcInitializer(initializerSelector, ...) \
+(void) alc_methodName(registerObjectFactoryInitializer, __LINE__):(ALCClassObjectFactory *) classObjectFactory { \
[[Alchemic mainContext] objectFactory:classObjectFactory setInitializer:@selector(initializerSelector), ## __VA_ARGS__, nil]; \
}

/**
 registers a method factory.

 @param methodType     The return type of the method.
 @param methodSelector The method selector.
 @param ...                 Arguments for the method, if any.
 */
#define AcMethod(methodType, methodSelector, ...) \
+(void) alc_methodName(registerMethodObjectFactory, __LINE__):(ALCClassObjectFactory *) classObjectFactory { \
[[Alchemic mainContext] objectFactory:classObjectFactory \
registerFactoryMethod:@selector(methodSelector) \
returnType:[methodType class], ## __VA_ARGS__, nil]; \
}

/**
 Registers a variable injection in the class factory.

 @param variableName The variable name. Can be a property name or internal variable name.
 @param ...          Option list of arguments that define the injection.
 */
#define AcInject(variableName, ...) \
+(void) alc_methodName(registerObjectFactoryDependency, __LINE__):(ALCClassObjectFactory *) classObjectFactory { \
[[Alchemic mainContext] objectFactory:classObjectFactory registerVariableInjection:alc_toNSString(variableName), ## __VA_ARGS__, nil]; \
}

#pragma mark - Factory configuration

/**
 Tells Alchemic to set a custom name on an object factory.
 */
#define AcFactoryName(factoryName) [ALCFactoryName withName:factoryName]

/**
 When passed to an object factory registration, sets the factory to be a template.

 @discussion Templates create a new instance of an object every time they are accessed and don't store any reference to the objects they have previously created.

 */
#define AcTemplate [ALCIsTemplate macro]

/**
 When passed to a factory registration, sets the factory as a primary factory.

 @discussion This is mainly used for a couple of situations. Firstly where there are a number of candiates and you don't want to use names to define a default. Secondly during unit testing, this can be used to set registrations in unit test code as overrides to the app's instances.
 */
#define AcPrimary [ALCIsPrimary macro]

/**
 When passed to a factory registration, sets the factory as storing and inject external objects.

 @discussion Can only be used on class factories as it makes no sense when set on method or initializers.
 */
#define AcReference [ALCIsReference macro]

/**
 When passed to a singleton or reference factory registration, sets the factory as storing weak references rather than strng ones.
 
 @discussion Illegal on template factories.
 */
#define AcWeak [ALCIsWeak macro]

#pragma mark - Method arguments
/**
 Shortcut macro for specifying method arguments.

 @param argClass  The class of the argument. Used for final processing of model search results.
 @param critieria The argument criteria or constant. If search criteria are being used to location model objects, then multiple can be specified.
 @param ...       further criteria.
 */
#define AcArg(argClass, firstCritieria, ...) [ALCMethodArgument argumentWithClass:[argClass class] criteria:firstCritieria, ## __VA_ARGS__, nil]

#pragma mark - Accessing the model

/**
 Used in code to directly retrieve an object from Alchemic.

 @param returnType The type of value to retrieve.
 @param ...        Option search criteria to locate the object. Constants are not allowed here as they make no sense.

 @return The matching object.
 */
#define AcGet(returnType, ...) [[Alchemic mainContext] objectWithClass:[returnType class], ## __VA_ARGS__, nil]

/**
 Stores an object in the Alchemic model.

 This can be used to set an object on any factory declared as a singleton or external reference. Obviously it makes no sense to set a value on a factory.

 @param value The object to store.
 @param ... A set of model search criteria that will locate the factory where the value is to be stored.
 */
#define AcSet(value, ...)  [[Alchemic mainContext] setObject:value, ## __VA_ARGS__, nil]

#pragma mark - Search criteria

/**
 Selects factories which return instances of the specified class.

 @param className The class to search for.
 */
#define AcClass(className) [ALCModelSearchCriteria searchCriteriaForClass:[className class]]

/**
 Selects factories which return instances which conform to the specified protocol.

 @param protocolName The protocol to look for.
 */
#define AcProtocol(protocolName) [ALCModelSearchCriteria searchCriteriaForProtocol:@protocol(protocolName)]

/**
 Selects a single factory based on it's unique name.

 @param objectName The factory name.
 */
#define AcName(objectName) [ALCModelSearchCriteria searchCriteriaForName:objectName]

#pragma mark - Misc

/**
 Mostly used in testing, this macro hides selector warnings triggered when a selector is not declared on the current class.

 @param code The code that generates the warning.
 */
#define AcIgnoreSelectorWarnings(code) \
_Pragma ("clang diagnostic push") \
_Pragma ("clang diagnostic ignored \"-Wselector\"") \
_Pragma ("clang diagnostic ignored \"-Wundeclared-selector\"") \
code \
_Pragma ("clang diagnostic pop")

