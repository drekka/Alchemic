//
//  ALCValue+Injection.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
@import StoryTeller;

#import <Alchemic/ALCValue+Injection.h>

#import <Alchemic/ALCStringMacros.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCException.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue (Injection)

#pragma mark - Access points

-(nullable ALCVariableInjectorBlock) variableInjector {
    Method method;
    SEL selector = NSSelectorFromString(str(@"variableInjectorFor%@", self.methodNameFragment));
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            STLog(self, @"Calling selector %@ to get injector", NSStringFromSelector(selector));
            return ((ALCVariableInjectorBlock (*)(id, Method)) method_invoke)(self, method);
        }
    }
    throwException(AlchemicSelectorNotFoundException, @"Unable to find variable injector for type: %@", self.description);
    return NULL;
}

-(nullable ALCInvocationInjectorBlock) invocationInjector {
    Method method;
    SEL selector = NSSelectorFromString(str(@"invocationInjectorFor%@", self.methodNameFragment));
    STLog(self, @"Calling selector %@ to get injector", NSStringFromSelector(selector));
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            return ((ALCInvocationInjectorBlock (*)(id, Method)) method_invoke)(self, method);
        }
    }

    throwException(AlchemicSelectorNotFoundException, @"Unable to find invocation injector for type: %@", self.description);
    return NULL;
}

#pragma mark - Variable injectors

#define scalarVariableInjector(type, typeName) \
-(ALCVariableInjectorBlock) variableInjectorFor ## typeName { \
    return ^(ALCVariableInjectorBlockArgs) { \
        type value; \
        [self.value getValue:&value]; \
        CFTypeRef objRef = CFBridgingRetain(obj); \
        type *ivarPtr = (type *) ((uint8_t *) objRef + ivar_getOffset(ivar)); \
        *ivarPtr = value; \
        CFBridgingRelease(objRef); \
        [ALCRuntime executeSimpleBlock:self.completion]; \
    }; \
}

scalarVariableInjector(int, Int)

-(ALCVariableInjectorBlock) variableInjectorForArray {
    return [self variableInjectorForObject];
}

-(ALCVariableInjectorBlock) variableInjectorForObject {
    return ^(ALCVariableInjectorBlockArgs) {

        id value = self.value;
        
        // Check for setting a nil.
        if (value == [NSNull null]) {
            value = nil;
        }
        
        // Patch for Swift Ivars not being retained.
        const char *encoding = ivar_getTypeEncoding(ivar);
        if (value && strlen(encoding) == 0) {
            // Swift ivar? Currently returning no encoding.
            // Fixing bug with missing retain when setting Swift ivars via object_setVar(...) which causes EXC BAD ACCESS
            // This code seems to fix the missing retain back in.
            const void * ptr = CFBridgingRetain(value);
            value = CFBridgingRelease(ptr);
        }
        
        object_setIvar(obj, ivar, value);
        [ALCRuntime executeSimpleBlock:self.completion];
    };
}

#pragma mark - Method argument injectors

#define scalarMethodArgumentInjector(type, typeName) \
-(ALCInvocationInjectorBlock) invocationInjectorFor ## typeName { \
    return ^(ALCInvocationInjectorBlockArgs) { \
        type value; \
        [self.value getValue:&value]; \
        [ALCRuntime executeSimpleBlock:self.completion]; \
        [inv setArgument:&value atIndex:idx + 2]; \
    }; \
}

#define methodArgumentInjector(type, typeName) \
-(ALCInvocationInjectorBlock) invocationInjectorFor ## typeName { \
return ^(ALCInvocationInjectorBlockArgs) { \
type value = self.value; \
[ALCRuntime executeSimpleBlock:self.completion]; \
[inv setArgument:&value atIndex:idx + 2]; \
}; \
}

scalarMethodArgumentInjector(int, Int)
methodArgumentInjector(id, Object)
methodArgumentInjector(NSArray *, Array)

@end

NS_ASSUME_NONNULL_END
