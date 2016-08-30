//
//  ALCValue+Injection.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCValue+Injection.h"

#import <Alchemic/ALCStringMacros.h>
#import <Alchemic/ALCRuntime.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue (Injection)

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
    return NULL;
}

-(nullable ALCInvocationInjectorBlock) invocationInjector {
    Method method;
    SEL selector = NSSelectorFromString(str(@"invocationInjectorFor%@", self.methodNamePart));
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            return ((ALCInvocationInjectorBlock (*)(id, Method)) method_invoke)(self, method);
        }
    }
    return NULL;
}


-(ALCVariableInjectorBlock) variableInjectorForInt {
    return ^(ALCVariableInjectorBlockArgs) {
        
        // Convert back to an int.
        int intValue;
        [self.value getValue:&intValue];
        
        // Set the variable.
        CFTypeRef objRef = CFBridgingRetain(obj);
        int *ivarPtr = (int *) ((uint8_t *) objRef + ivar_getOffset(ivar));
        *ivarPtr = intValue;
        CFBridgingRelease(objRef);
        [ALCRuntime executeSimpleBlock:self.completion];
    };
}

-(ALCInvocationInjectorBlock) invocationInjectorForInt {
    return ^(ALCInvocationInjectorBlockArgs) {
        
        // Convert back to an int.
        int intValue;
        [self.value getValue:&intValue];
        
        // Set the variable.
        [ALCRuntime executeSimpleBlock:self.completion];
        [inv setArgument:&intValue atIndex:idx + 2];
    };
}

@end

NS_ASSUME_NONNULL_END
