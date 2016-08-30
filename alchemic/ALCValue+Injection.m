//
//  ALCValue+Injection.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
@import StoryTeller;

#import "ALCValue+Injection.h"

#import <Alchemic/ALCStringMacros.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCException.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue (Injection)

#pragma mark - Access points

-(nullable ALCVariableInjectorBlock) variableInjector {
    Method method;
    SEL selector = NSSelectorFromString(str(@"variableInjectorFor%@", self.methodNamePart));
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            return ((ALCVariableInjectorBlock (*)(id, Method)) method_invoke)(self, method);
        }
    }
    throwException(Injection, @"Unable to find variable injector for type: %@", self.typeDescription);
    return NULL;
}

-(nullable ALCInvocationInjectorBlock) invocationInjector {
    Method method;
    SEL selector = NSSelectorFromString(str(@"invocationInjectorFor%@", self.methodNamePart));
    STLog(self, @"Calling selector %@ to get injector", NSStringFromSelector(selector));
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            return ((ALCInvocationInjectorBlock (*)(id, Method)) method_invoke)(self, method);
        }
    }

    throwException(Injection, @"Unable to find invocation injector for type: %@", self.typeDescription);
    return NULL;
}

#pragma mark - Variable factories

-(ALCVariableInjectorBlock) variableInjectorForInt {
    return ^(ALCVariableInjectorBlockArgs) {
        int value;
        [self.value getValue:&value];
        CFTypeRef objRef = CFBridgingRetain(obj);
        int *ivarPtr = (int *) ((uint8_t *) objRef + ivar_getOffset(ivar));
        *ivarPtr = value;
        CFBridgingRelease(objRef);
        [ALCRuntime executeSimpleBlock:self.completion];
    };
}

-(ALCVariableInjectorBlock) variableInjectorForObject {
    return ^(ALCVariableInjectorBlockArgs) {
        id value;
        [self.value getValue:&value];
        object_setIvar(obj, ivar, value);
        [ALCRuntime executeSimpleBlock:self.completion];
    };
}

#pragma mark - Injector factories

#define injectorFunction(type, typeName) \
-(ALCInvocationInjectorBlock) invocationInjectorFor ## typeName { \
    return ^(ALCInvocationInjectorBlockArgs) { \
        type value; \
        [self.value getValue:&value]; \
        [ALCRuntime executeSimpleBlock:self.completion]; \
        [inv setArgument:&value atIndex:idx + 2]; \
    }; \
}

injectorFunction(int, Int)
injectorFunction(id, Object)

@end

NS_ASSUME_NONNULL_END
