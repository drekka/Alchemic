//
//  ALCConstantValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCMacroArgument.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALCConstantValue : NSObject<ALCMacroArgument>

@property(nonatomic, strong, readonly) id value;

+(instancetype) constantValueWithValue:(id) value;

@end

NS_ASSUME_NONNULL_END