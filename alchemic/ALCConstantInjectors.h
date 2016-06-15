//
//  ALCConstantValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import UIKit;

#import <Alchemic/ALCAbstractConstantInjector.h>
#import <Alchemic/ALCInjector.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Internal macro for building @interface definitions.
 
 @param name The type name as used for name construction.
 @param type The base type to be used.
 */
#define ALCConstantHeader(name, type) \
id<ALCInjector> Ac ## name(type value); \
@interface ALCConstant ## name : ALCAbstractConstantInjector \
/** Unavailable initializer. */ \
-(instancetype) init NS_UNAVAILABLE; \
/** \
Factory method for creating instances. 
@param value the value to be stored as the constant.
*/ \
+(instancetype) constantValue:(type) value; \
@end

// Scalar types
ALCConstantHeader(Bool, BOOL)
ALCConstantHeader(Int, int)
ALCConstantHeader(Long, long)
ALCConstantHeader(Float, float)
ALCConstantHeader(Double, double)

// Structs
ALCConstantHeader(CGFloat, CGFloat)
ALCConstantHeader(CGSize, CGSize)
ALCConstantHeader(CGRect, CGRect)

// Object types.
ALCConstantHeader(String, NSString *)

#pragma mark - Nil value injector

#define AcNil [[ALCConstantNil alloc] init]
@interface ALCConstantNil : ALCAbstractConstantInjector
@end

NS_ASSUME_NONNULL_END
