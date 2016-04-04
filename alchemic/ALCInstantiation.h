//
//  ALCInstantiationResult.h
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCInstantiation : NSObject

@property (nonatomic, strong, readonly) id object;
@property (nonatomic, strong, readonly, nullable) ALCSimpleBlock completion;

+(instancetype) instantiationWithObject:(id) object completion:(nullable ALCSimpleBlock) completion;

@end

NS_ASSUME_NONNULL_END
