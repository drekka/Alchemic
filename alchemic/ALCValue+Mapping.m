//
//  ALCValue+ALCValue_Mapping.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCValue+Mapping.h"

#import <Alchemic/ALCInternalMacros.h>
@import ObjectiveC;

@implementation ALCValue (Mapping)

-(BOOL) mapInTo:(ALCValue *) toValue error:(NSError **) error {
    
    // Use the runtime to build a reference to the method.
    Method method;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"convert%@To%@:error:", self.methodNamePart, toValue.methodNamePart]);
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            return ((BOOL (*)(id, Method, ALCValue *, NSError **)) method_invoke)(self, method, toValue, error);
        }
    }
    setError(@"Unable to convert a %@ to a %@", self, toValue);
    return NO;
}

-(BOOL) convertObjectToInt:(ALCValue *) toValue error:(NSError **) error {
    return [self setToValue:toValue error:error withScalar:^NSValue *(NSNumber *number) {
        int scalar = number.intValue;
        return [NSValue value:&scalar withObjCType:toValue.scalarType];
    }];
}

-(BOOL) setToValue:(ALCValue *) toValue
             error:(NSError **) error
        withScalar:(NSValue * (^)(NSNumber *result)) getScalar {
    
    id obj = self.value.nonretainedObjectValue;
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        toValue.value = getScalar(obj);
        return YES;
    }
    
    setError(@"Cannot convert source %@ to NSNumber *", NSStringFromClass([obj class]));
    return NO;
}

@end
