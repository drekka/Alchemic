//
//  alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInternal.h"
#import "ALCContext.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCNameMatcher.h"
#import "ALCLogger.h"
@import ObjectiveC;

// Matcher wrapping macros passed to the inject macro.

#define intoVariable(variableName) _alchemic_toNSString(variableName)

#define withClass(className) [[ALCClassMatcher alloc] initWithClass:object_getClass(className)]

#define withProtocol(protocolName) [[ALCProtocolMatcher alloc] initWithProtocol:@protocol(protocolName)]

#define withName(objectName) [[ALCNameMatcher alloc] initWithName:objectName]

#pragma mark - Injection

/// Main injection method.
#define inject(variable, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _inject_dependency_intoInstance):(ALCInstance *) instance { \
    [instance addDependency:variable, ## __VA_ARGS__, nil]; \
}

#define injectDependencies(object) [[Alchemic mainContext] injectDependencies:object]

#define primary

// Creates an object using a method. These are treated as if the method
// was the class definition. Only creates a single object. Any other calls will return that object.
#define object(methodSignature)

// Same as object, except that every time it's called, a new object is created.
#define objectFactory(methodSignature)

#pragma mark - Injecting values

// Injects resources which are located via resource locators.
#define localisedValue(key)
#define fileContentsValue(filename)
#define imageValue(imageName, resolution)
#define plistValue(plistName, keyPath) [[Alchemic mainContext] res

#define injectValue(variable, locator)

#pragma mark - Registering

/**
 This macros is used to register a class in Alchemic. Registered classes will be created automatically.
 */
#define registerComponent() \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassWithInstance):(ALCInstance *) instance {}

#define registerComponentWithName(componentName) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassWithInstance):(ALCInstance *) instance { \
    instance.name = componentName; \
    instance.instantiate = YES; \
}

/**
 Adds a pre-built object to the model.
 */
#define addObjectWithName(objectValue, objectName) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _object_withInstance):(ALCInstance *) instance { \
    instance.name = componentName; \
    instance.instantiate = YES; \
    instance.finalObject = object; \
}

/**
 This macros is used to specify that this class is a factory for other objects.
 */
#define registerFactory() \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerFactoryWithInstance):(ALCInstance *) instance {}

#pragma mark - The context itself

@interface Alchemic : NSObject

/**
 Returns the main context.
 
 @return An instance of ALCContext.
 */
+(ALCContext *) mainContext;

@end
