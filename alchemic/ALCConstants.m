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

NS_ASSUME_NONNULL_BEGIN

#define ALCConstantFunctionImplementation(name, type) \
id<ALCDependency> ALC ## name(type value) { \
    return [[ALCConstant ## name alloc] initWithValue:value]; \
}

#define ALCConstantScalarImplementation(name, type, toObject) \
@implementation ALCConstant ## name { \
    type _value; \
} \
-(BOOL) ready { \
    return YES; \
} \
-(NSArray<ALCResolvable> *)dependencies { \
    return @[]; \
} \
-(instancetype) initWithValue:(type) value { \
    self = [super init]; \
    if (self) { \
        _value = value; \
    } \
    return self; \
} \
-(void)resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>)model{} \
-(void)setObject:(id) object variable:(Ivar) variable { \
    ALCTypeData *ivarTypeData = [ALCRuntime typeDataForIVar:variable]; \
    if (ivarTypeData.objcClass) { \
        [ALCRuntime setObject:object variable:variable withValue:toObject]; \
    } else { \
        CFTypeRef objRef = CFBridgingRetain(object); \
        type *ivarPtr = (type *) ((uint8_t *) objRef + ivar_getOffset(variable)); \
        *ivarPtr = _value; \
        CFBridgingRelease(objRef); \
    } \
} \
-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx { \
    [inv setArgument:&_value atIndex:idx]; \
} \
@end

#define ALCConstantObjectImplementation(name, type) \
@implementation ALCConstant ## name { \
type _value; \
} \
-(BOOL) ready { \
return YES; \
} \
-(NSArray<ALCResolvable> *)dependencies { \
return @[]; \
} \
-(instancetype) initWithValue:(type) value { \
self = [super init]; \
if (self) { \
_value = value; \
} \
return self; \
} \
-(void)resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>)model{} \
-(void)setObject:(id) object variable:(Ivar) variable { \
[ALCRuntime setObject:object variable:variable withValue:_value]; \
} \
-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx { \
[inv setArgument:&_value atIndex:idx]; \
} \
@end

// Scalar types
ALCConstantFunctionImplementation(Int, int)
ALCConstantScalarImplementation(Int, int, @(_value))
ALCConstantFunctionImplementation(CGRect, CGRect)
ALCConstantScalarImplementation(CGRect, CGRect, [NSValue valueWithCGRect:_value])

// Object types.
ALCConstantFunctionImplementation(String, NSString *)
ALCConstantObjectImplementation(String, NSString *)

//ALCConstantImplementation(Long, long, @(_value))
//ALCConstantImplementation(Float, float, @(_value))
//ALCConstantImplementation(CGRect, CGRect, [NSValue valueWithCGRect:_value])
//ALCConstantImplementation(Double, double, @(_value))

NS_ASSUME_NONNULL_END

