//
//  ALCObjectGenerator.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCResolvable.h"

@class ALCInstantiation;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCInstantiator <ALCResolvable>

@property (nonatomic, strong, readonly) ALCInstantiation *instantiation;

@property (nonatomic, strong, readonly) NSString *defaultName;

@property (nonatomic, strong, readonly) NSString *descriptionAttributes;

@end

NS_ASSUME_NONNULL_END
