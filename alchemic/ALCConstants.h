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

NS_ASSUME_NONNULL_BEGIN

#define ALCConstantHeader(name, type) \
id<ALCDependency> ALC ## name(type value); \
@interface ALCConstant ## name : NSObject<ALCDependency> \
-(instancetype) initWithValue:(type) value; \
@end

// Scalar types
ALCConstantHeader(Int, int)
ALCConstantHeader(CGRect, CGRect)

// Object types.
ALCConstantHeader(String, NSString *)

//ALCConstantHeader(Long, long)
//ALCConstantHeader(Float, float)
//ALCConstantHeader(Double, double)

NS_ASSUME_NONNULL_END
