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

#import "ALCValue+Injection.h"

#import "ALCStringMacros.h"
#import "ALCInternalMacros.h"
#import "ALCException.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValue (Injection)

#pragma mark - Access points

-(nullable ALCVariableInjectorBlock) variableInjectorForType:(ALCType *) type {
    Method method = [self methodWithPrefix:@"variableInjectorFor" forType:type];
    return ((ALCVariableInjectorBlock (*)(id, Method)) method_invoke)(self, method);
}

-(nullable ALCInvocationInjectorBlock) invocationInjectorForType:(ALCType *) type {
    Method method = [self methodWithPrefix:@"invocationInjectorFor" forType:type];
    return ((ALCInvocationInjectorBlock (*)(id, Method)) method_invoke)(self, method);
}

#pragma mark - Variable injectors

#define scalarVariableInjector(type, typeName) \
-(ALCVariableInjectorBlock) variableInjectorFor ## typeName { \
return ^BOOL(ALCVariableInjectorBlockArgs) { \
type value; \
[self.object getValue:&value]; \
CFTypeRef objRef = CFBridgingRetain(obj); \
type *ivarPtr = (type *) ((uint8_t *) objRef + ivar_getOffset(ivar)); \
*ivarPtr = value; \
CFBridgingRelease(objRef); \
[self complete]; \
return YES; \
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
    return ^BOOL(ALCVariableInjectorBlockArgs) {
        id value = [self valueAsArrayError:error];
        if (!value && *error) {
            return NO;
        }
        return [self injectValue:value ofType:type intoObject:obj variable:ivar error:error];
    };
}

-(ALCVariableInjectorBlock) variableInjectorForObject {
    return ^BOOL(ALCVariableInjectorBlockArgs) {
        id value = [self valueAsObjectError:error];
        if (!value && *error) {
            return NO;
        }
        return [self injectValue:value ofType:type intoObject:obj variable:ivar error:error];
    };
}

#pragma mark - Method argument injectors

#define scalarMethodArgumentInjector(scalarType, typeName) \
-(ALCInvocationInjectorBlock) invocationInjectorFor ## typeName { \
return ^BOOL(ALCInvocationInjectorBlockArgs) { \
scalarType value; \
[(NSValue *)self.object getValue:&value]; \
[self complete]; \
[inv setArgument:&value atIndex:idx + 2]; \
return YES; \
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
    return ^BOOL(ALCInvocationInjectorBlockArgs) {
        id value = [self valueAsObjectError:error];
        if (!value && *error) {
            return NO;
        }
        return [self injectValue:value ofType:type intoInvocation:inv atIndex:idx error:error];
    };
}

-(ALCInvocationInjectorBlock) invocationInjectorForArray {
    return ^BOOL(ALCInvocationInjectorBlockArgs) {
        id value = [self valueAsArrayError:error];
        if (!value && *error) {
            return NO;
        }
        return [self injectValue:value ofType:type intoInvocation:inv atIndex:idx error:error];
    };
}

#pragma mark - Locating methods

-(NSString *) methodNameFragmentForType:(ALCValueType) type {
    
    switch (type) {
            
            // Scalar types.
        case ALCValueTypeBool: return @"Bool";
        case ALCValueTypeChar: return @"Char";
        case ALCValueTypeCharPointer: return @"CharPointer";
        case ALCValueTypeDouble: return @"Double";
        case ALCValueTypeFloat: return @"Float";
        case ALCValueTypeInt: return @"Int";
        case ALCValueTypeLong: return @"Long";
        case ALCValueTypeLongLong: return @"LongLong";
        case ALCValueTypeShort: return @"Short";
        case ALCValueTypeUnsignedChar: return @"UnsignedChar";
        case ALCValueTypeUnsignedInt: return @"UnsignedInt";
        case ALCValueTypeUnsignedLong: return @"UnsignedLong";
        case ALCValueTypeUnsignedLongLong: return @"UnsignedLongLong";
        case ALCValueTypeUnsignedShort: return @"UnsignedShort";
        case ALCValueTypeCGSize: return @"CGSize";
        case ALCValueTypeCGPoint: return @"CGPoint";
        case ALCValueTypeCGRect: return @"CGRect";
            
            // Object types.
        case ALCValueTypeObject:return @"Object";
        case ALCValueTypeArray: return @"Array";
            
        default:
            throwException(AlchemicIllegalArgumentException, @"Cannot deduce a method name when type is unknown");
    }
}

-(nullable Method) methodWithPrefix:(NSString *) prefix forType:(ALCType *) type {
    
    SEL selector = NSSelectorFromString([prefix stringByAppendingString:[self methodNameFragmentForType:type.type]]);
    if (selector) {
        Method method = class_getInstanceMethod([self class], selector);
        if (method) {
            return method;
        }
    }
    
    throwException(AlchemicSelectorNotFoundException, @"Unable to find injector method: '%@' for %@", (selector ? NSStringFromSelector(selector) : @"<null>"), self);
    return NULL;
}

#pragma mark - Object value injections

/** Swift ivar? Currently returning no encoding.
 Fixing bug with missing retain when setting Swift ivars via object_setIvar(...) which causes EXC BAD ACCESS
 This code adds an extra retain.
 */
-(id) copyValueWithRetain:(id) value {
    CFTypeRef ptr = CFBridgingRetain(value);
#ifndef __clang_analyzer__ // Needed because we are violating ARC rules deliberately and need to hide the static analyzer    warnings.
    CFRetain(ptr);
#endif
    return CFBridgingRelease(ptr);
}

-(nullable NSArray *) valueAsArrayError:(NSError **) error {
    
    // Already an array.
    id value = self.object;
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    
    // Scalar types
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) {
        setError(@"Expected an object, found a scalar value");
        return nil;
    }
    
    // Must be an object but check for null.
    return value ? @[value] : @[];
}

-(nullable id) valueAsObjectError:(NSError **) error {
    
    id value = self.object;
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *values = value;
        switch (values.count) {
            case 0:
                return nil;
            case 1:
                return values[0];
            default:
                setError(@"Expected 1, got %lu", (unsigned long) values.count);
                return nil;
        }
    }
    
    // Scalar types
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) {
        setError(@"Expected an object, found a scalar value");
        return nil;
    }
    
    return value;
}

-(BOOL) injectValue:(nullable id) value ofType:(ALCType *) type intoObject:(id) obj variable:(Ivar) ivar error:(NSError **) error {
    
    if (!value && !type.isNillable) {
        setError(@"Nil value not allowed in this injection");
        return NO;
    }
    
    // Patch for Swift Ivars not being retained.
    // Swift ivar? Currently we detect this via checking it's encoding. Swift returns a null string.
    // This may be fragile, but appears to be the only choice at the moment.
    if (value && strlen(ivar_getTypeEncoding(ivar)) == 0) {
        value = [self copyValueWithRetain:value];
    }

    object_setIvar(obj, ivar, value);
    [self complete];
    return YES;
}

-(BOOL) injectValue:(nullable id) value ofType:(ALCType *) type intoInvocation:(NSInvocation *) inv atIndex:(NSInteger) index error:(NSError **) error {
    
    if (!value && !type.isNillable) {
        setError(@"Nil value not allowed at method argument");
        return NO;
    }
    
    if (value) {
        [self complete];
        id localValue = value;
        [inv setArgument:&localValue atIndex:index + 2];
    }
    return YES;
}

@end

NS_ASSUME_NONNULL_END
