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

// This macros is used to do injections. The args can be any combination of
// variable names, property names or internal property variables.
#define injectValues(...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _alchemic_concat(dependency_, __LINE__)) { \
[[Alchemic mainContext] registerClass:self injectionPoints:__VA_ARGS__, NULL]; \
}

/**
 This macros is used to register a class in Alchemic. Registered classes will be created automatically.
 */
#define registerComponent() \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, registerObject) { \
[[Alchemic mainContext] registerClass:self]; \
}

#define injectDependencies(object) \
[[Alchemic mainContext] injectDependencies:object];

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
