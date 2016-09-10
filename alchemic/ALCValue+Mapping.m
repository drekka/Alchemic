//
//  ALCValue+ALCValue_Mapping.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
@import StoryTeller;

#import <Alchemic/ALCValue+Mapping.h>

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCType.h>

@implementation ALCValue (Mapping)

-(nullable ALCValue *) mapTo:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {
    
    if (self.type != ALCValueTypeObject && self.type == toType.type) {
        STLog(self, @"No mapping required for final value");
        return self;
    }
    
    // Use the runtime to build a reference to the method.
    Method method;
    SEL selector = NSSelectorFromString(str(@"convert%@To%@:error:", self.methodNameFragment, toType.methodNameFragment));
    STLog(self, @"Looking for selector %@", NSStringFromSelector(selector));
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

#pragma mark - Mapping routines

-(nullable ALCValue *) convertObjectToObject:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {

    //
    if (!toType.objcClass || [[self.value class] isSubclassOfClass:toType.objcClass]) {
        // Ok to map. No to class is id type.
    } else {
        setError(@"Cannot convert a %@ to a %@", NSStringFromClass([self.value class]), NSStringFromClass([toType.objcClass class]));
        return nil;
    }
    return nil;
}

-(nullable ALCValue *) convertObjectToArray:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {
    return [ALCValue withType:ALCValueTypeArray value:@[self.value] completion:self.completion];
}

#define convertObjectToNumber(toTypeName, scalarTypeDef, numberFuction) \
-(nullable ALCValue *) convertObjectTo ## toTypeName:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error { \
    return [self valueOfType:toType error:error withNumberConversion:^NSValue *(NSNumber *number) { \
        scalarTypeDef scalar = number.numberFuction; \
        return [NSValue value:&scalar withObjCType:toType.scalarType.UTF8String]; \
    }]; \
}

convertObjectToNumber(Bool, BOOL, boolValue)
convertObjectToNumber(Int, int, intValue)
convertObjectToNumber(Double, double, doubleValue)
convertObjectToNumber(Float, float, floatValue)
convertObjectToNumber(Short, short, shortValue)
convertObjectToNumber(Long, long, longValue)
convertObjectToNumber(LongLong, long long, longLongValue)
convertObjectToNumber(UnsignedInt, unsigned int, unsignedIntValue)
convertObjectToNumber(UnsignedLong, unsigned long, unsignedLongValue)
convertObjectToNumber(UnsignedLongLong, unsigned long long, unsignedLongLongValue)
convertObjectToNumber(UnsignedShort, unsigned short, unsignedShortValue)

-(nullable ALCValue *) convertArrayToObject:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {
    
    NSArray *objs = self.value;
    
    if (objs.count > 1) {
        setError(@"Too many values. Expected 1 %@ value.", NSStringFromClass(toType.objcClass));
        return nil;
    }
    
    if (objs.count == 0) {
        // Return a nil value.
        return [ALCValue withType:ALCValueTypeObject value:[NSNull null] completion:NULL];
    }
    
    id obj = objs[0];
    if ([obj isKindOfClass:toType.objcClass]) {
        return [ALCValue withType:toType.type value:obj completion:self.completion];
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
        return [ALCValue withType:type.type value:numberConversion(self.value) completion:self.completion];
    }
    
    setError(@"Cannot convert source %@ to NSNumber *", NSStringFromClass([self.value class]));
    return nil;
}

@end
