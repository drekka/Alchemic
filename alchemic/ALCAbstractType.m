//
//  ALCAbstractType.m
//  Alchemic
//
//  Created by Derek Clarkson on 10/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractType.h"

#import <Alchemic/ALCInternalMacros.h>

@implementation ALCAbstractType

#pragma mark - Initializers

-(instancetype) init {
    self = [super init];
    if (self) {
        _type = ALCValueTypeUnknown;
    }
    return self;
}

-(NSString *) methodNameFragment {

    switch (_type) {

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
        case ALCValueTypeStruct: return @"Struct";

            // Object types.
        case ALCValueTypeObject:return @"Object";
        case ALCValueTypeArray: return @"Array";

        default:
            throwException(AlchemicIllegalArgumentException, @"Cannot deduce a method name when type is unknown");
    }
}

-(NSString *) description {
    switch (_type) {
        case ALCValueTypeUnknown: return @"[unknown type]";
        case ALCValueTypeBool: return @"scalar BOOL";
        case ALCValueTypeChar: return @"scalar char";
        case ALCValueTypeCharPointer: return @"scalar char *";
        case ALCValueTypeDouble: return @"scalar double";
        case ALCValueTypeFloat: return @"scalar float";
        case ALCValueTypeInt: return @"scalar int";
        case ALCValueTypeLong: return @"scalar long";
        case ALCValueTypeLongLong: return @"scalar long long";
        case ALCValueTypeShort: return @"scalar short";
        case ALCValueTypeUnsignedChar: return @"scalar unsigned char";
        case ALCValueTypeUnsignedInt: return @"scalar unsigned int";
        case ALCValueTypeUnsignedLong: return @"scalar unsigned long";
        case ALCValueTypeUnsignedLongLong: return @"scalar unsigned long long";
        case ALCValueTypeUnsignedShort: return @"scalar unsigned short";
        case ALCValueTypeStruct: return str(@"struct");
        case ALCValueTypeObject: return @"class NSObject *";
        case ALCValueTypeArray: return @"class NSArray *";
    }
}


@end
