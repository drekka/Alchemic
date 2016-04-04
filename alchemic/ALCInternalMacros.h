//
//  ALCInternalMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCRuntime.h"
#import "ALCException.h"

#define ALCHEMIC_PREFIX _alc_
#define ALCHEMIC_METHOD_PREFIX alc_concat(ALCHEMIC_PREFIX, __LINE__)

// Used to assemble two strings. We use double macros to ensure any
// embedded macros are resolved.
#define alc_concat(prefix, suffix) _alc_concat(prefix, suffix)
#define _alc_concat(prefix, suffix) prefix ## suffix

#pragma mark - Useful code defines

#define str(template, ...) [NSString stringWithFormat:template, ## __VA_ARGS__ ]

#define blockSelf __weak __typeof(self) weakSelf = self;__typeof(self) strongSelf = weakSelf

#define throwException(exceptionName, template, ...) \
@throw [ALCException \
        exceptionWithName:exceptionName \
        reason:str(template, ## __VA_ARGS__) \
        userInfo:nil]

#pragma mark - Assertions

#define methodNotImplemented \
NSAssert(NO, @"Abstract method %@ not implemented.", [ALCRuntime selectorDescription:[self class] selector:_cmd])

#define methodReturningObjectNotImplemented \
methodNotImplemented; \
return nil

#define methodReturningIntNotImplemented \
methodNotImplemented; \
return 0

#define methodReturningBooleanNotImplemented \
methodNotImplemented; \
return NO

#define methodReturningBlockNotImplemented \
methodNotImplemented; \
return NULL

#pragma mark - Unneccessary warnings

#define ignoreSelectorWarnings(code) \
_Pragma ("clang diagnostic push") \
_Pragma ("clang diagnostic ignored \"-Wselector\"") \
_Pragma ("clang diagnostic ignored \"-Wundeclared-selector\"") \
code \
_Pragma ("clang diagnostic pop")

#pragma mark - Var arg lists

// Processes varadic args including the arg that delimits the var arg list.
#define alc_loadVarArgsIntoArray(firstArg, arrayVar) \
va_list argList; \
va_start(argList, firstArg); \
for (id nextArg = firstArg; nextArg != nil; nextArg = va_arg(argList, id)) { \
[arrayVar addObject:nextArg]; \
} \
va_end(argList)

// Processes varadic args excluding the arg that delimits the var arg list.
#define alc_loadVarArgsAfterVariableIntoArray(afterArg, arrayVar) \
va_list argList; \
va_start(argList, afterArg); \
id nextArg; \
while ((nextArg = va_arg(argList, id)) != nil) { \
[arrayVar addObject:nextArg]; \
} \
va_end(argList)

