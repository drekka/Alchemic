//
//  AlchemicInternal.h
//  alchemic
//
//  Created by Derek Clarkson on 14/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#define ALCHEMIC_LOG @"Alchemic"

#define ALCHEMIC_PREFIX _alchemic_

// Used to assemble two strings. We use double macros to ensure any
// embedded macros are resolved.
#define _alchemic_concat(prefix, suffix) _alchemic_concat_strings(prefix, suffix)
#define _alchemic_concat_strings(prefix, suffix) prefix ## suffix

#define ALCHEMIC_METHOD_PREFIX _alchemic_concat(ALCHEMIC_PREFIX, __LINE__)

// Convert raw macro text to a char *
#define _alchemic_toCharPointer(text) __alchemic_toCharPointer(text)
#define __alchemic_toCharPointer(text) #text

// Convert raw macro text to a NSString *
#define _alchemic_toNSString(chars) __alchemic_toNSString(chars)
#define __alchemic_toNSString(chars) @#chars

#define loadMacrosAfter(processorVar, afterArg) \
{ \
va_list args; \
va_start(args, afterArg); \
id arg; \
while ((arg = va_arg(args, id)) != nil) { \
[processorVar addArgument:arg]; \
} \
va_end(args); \
[processorVar validate]; \
}

#define loadMacrosIncluding(processorVar, firstArg) \
{ \
va_list args; \
va_start(args, firstArg); \
for (id arg = firstArg; arg != nil; arg = va_arg(args, id)) { \
[processorVar addArgument:arg]; \
} \
va_end(args); \
[processorVar validate]; \
}

#define wrapperArgTypes(...) , ## __VA_ARGS__
#define wrapperArgNames(...) , ## __VA_ARGS__

#define insertInitWrapper(destClass, initializerSel, initSig, initArgTypes, initArgNames) \
initWrapper(initSig, wrapperArgTypes(initArgTypes), (initArgNames)) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _injectInitWrapper) { \
   [ALCRuntime wrapClass:[destClass class] initializer:@selector(initializerSel) \
	withClass:[self class] wrapper:@selector(initWrapper ## initializerSel)]; \
} \

#define initWrapper(initSig, initArgTypes, initArgNames) \
-(id) initWrapper ## initSig { \
   SEL relocatedInitSel = [ALCRuntime alchemicSelectorForSelector:_cmd]; \
   if ([self respondsToSelector:relocatedInitSel]) { \
      self = ((id (*)(id, SEL initArgTypes)) objc_msgSend)(self, relocatedInitSel initArgNames); \
	} else { \
      struct objc_super superData = {self, class_getSuperclass([self class])}; \
      self = ((id (*)(struct objc_super *, SEL initArgTypes))objc_msgSendSuper)(&superData, initSel initArgNames); \
   } \
   STLog([self class], @"Triggering dependency injection from -[%s %s]", class_getName([self class]), sel_getName(initSel)); \
   [[ALCAlchemic mainContext] injectDependencies:self]; \
   return self; \
}



