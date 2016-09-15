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

#pragma mark - Objects

-(nullable ALCValue *) convertObjectToObject:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {

    // If object classes are castable, then return self.
    Class targetClass = toType.objcClass ? toType.objcClass : [NSObject class];
    if ([[self.value class] isSubclassOfClass:targetClass]) {
        return self;
    }

    setError(@"Cannot convert a %@ to a %@", NSStringFromClass([self.value class]), NSStringFromClass([toType.objcClass class]));
    return nil;
}

-(nullable ALCValue *) convertObjectToArray:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {
    return [ALCValue withValue:@[self.value] completion:self.completion];
}

#define defineConvertObjectToScalarMethod(toTypeName, scalarVarType, numberFuction) \
-(nullable ALCValue *) convertObjectTo ## toTypeName:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error { \
return [self convertNSNumberToValueWithError:error usingConverter:^NSValue *(NSNumber *number) { \
scalarVarType scalar = number.numberFuction; \
return [NSValue valueWithBytes:&scalar objCType:toType.scalarType.UTF8String]; \
}]; \
}

defineConvertObjectToScalarMethod(Bool, BOOL, boolValue)
defineConvertObjectToScalarMethod(Int, int, intValue)
defineConvertObjectToScalarMethod(Double, double, doubleValue)
defineConvertObjectToScalarMethod(Float, float, floatValue)
defineConvertObjectToScalarMethod(Short, short, shortValue)
defineConvertObjectToScalarMethod(Long, long, longValue)
defineConvertObjectToScalarMethod(LongLong, long long, longLongValue)
defineConvertObjectToScalarMethod(UnsignedInt, unsigned int, unsignedIntValue)
defineConvertObjectToScalarMethod(UnsignedLong, unsigned long, unsignedLongValue)
defineConvertObjectToScalarMethod(UnsignedLongLong, unsigned long long, unsignedLongLongValue)
defineConvertObjectToScalarMethod(UnsignedShort, unsigned short, unsignedShortValue)

#pragma mark - Arrays

-(nullable ALCValue *) convertArrayToArray:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {
    return self;
}

-(nullable ALCValue *) convertArrayToObject:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error {

    NSArray *objs = self.value;

    if (objs.count > 1) {
        setError(@"Too many values. Expected 1 %@ value.", NSStringFromClass(toType.objcClass));
        return nil;
    }

    if (objs.count == 0) {
        // Return a nil value.
        return [ALCValue withValue:[NSNull null] completion:NULL];
    }

    id obj = objs[0];
    if (!toType.objcClass || [obj isKindOfClass:toType.objcClass]) {
        return [ALCValue withValue:obj completion:self.completion];
    } else {
        setError(@"Cannot covert a %@ to a %@", NSStringFromClass([obj class]), NSStringFromClass(toType.objcClass));
        return nil;
    }
}

#pragma mark - Scalars

#define defineConvertScalarToSameMethod(typeName) \
-(nullable ALCValue *) convert ## typeName ## To ## typeName:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error { \
return self; \
}

#define defineConvertScalarToScalarMethod(fromName, fromScalarType, toName, toScalarType) \
-(nullable ALCValue *) convert ## fromName ## To ## toName:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error { \
fromScalarType value; \
[(NSValue *) self.value getValue:&value]; \
toScalarType newValue = (toScalarType) value; \
return [ALCValue withValue:[NSValue valueWithBytes:&newValue objCType:@encode(toScalarType)] completion:NULL]; \
}

#define defineConvertScalarToObjectMethod(fromName, fromScalarType) \
-(nullable ALCValue *) convert ## fromName ## ToObject:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error { \
fromScalarType value; \
[(NSValue *) self.value getValue:&value]; \
return [ALCValue withValue:@(value) completion:NULL]; \
}

#define defineConvertScalarToArrayMethod(fromName, fromScalarType) \
-(nullable ALCValue *) convert ## fromName ## ToArray:(ALCType *) toType error:(NSError * __autoreleasing _Nullable *) error { \
fromScalarType value; \
[(NSValue *) self.value getValue:&value]; \
return [ALCValue withValue:@[@(value)] completion:NULL]; \
}

