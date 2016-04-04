//
//  ALCConstantValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import UIKit;

#import "ALCDependency.h"
#import "ALCConstant.h"

NS_ASSUME_NONNULL_BEGIN

#define ALCConstantHeader(name, type) \
id<ALCDependency> Ac ## name(type value); \
@interface ALCConstant ## name : NSObject<ALCDependency, ALCConstant> \
-(instancetype) initWithValue:(type) value; \
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

NS_ASSUME_NONNULL_END
