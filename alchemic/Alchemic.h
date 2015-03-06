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
#define inject(...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, __LINE__) { \
[[Alchemic mainContext] registerClass:self withInjectionPoints: __VA_ARGS__, NULL]; \
}

/**
 This macros is used to specify that this class is a singleton.
 */
#define registerSingleton() \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, registerSingleton) { \
[[Alchemic mainContext] registerSingleton:self]; \
}

@interface Alchemic : NSObject

/**
 Returns the main context.
 
 @return An instance of ALCContext.
 */
+(ALCContext *) mainContext;

@end
