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
    ALCTypeUnknown,
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
    ALCTypeUnsignedShort,
    ALCTypeStruct,
    ALCTypeObject
};

NS_ASSUME_NONNULL_BEGIN

/**
 Simple class containing information about a type.
 */
@interface ALCTypeData : NSObject

/**
 A string containing the type data for scalar types.
 */
@property (nonatomic, assign, readonly) ALCType type;

/**
 The name of a struct. ie. CGRect, CGSize, etc.
 */
@property (nonatomic, assign, nullable, readonly) const char *scalarType;

/**
 The class if the type is an object type.
 */
@property (nonatomic, assign, nullable, readonly) Class objcClass;

/**
 Any protocols that the class implements.
 */
@property (nonatomic, strong, nullable, readonly) NSArray<Protocol *> *objcProtocols;

/**
 Factory method for analysing a passed encoding.
 
 @param encoding The encoding to analyse.
 */
+(instancetype) typeForEncoding:(const char *) encoding;

-(instancetype) init NS_UNAVAILABLE;

-(BOOL) canMapToTypeData:(ALCTypeData *) otherTypeData;

@end

NS_ASSUME_NONNULL_END
