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

@implementation ALCConstant

-(bool) ready {
    return YES;
}

-(void)resolveWithStack:(NSMutableArray<ALCDependencyStackItem *> *)resolvingStack model:(id<ALCModel>)model{}

-(void)setObject:(id) object variable:(Ivar) variable {

    ALCTypeData *ivarTypeData = [ALCRuntime typeDataForIVar:variable];

    if (ivarTypeData.objcClass) {
        // Target is an id.
        [ALCRuntime setObject:object variable:variable withValue:[self objValue]];
    } else {
        // Set the value directly into the variable.
        CFTypeRef objRef = CFBridgingRetain(object);
        [self setMemoryLocation:(uint8_t *) objRef + ivar_getOffset(variable)];
        CFBridgingRelease(objRef);
    }
}

-(void) setMemoryLocation:(uint8_t *) memoryLocation {}

-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx {}

-(id) objValue {
    return nil;
}

@end

#define ALCConstantImplementation(name, type, toObject) \
id<ALCDependency> ALC ## name(type value) {return [[ALCConstant ## name alloc] initWithValue:value];} \
@implementation ALCConstant ## name {type _value;} \
-(instancetype) initWithValue:(type) value {self = [super init];if (self) {_value = value;}return self;} \
-(void) setMemoryLocation:(uint8_t *) memoryLocation {type *ivarPtr = (type *) memoryLocation;*ivarPtr = _value;} \
-(void) setInvocation:(NSInvocation *) inv argumentIndex:(int) idx {[inv setArgument:&_value atIndex:idx];} \
-(id) objValue {return toObject;} \
@end

ALCConstantImplementation(Int, int, @(_value))

//ALCConstantImplementation(Long, long, @(_value))
//ALCConstantImplementation(Float, float, @(_value))
//ALCConstantImplementation(CGRect, CGRect, [NSValue valueWithCGRect:_value])
//ALCConstantImplementation(Double, double, @(_value))
//ALCConstantImplementation(String, NSString *, _value)

NS_ASSUME_NONNULL_END

