//
//  alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInternal.h"
#import "ALCInstance.h"
#import "ALCContext.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCNameMatcher.h"
#import "ALCLogger.h"
@import ObjectiveC;

// Matcher wrapping macros passed to the inject macro.

#define intoVariable(_variableName) _alchemic_toNSString(_variableName)

#define withClass(_className) [[ALCClassMatcher alloc] initWithClass:[_className class]]

#define withProtocol(_protocolName) [[ALCProtocolMatcher alloc] initWithProtocol:@protocol(_protocolName)]

#define withName(_objectName) [[ALCNameMatcher alloc] initWithName:_objectName]

#pragma mark - Injection

#define injectDependencies(object) [[Alchemic mainContext] injectDependencies:object]

#define primary

#pragma mark - Injecting values

// Injects resources which are located via resource locators.
#define localisedValue(key)
#define fileContentsValue(filename)
#define imageValue(imageName, resolution)
#define plistValue(plistName, keyPath)

#define injectValue(variable, locator)

#pragma mark - Registering

// All registration methods must make use of the same signature.

// Registers an injection point in the current class.
#define inject(_variable, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerDependencyInInstance):(ALCInstance *) instance { \
    [instance addDependency:_variable, ## __VA_ARGS__, nil]; \
}

/**
 This macros is used to register a class in Alchemic. Registered classes will be created automatically.
 */
#define registerSingleton \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassWithInstance):(ALCInstance *) instance { \
    [[Alchemic mainContext] registerAsSingleton:instance]; \
}

#define registerSingletonWithName(_componentName) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassWithInstance):(ALCInstance *) instance { \
    [[Alchemic mainContext] registerAsSingleton:instance withName:_componentName]; \
}

/**
 Adds a pre-built object to the model.
 */
#define registerObjectWithName(_object, _objectName) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerObjecWithInstance):(ALCInstance *) instance { \
    [[Alchemic mainContext] registerObject:_object withName:_objectName]; \
}

/**
 This macros is used to specify that this class is a factory for other objects.
 @param factorySelector the signature of the factory selector.
 @param returnType the Class of the return type. Will be used to for resolving dependecies which will use this factory.
 @param ... a args list of criteria which will be used to locate the arguments needed for the factory method. Argments can be several things.
 A single Matcher object.
 An Array of Matcher objects.
 The number of objects passed must match the number of expected arguments.
 */
#define registerFactoryMethod(_returnTypeClassName, _factorySelector, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerFactoryMethodWithInstance):(ALCInstance *) instance { \
    [[Alchemic mainContext] registerFactory:instance \
                            factorySelector:@selector(_factorySelector) \
                                 returnType:[_returnTypeClassName class], ## __VA_ARGS__, nil]; \
}

#pragma mark - The context itself

@interface Alchemic : NSObject

/**
 Returns the main context.
 
 @return An instance of ALCContext.
 */
+(ALCContext *) mainContext;

@end
