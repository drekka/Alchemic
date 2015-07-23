//
//  AlchemicInternal.h
//  alchemic
//
//  Created by Derek Clarkson on 14/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#define ALCHEMIC_LOG @"Alchemic"

#define ALCHEMIC_PREFIX _alc_

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

// Processes varadic args
#define alc_processVarArgsIncluding(argType, firstArg, codeBlock) \
{ \
va_list argList; \
va_start(argList, firstArg); \
for (argType nextArg = firstArg; nextArg != nil; nextArg = va_arg(argList, argType)) { \
codeBlock(nextArg); \
} \
va_end(argList); \
}

// Processes varadic args into a macro processor, excluding the arg that is used to guard them.
#define alc_loadMacrosAfter(processorVar, afterArg) \
{ \
va_list macroList; \
va_start(macroList, afterArg); \
id macro; \
while ((macro = va_arg(macroList, id)) != nil) { \
[processorVar addMacro:macro]; \
} \
va_end(macroList); \
[processorVar validate]; \
}

// Processes varadic args into a macro processor, including the arg that is used to guard them.
#define alc_loadMacrosIncluding(processorVar, firstArg) \
alc_processVarArgsIncluding(id<ALCMacro>, firstArg, ^(id<ALCMacro> macro){[processorVar addMacro:macro];}); \
[processorVar validate];

