//
//  AlchemicInternal.h
//  alchemic
//
//  Created by Derek Clarkson on 14/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#define ALCHEMIC_LOG @"Alchemic"

#define ALCHEMIC_PREFIX _alc_

#define blockSelf __weak __typeof(self) weakSelf = self;__typeof(self) strongSelf = weakSelf

// Used to assemble two strings. We use double macros to ensure any
// embedded macros are resolved.
#define alc_concat(prefix, suffix) _alc_concat(prefix, suffix)
#define _alc_concat(prefix, suffix) prefix ## suffix

#define ALCHEMIC_METHOD_PREFIX alc_concat(ALCHEMIC_PREFIX, __LINE__)

// Convert raw macro text to a char *
#define alc_toCharPointer(text) _alc_toCharPointer(text)
#define _alc_toCharPointer(text) #text

// Convert raw macro text to a NSString *
#define alc_toNSString(chars) _alc_toNSString(chars)
#define _alc_toNSString(chars) @#chars

// Processes varadic args including the arg that delimits the var arg list.
#define alc_processVarArgsIncluding(argType, firstArg, codeBlock) \
{ \
va_list argList; \
va_start(argList, firstArg); \
for (argType nextArg = firstArg; nextArg != nil; nextArg = va_arg(argList, argType)) { \
codeBlock(nextArg); \
} \
va_end(argList); \
}

// Processes varadic args excluding the arg that delimits the var arg list.
#define alc_processVarArgsAfter(argType, afterArg, codeBlock) \
{ \
va_list argList; \
va_start(argList, afterArg); \
id nextArg; \
while ((nextArg = va_arg(argList, id)) != nil) { \
codeBlock(nextArg); \
} \
va_end(argList); \
}

// Processes varadic args into a macro processor, excluding the arg that is used to guard them.
#define alc_loadMacrosAfter(processorVar, afterArg) \
alc_processVarArgsAfter(id<ALCMacro>, afterArg, ^(id<ALCMacro> macro){[processorVar addMacro:macro];});

// Processes varadic args into a macro processor, including the arg that is used to guard them.
#define alc_loadMacrosIncluding(processorVar, firstArg) \
alc_processVarArgsIncluding(id<ALCMacro>, firstArg, ^(id<ALCMacro> macro){[processorVar addMacro:macro];});

#define ignoreSelectorWarnings(code) \
_Pragma ("clang diagnostic push") \
_Pragma ("clang diagnostic ignored \"-Wselector\"") \
_Pragma ("clang diagnostic ignored \"-Wundeclared-selector\"") \
code \
_Pragma ("clang diagnostic pop")


