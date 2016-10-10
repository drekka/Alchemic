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

@interface ALCValue(internal)
@property (nonatomic, strong, readonly, nullable) id valueAsObject;
@property (nonatomic, strong, readonly) NSArray *valueAsArray;
@end

@implementation ALCValue (Injection)

#pragma mark - Access points

-(nullable ALCVariableInjectorBlock) variableInjectorForType:(ALCValueType) type {
    Method method;
    SEL selector = NSSelectorFromString(str(@"variableInjectorFor%@", [self methodNameFragmentForType:type]));
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

-(nullable ALCInvocationInjectorBlock) invocationInjectorForType:(ALCValueType) type {
    Method method;
    SEL selector = NSSelectorFromString(str(@"invocationInjectorFor%@", [self methodNameFragmentForType:type]));
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
    return ^(ALCVariableInjectorBlockArgs) {
        [self injectObject:obj variable:ivar withValue:self.valueAsArray];
    };
}

-(ALCVariableInjectorBlock) variableInjectorForObject {
    return ^(ALCVariableInjectorBlockArgs) {
        [self injectObject:obj variable:ivar withValue:self.valueAsObject];
    };
}

#pragma mark - Method argument injectors

#define scalarMethodArgumentInjector(scalarType, typeName) \
-(ALCInvocationInjectorBlock) invocationInjectorFor ## typeName { \
return ^(ALCInvocationInjectorBlockArgs) { \
scalarType value; \
[(NSValue *)self.value getValue:&value]; \
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
        id value = self.valueAsObject;
        [ALCRuntime executeSimpleBlock:self.completion];
        [inv setArgument:&value atIndex:idx + 2];
    };
}

-(ALCInvocationInjectorBlock) invocationInjectorForArray {
    return ^(ALCInvocationInjectorBlockArgs) {
        NSArray *value = self.valueAsArray;
        [ALCRuntime executeSimpleBlock:self.completion];
        [inv setArgument:&value atIndex:idx + 2];
    };
}

#pragma mark - Internal

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


-(void) injectObject:(id) obj variable:(Ivar) ivar withValue:(id) value {
    
    // Patch for Swift Ivars not being retained.
    // Swift ivar? Currently we detect this via checking it's encoding. Swift returns a null string.
    // This may be fragile, but appears to be the only choice at the moment.
    if (value && strlen(ivar_getTypeEncoding(ivar)) == 0) {
        value = [self copyValueWithRetain:value];
    }
    
    object_setIvar(obj, ivar, value);
    [ALCRuntime executeSimpleBlock:self.completion];
}

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

-(NSArray *) valueAsArray {
    
    // Already an array.
    id value = self.value;
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    
    // Scalar types
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) {
        throwException(AlchemicInjectionException, @"Expected an object, found a scalar value");
    }
    
    // Must be an object but check for null.
    return value == [NSNull null] ? @[] : @[value];
}

-(nullable id) valueAsObject {
    
    id value = self.value;
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *values = value;
        switch (values.count) {
            case 0:
                return nil;
            case 1:
                return values[0];
            default:
                throwException(AlchemicIncorrectNumberOfValuesException, @"Expected 1, got %lu", (unsigned long) values.count);
        }
    }
    
    // Scalar types
    if ([value isKindOfClass:[NSValue class]] && ![value isKindOfClass:[NSNumber class]]) {
        throwException(AlchemicInjectionException, @"Expected an object, found a scalar value");
    }
    
    // Must be an object but check for null.
    return value == [NSNull null] ? nil : value;
}

@end

NS_ASSUME_NONNULL_END
