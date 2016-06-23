//
//  ALCInternalMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCStringMacros.h>
#import <Alchemic/ALCException.h>

#define setWeakSelf __weak __typeof(self) weakSelf = self
#define setStrongSelf __typeof(self) strongSelf = weakSelf

#define throwException(exceptionName, template, ...) \
@throw [Alchemic ## exceptionName ## Exception exceptionWithName:alc_toNSString(exceptionName) reason:str(template, ## __VA_ARGS__) userInfo:nil]

#pragma mark - Assertions

#define methodNotImplemented \
[self doesNotRecognizeSelector:_cmd];

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

#pragma mark - Var arg lists

// Processes varadic args including the arg that delimits the var arg list.
#define alc_loadVarArgsIntoArray(firstArg, arrayVar) \
NSMutableArray *arrayVar = [[NSMutableArray alloc] init]; \
va_list argList; \
va_start(argList, firstArg); \
for (id nextArg = firstArg; nextArg != nil; nextArg = va_arg(argList, id)) { \
[arrayVar addObject:nextArg]; \
} \
va_end(argList)

// Processes varadic args excluding the arg that delimits the var arg list.
#define alc_loadVarArgsAfterVariableIntoArray(afterArg, arrayVar) \
NSMutableArray *arrayVar = [[NSMutableArray alloc] init]; \
va_list argList; \
va_start(argList, afterArg); \
id nextArg; \
while ((nextArg = va_arg(argList, id)) != nil) { \
[arrayVar addObject:nextArg]; \
} \
va_end(argList)

