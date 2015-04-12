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
#import <objc/runtime.h>

// Matcher wrapping macros.
#define intoVariable(variableName) _alchemic_toNSString(variableName)

#define withClass(className) [[ALCClassMatcher alloc] initWithClass:[className class]]

#define withProtocol(protocolName) [[ALCProtocolMatcher alloc] initWithProtocol:@protocol(protocolName)]

#define withName(objectName) [[ALCNameMatcher alloc] initWithName:objectName]

#define inject(variable, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _alchemic_concat(inject_dependency_, __LINE__)) { \
    [[Alchemic mainContext] registerClass:self injectionPoint:variable, ## __VA_ARGS__, nil]; \
}

#define injectDependencies(object) \
[[Alchemic mainContext] injectDependencies:object]

/**
 This macros is used to register a class in Alchemic. Registered classes will be created automatically.
 */
#define registerComponent() \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, registerObject) { \
[[Alchemic mainContext] registerClass:self]; \
}

#define registerComponentWithName(name) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, registerObject) { \
[[Alchemic mainContext] registerClass:self withName:name]; \
}

/**
 Adds a pre-built object to the model.
 */
#define addObjectWithName(objectValue, objectName) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _alchemic_concat(object_, __LINE__)) { \
[[Alchemic mainContext] registerObject:(objectValue) withName:objectName]; \
}

/**
 This macros is used to specify that this class is a factory for other objects.
 */
#define registerFactory() \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, registerObject) { \
[[Alchemic mainContext] registerClass:self]; \
}

@interface Alchemic : NSObject

/**
 Returns the main context.
 
 @return An instance of ALCContext.
 */
+(ALCContext *) mainContext;

@end
