//
//  ALCValue+Injection.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
@import StoryTeller;
@import CoreGraphics;

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
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            STLog(self, @"Calling selector %@ to get injector", NSStringFromSelector(selector));
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

scalarVariableInjector(BOOL, Bool)
scalarVariableInjector(char, Char)
scalarVariableInjector(char *, CharPointer)
scalarVariableInjector(double, Double)
scalarVariableInjector(float, Float)
scalarVariableInjector(int, Int)
scalarVariableInjector(long, Long)
scalarVariableInjector(long long, LongLong)
scalarVariableInjector(short, Short)
scalarVariableInjector(unsigned char, UnsignedChar)
scalarVariableInjector(unsigned int, UnsignedInt)
scalarVariableInjector(unsigned long, UnsignedLong)
scalarVariableInjector(unsigned long long, UnsignedLongLong)
scalarVariableInjector(unsigned short, UnsignedShort)

scalarVariableInjector(CGSize, CGSize)
scalarVariableInjector(CGPoint, CGPoint)
scalarVariableInjector(CGRect, CGRect)

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

scalarMethodArgumentInjector(BOOL, Bool)
scalarMethodArgumentInjector(char, Char)
scalarMethodArgumentInjector(char *, CharPointer)
scalarMethodArgumentInjector(double, Double)
scalarMethodArgumentInjector(float, Float)
scalarMethodArgumentInjector(int, Int)
scalarMethodArgumentInjector(double, Long)
scalarMethodArgumentInjector(long long, LongLong)
scalarMethodArgumentInjector(short, Short)
scalarMethodArgumentInjector(unsigned char, UnsignedChar)
scalarMethodArgumentInjector(unsigned int, UnsignedInt)
scalarMethodArgumentInjector(unsigned long, UnsignedLong)
scalarMethodArgumentInjector(unsigned long long, UnsignedLongLong)
scalarMethodArgumentInjector(short, UnsignedShort)

scalarMethodArgumentInjector(CGSize, CGSize)
scalarMethodArgumentInjector(CGPoint, CGPoint)
scalarMethodArgumentInjector(CGRect, CGRect)

-(ALCInvocationInjectorBlock) invocationInjectorForObject {
    return ^(ALCInvocationInjectorBlockArgs) {
        id value = self.value;
        [ALCRuntime executeSimpleBlock:self.completion];
        [inv setArgument:&value atIndex:idx + 2];
    };
}

-(ALCInvocationInjectorBlock) invocationInjectorForArray {
    return ^(ALCInvocationInjectorBlockArgs) {
        NSArray *value = self.value;
        [ALCRuntime executeSimpleBlock:self.completion];
        [inv setArgument:&value atIndex:idx + 2];
    };
}

@end

NS_ASSUME_NONNULL_END