defineConvertScalarToSameMethod(Bool)
defineConvertScalarToSameMethod(Char)
defineConvertScalarToSameMethod(CharPointer)
defineConvertScalarToSameMethod(Float)
defineConvertScalarToSameMethod(Short)
defineConvertScalarToSameMethod(UnsignedChar)
defineConvertScalarToSameMethod(UnsignedInt)
defineConvertScalarToSameMethod(UnsignedLong)
defineConvertScalarToSameMethod(UnsignedLongLong)
defineConvertScalarToSameMethod(UnsignedShort)

defineConvertScalarToSameMethod(Int)
defineConvertScalarToScalarMethod(Int, int, Double, double)
defineConvertScalarToScalarMethod(Int, int, Float, float)
defineConvertScalarToScalarMethod(Int, int, Long, signed long)
defineConvertScalarToScalarMethod(Int, int, LongLong, signed long long)
defineConvertScalarToScalarMethod(Int, int, Short, short)
defineConvertScalarToScalarMethod(Int, int, UnsignedInt, unsigned int)
defineConvertScalarToScalarMethod(Int, int, UnsignedLong, unsigned long)
defineConvertScalarToScalarMethod(Int, int, UnsignedLongLong, unsigned long long)
defineConvertScalarToScalarMethod(Int, int, UnsignedShort, unsigned short)
defineConvertScalarToObjectMethod(Int, int)
defineConvertScalarToArrayMethod(Int, int)

defineConvertScalarToSameMethod(Double)
defineConvertScalarToScalarMethod(Double, double, Int, int)
defineConvertScalarToScalarMethod(Double, double, Float, float)
defineConvertScalarToScalarMethod(Double, double, Long, signed long)
defineConvertScalarToScalarMethod(Double, double, LongLong, signed long long)
defineConvertScalarToScalarMethod(Double, double, Short, short)
defineConvertScalarToScalarMethod(Double, double, UnsignedInt, unsigned int)
defineConvertScalarToScalarMethod(Double, double, UnsignedLong, unsigned long)
defineConvertScalarToScalarMethod(Double, double, UnsignedLongLong, unsigned long long)
defineConvertScalarToScalarMethod(Double, double, UnsignedShort, unsigned short)
defineConvertScalarToObjectMethod(Double, double)
defineConvertScalarToArrayMethod(Double, double)

defineConvertScalarToSameMethod(Long)
defineConvertScalarToScalarMethod(Long, long, Double, double)
defineConvertScalarToScalarMethod(Long, long, Float, float)
defineConvertScalarToScalarMethod(Long, long, Int, signed int)
defineConvertScalarToScalarMethod(Long, long, LongLong, signed long long)
defineConvertScalarToScalarMethod(Long, long, Short, short)
defineConvertScalarToScalarMethod(Long, long, UnsignedInt, unsigned int)
defineConvertScalarToScalarMethod(Long, long, UnsignedLong, unsigned long)
defineConvertScalarToScalarMethod(Long, long, UnsignedLongLong, unsigned long long)
defineConvertScalarToScalarMethod(Long, long, UnsignedShort, unsigned short)
defineConvertScalarToObjectMethod(Long, long)
defineConvertScalarToArrayMethod(Long, long)

defineConvertScalarToSameMethod(LongLong)
defineConvertScalarToScalarMethod(LongLong, long long, Double, double)
defineConvertScalarToScalarMethod(LongLong, long long, Float, float)
defineConvertScalarToScalarMethod(LongLong, long long, Int, signed int)
defineConvertScalarToScalarMethod(LongLong, long long, Long, signed long)
defineConvertScalarToScalarMethod(LongLong, long long, Short, short)
defineConvertScalarToScalarMethod(LongLong, long long, UnsignedInt, unsigned int)
defineConvertScalarToScalarMethod(LongLong, long long, UnsignedLong, unsigned long)
defineConvertScalarToScalarMethod(LongLong, long long, UnsignedLongLong, unsigned long long)
defineConvertScalarToScalarMethod(LongLong, long long, UnsignedShort, unsigned short)
defineConvertScalarToObjectMethod(LongLong, long long)
defineConvertScalarToArrayMethod(LongLong, long long)

#pragma mark - Internal helpers

-(nullable ALCValue *) convertNSNumberToValueWithError:(NSError * __autoreleasing _Nullable *) error
                                        usingConverter:(NSValue * (^)(NSNumber *result)) converter {

    if ([self.value isKindOfClass:[NSNumber class]]) {
        return [ALCValue withValue:converter(self.value) completion:NULL];
    }

    setError(@"Cannot convert source %@ to NSNumber *", NSStringFromClass([self.value class]));
    return nil;
}

@end
