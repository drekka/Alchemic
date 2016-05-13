//
//  ALCConstantValue.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCConstants.h"
#import "NSObject+Alchemic.h"
#import "ALCRuntime.h"
#import "ALCInternalMacros.h"
#import "ALCTypeData.h"
#import "ALCModel.h"

NS_ASSUME_NONNULL_BEGIN

#define ALCConstantFunctionImplementation(name, type) \
id<ALCDependency> Ac ## name(type value) { \
    return [[ALCConstant ## name alloc] initWithValue:value]; \
}

#define ALCConstantImplementation(name, type, injectVariableCode) \
@implementation ALCConstant ## name { \
    type _value; \
} \
-(instancetype) init { \
    [self doesNotRecognizeSelector:@selector(init)]; \
    return nil; \
} \
-(instancetype) initWithValue:(type) value { \
    self = [super init]; \
    if (self) { \
        _value = value; \
    } \
    return self; \
} \
-(ALCSimpleBlock) setObject:(id) object variable:(Ivar) variable { \
    injectVariableCode \
    return NULL; \
} \
-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx { \
    [inv setArgument:&_value atIndex:idx]; \
} \
@end

#define ALCConstantScalarImplementation(name, type, toObject) \
ALCConstantImplementation(name, type, \
    ALCTypeData *ivarTypeData = [ALCRuntime typeDataForIVar:variable]; \
    if (ivarTypeData.objcClass) { \
        [ALCRuntime setObject:object variable:variable withValue:toObject]; \
    } else { \
        CFTypeRef objRef = CFBridgingRetain(object); \
        type *ivarPtr = (type *) ((uint8_t *) objRef + ivar_getOffset(variable)); \
        *ivarPtr = _value; \
        CFBridgingRelease(objRef); \
    } \
)

#define ALCConstantObjectImplementation(name, type) \
ALCConstantImplementation(name, type, \
    [ALCRuntime setObject:object variable:variable withValue:_value]; \
)

#pragma mark - Scalar types

ALCConstantFunctionImplementation(Bool, BOOL)
ALCConstantScalarImplementation(Bool, BOOL, @(_value))
ALCConstantFunctionImplementation(Int, int)
ALCConstantScalarImplementation(Int, int, @(_value))
ALCConstantFunctionImplementation(Long, long)
ALCConstantScalarImplementation(Long, long, @(_value))
ALCConstantFunctionImplementation(Float, float)
ALCConstantScalarImplementation(Float, float, @(_value))
ALCConstantFunctionImplementation(Double, double)
ALCConstantScalarImplementation(Double, double, @(_value))

ALCConstantFunctionImplementation(CGFloat, CGFloat)
ALCConstantScalarImplementation(CGFloat, CGFloat, @(_value))
ALCConstantFunctionImplementation(CGSize, CGSize)
ALCConstantScalarImplementation(CGSize, CGSize, [NSValue valueWithCGSize:_value])
ALCConstantFunctionImplementation(CGRect, CGRect)
ALCConstantScalarImplementation(CGRect, CGRect, [NSValue valueWithCGRect:_value])

#pragma mark - Object types

ALCConstantFunctionImplementation(String, NSString *)
ALCConstantObjectImplementation(String, NSString *)

NS_ASSUME_NONNULL_END

