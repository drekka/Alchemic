//
//  ALCValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

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
    ALCValueTypeCGSize,
    ALCValueTypeCGPoint,
    ALCValueTypeCGRect,

    // Object types.
    ALCValueTypeObject,
    ALCValueTypeArray
};

NS_ASSUME_NONNULL_BEGIN

/**
 Contains type information about an injection.
 */
@interface ALCType : NSObject

/**
 A string containing the type data for scalar types.
 */
@property (nonatomic, assign, readonly) ALCValueType type;

/**
 The name of a scalar type. ie. int, unsigned int, CGRect, CGSize, etc.
 */
@property (nonatomic, assign, nullable, readonly) NSString *scalarType;

/**
 The class if the type is an object type.
 */
@property (nonatomic, strong, nullable, readonly) Class objcClass;

/**
 Any protocols that the class implements.
 */
@property (nonatomic, strong, nullable, readonly) NSArray<Protocol *> *objcProtocols;

#pragma mark - Factory methods

/**
 Returns an instance of ALCType containing information about the type of the ivar.
 
 @param iVar The ivar to examine.
 
 @return An instance of ALCValue containing the type information.
 */
+(ALCType *) typeForIvar:(Ivar) ivar;

/**
 Factory method for analysing a passed encoding.
 
 @param encoding The encoding to analyse.
 */
+(instancetype) typeWithEncoding:(const char *) encoding;

/**
 Factory method which takes a class.

 @param aClass The class to base the type on.
 */
+(instancetype) typeWithClass:(Class) aClass;


@end

NS_ASSUME_NONNULL_END
