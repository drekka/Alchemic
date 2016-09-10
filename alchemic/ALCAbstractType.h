//
//  ALCAbstractType.h
//  Alchemic
//
//  Created by Derek Clarkson on 10/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Enum of types for comparing when mapping.
 */
typedef NS_ENUM(NSUInteger, ALCValueType) {

    // Base unknown type
    ALCValueTypeUnknown,

    // Scalar types.
    ALCValueTypeBool,
    ALCValueTypeChar,
    ALCValueTypeCharPointer,
    ALCValueTypeDouble,
    ALCValueTypeFloat,
    ALCValueTypeInt,
    ALCValueTypeLong,
    ALCValueTypeLongLong,
    ALCValueTypeShort,
    ALCValueTypeUnsignedChar,
    ALCValueTypeUnsignedInt,
    ALCValueTypeUnsignedLong,
    ALCValueTypeUnsignedLongLong,
    ALCValueTypeUnsignedShort,
    ALCValueTypeStruct,

    // Object types.
    ALCValueTypeObject,
    ALCValueTypeArray
};

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractType : NSObject

/**
 A string containing the type data for scalar types.
 */
@property (nonatomic, assign) ALCValueType type;

@property (nonatomic, strong, readonly) NSString *methodNameFragment;

@end

NS_ASSUME_NONNULL_END
