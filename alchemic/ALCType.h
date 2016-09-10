//
//  ALCValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/ALCAbstractType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Contains type information about an injection.
 */
@interface ALCType : ALCAbstractType

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
