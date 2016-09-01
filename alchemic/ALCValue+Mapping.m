//
//  ALCValue+ALCValue_Mapping.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCValue+Mapping.h>

#import <Alchemic/ALCInternalMacros.h>
@import ObjectiveC;
@import StoryTeller;

@implementation ALCValue (Mapping)

-(nullable ALCValue *) mapTo:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {
    
    if (self.type == toType.type) {
        STLog(self, @"No mapping required for final value");
        return self;
    }
    
    // Use the runtime to build a reference to the method.
    Method method;
    SEL selector = NSSelectorFromString(str(@"convert%@To%@:error:", self.methodNameFragment, toType.methodNameFragment));
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            STLog(self, @"Calling selector %@", NSStringFromSelector(selector));
            return ((ALCValue * (*)(id, Method, ALCType *, NSError * __autoreleasing _Nullable *)) method_invoke)(self, method, toType, error);
        }
    }
    setError(@"Unable to convert a %@ to a %@", self, toType);
    return nil;
}

-(nullable ALCValue *) convertObjectToInt:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {
    return [self valueOfType:toType error:error withNumberConversion:^NSValue *(NSNumber *number) {
        int scalar = number.intValue;
        return [NSValue value:&scalar withObjCType:toType.scalarType.UTF8String];
    }];
}

-(nullable ALCValue *) convertArrayToObject:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {
    
    NSArray *objs = self.value;
    
    if (objs.count > 1) {
        setError(@"Too many values. Expected 1 %@ value.", NSStringFromClass(toType.objcClass));
        return nil;
    }
    
    if (objs.count == 0) {
        // Return a nil value.
        return [toType withValue:[NSNull null] completion:NULL];
    }
    
    id obj = objs[0];
    if ([obj isKindOfClass:toType.objcClass]) {
        return [toType withValue:obj completion:self.completion];
    } else {
        setError(@"Cannot covert a %@ to a %@", NSStringFromClass([obj class]), NSStringFromClass(toType.objcClass));
        return nil;
    }
}

#pragma mark - Internal

-(nullable ALCValue *) valueOfType:(ALCType *) type
                             error:(NSError * __autoreleasing _Nullable *) error
              withNumberConversion:(NSValue * (^)(NSNumber *result)) numberConversion {
    
    if ([self.value isKindOfClass:[NSNumber class]]) {
        return [type withValue:numberConversion(self.value) completion:self.completion];
    }
    
    setError(@"Cannot convert source %@ to NSNumber *", NSStringFromClass([self.value class]));
    return nil;
}

@end
