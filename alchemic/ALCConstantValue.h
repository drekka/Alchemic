//
//  ALCConstantValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCValueDefMacro.h"
#import "ALCMacro.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCConstantValue : NSObject<ALCValueDefMacro, ALCMacro>

@property(nonatomic, strong, readonly) id value;

+(instancetype) constantValue:(id) value;

@end

NS_ASSUME_NONNULL_END