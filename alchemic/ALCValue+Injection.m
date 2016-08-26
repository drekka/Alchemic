//
//  ALCValue+Injection.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCValue+Injection.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue (Injection)

-(nullable VariableInjectorBlock) variableInjector {
    Method method;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"variableInjectorFor%@", self.methodNamePart]);
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            return ((VariableInjectorBlock (*)(id, Method)) method_invoke)(self, method);
        }
    }
    return NULL;
}

-(nullable InvocationInjectorBlock) invocationInjector {
    Method method;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"invocationInjectorFor%@", self.methodNamePart]);
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            return ((InvocationInjectorBlock (*)(id, Method)) method_invoke)(self, method);
        }
    }
    return NULL;
}


-(VariableInjectorBlock) variableInjectorForInt {
    return ^(VariableInjectorBlockArgs) {
        
        // Convert back to an int.
        int intValue;
        [self.value getValue:&intValue];
        
        // Set the variable.
        CFTypeRef objRef = CFBridgingRetain(obj);
        int *ivarPtr = (int *) ((uint8_t *) objRef + ivar_getOffset(ivar));
        *ivarPtr = intValue;
        CFBridgingRelease(objRef);
    };
}

-(InvocationInjectorBlock) invocationInjectorForInt {
    return ^(InvocationInjectorBlockArgs) {
        
        // Convert back to an int.
        int intValue;
        [self.value getValue:&intValue];
        
        // Set the variable.
        [inv setArgument:&intValue atIndex:idx + 2];
    };
}

@end

NS_ASSUME_NONNULL_END
