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

@interface ALCConstant : NSObject<ALCDependency>
@end

#define ALCConstantHeader(name, type) \
id<ALCDependency> ALC ## name(type value); \
@interface ALCConstant ## name : ALCConstant \
-(instancetype) initWithValue:(type) value; \
@end

ALCConstantHeader(Int, int)

//ALCConstantHeader(Long, long)
//ALCConstantHeader(Float, float)
//ALCConstantHeader(CGRect, CGRect)
//ALCConstantHeader(Double, double)
//ALCConstantHeader(String, NSString *)

NS_ASSUME_NONNULL_END
