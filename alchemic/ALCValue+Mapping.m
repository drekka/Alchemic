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

-(nullable ALCValue *) mapTo:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {

    // Use the runtime to build a reference to the method.
    Method method;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"convert%@To%@:error:", self.methodNamePart, toType.methodNamePart]);
    if (selector) {
        method = class_getInstanceMethod([self class], selector);
        if (method) {
            // Dynamically call the selector method to do the converstion.
            return ((ALCValue * (*)(id, Method, ALCType *, NSError * __autoreleasing _Nullable *)) method_invoke)(self, method, toType, error);
        }
    }
    setError(@"Unable to convert a %@ to a %@", self, toType);
    return nil;
}

-(nullable ALCValue *) convertObjectToInt:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {
    return [self valueOfType:toType error:error withNumberConversion:^NSValue *(NSNumber *number) {
        int scalar = number.intValue;
        return [NSValue value:&scalar withObjCType:toType.scalarType];
    }];
}

#pragma mark - Internal

-(nullable ALCValue *) valueOfType:(ALCType *) type
                             error:(NSError * __autoreleasing _Nullable *) error
              withNumberConversion:(NSValue * (^)(NSNumber *result)) numberConversion {

    id obj = self.value.nonretainedObjectValue;

    if ([obj isKindOfClass:[NSNumber class]]) {
        return [ALCValue valueWithType:type value:numberConversion(obj) completion:self.completion];
    }

    setError(@"Cannot convert source %@ to NSNumber *", NSStringFromClass([obj class]));
    return nil;
}

@end
