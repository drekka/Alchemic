//
//  ALCAbstractConstantValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import CoreGraphics;

#import "ALCConstantValueSource.h"
#import "ALCType.h"
#import "ALCValue.h"
#import "ALCInternalMacros.h"
#import "ALCAbstractValueSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCConstantValueSource : ALCAbstractValueSource
-(instancetype) initWithType:(ALCType *) type NS_UNAVAILABLE;
@end

@implementation ALCConstantValueSource {
    id _value;
}

id<ALCValueSource> AcNil() {
    ALCType *type = [ALCType typeWithClass:[NSObject class]];
    return [[ALCConstantValueSource alloc] initWithType:type value:nil];
}

id<ALCValueSource> AcObject(id value) {
    ALCType *type = [ALCType typeWithClass:[NSObject class]];
    return [[ALCConstantValueSource alloc] initWithType:type value:value];
}

id<ALCValueSource> AcString(NSString *value) {
    ALCType *type = [ALCType typeWithClass:[NSString class]];
    return [[ALCConstantValueSource alloc] initWithType:type value:value];
}

id<ALCValueSource> AcBool(BOOL value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcChar(char value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcCString(const char *value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcDouble(double value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcFloat(float value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcInt(int value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}
id<ALCValueSource> AcLong(long value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcLongLong(long long value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcShort(short value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcUnsignedChar(unsigned char value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcUnsignedInt(unsigned int value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcUnsignedLong(unsigned long value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcUnsignedLongLong(unsigned long long value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcUnsignedShort(unsigned short value) {
    return [ALCConstantValueSource scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

id<ALCValueSource> AcSize(float width, float height) {
    CGSize value = CGSizeMake(width, height);
    NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(__typeof(value))];
    ALCType *type = [ALCType typeWithEncoding:nsValue.objCType];
    return [[ALCConstantValueSource alloc] initWithType:type value:nsValue];
}

id<ALCValueSource> AcPoint(float x, float y) {
    CGPoint value = CGPointMake(x, y);
    NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(__typeof(value))];
    ALCType *type = [ALCType typeWithEncoding:nsValue.objCType];
    return [[ALCConstantValueSource alloc] initWithType:type value:nsValue];
}

id<ALCValueSource> AcRect(float x, float y, float width, float height) {
    CGRect value = CGRectMake(x, y, width, height);
    NSValue *nsValue = [NSValue valueWithBytes:&value objCType:@encode(__typeof(value))];
    ALCType *type = [ALCType typeWithEncoding:nsValue.objCType];
    return [[ALCConstantValueSource alloc] initWithType:type value:nsValue];
}

#pragma mark - Internal factory methods

+(instancetype) scalarValueSourceWithValue:(NSValue *) value {
    ALCType *type = [ALCType typeWithEncoding:value.objCType];
    return [[ALCConstantValueSource alloc] initWithType:type value:value];
}

#pragma mark - Value source methods

-(instancetype) initWithType:(ALCType *) type {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithType:(ALCType *) type value:(nullable id) value {
    self = [super initWithType:type];
    if (self) {
        _value = value;
    }
    return self;
}

-(nullable ALCValue *) value {
    return [ALCValue withObject:_value completion:NULL];
}

-(NSString *)resolvingDescription {
    return self.type.description;
}

@end

NS_ASSUME_NONNULL_END
