//
//  ALCTypeData.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, ALCTypeMapping) {
    ALCTypeMappingScalarToScalar,
    ALCTypeMappingScalarToObject,
    ALCTypeMappingObjectToScalar,
    ALCTypeMappingObjectToObject
};

typedef NS_ENUM(NSUInteger, ALCType) {
    ALCTypeBool,
    ALCTypeChar,
    ALCTypeCharPointer,
    ALCTypeDouble,
    ALCTypeFloat,
    ALCTypeInt,
    ALCTypeLong,
    ALCTypeLongLong,
    ALCTypeShort,
    ALCTypeUnsignedChar,
    ALCTypeUnsignedInt,
    ALCTypeUnsignedLong,
    ALCTypeUnsignedLongLong,
    ALCTypeUnsignedShort
};

NS_ASSUME_NONNULL_BEGIN

/**
 Simple class containing information about a type.
 */
@interface ALCTypeData : NSObject

/**
 A string containing the type data for scalar types.
 */
@property (nonatomic, assign, nullable) const char *scalarType;

/**
 The class if the type is an object type.
 */
@property (nonatomic, assign, nullable) Class objcClass;

/**
 Any protocols that the class implements.
 */
@property (nonatomic, strong, nullable) NSArray<Protocol *> *objcProtocols;

-(instancetype) initWithEncoding:(const char *) encoding;

-(BOOL) canMapToTypeData:(ALCTypeData *) otherTypeData;

@end

NS_ASSUME_NONNULL_END
