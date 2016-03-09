//
//  ALCObjectGenerator.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCResolvable.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALCObjectGenerator <ALCResolvable>

@property (nonatomic, strong, readonly) id object;

@property (nonatomic, assign, readonly) Class objectClass;

@property (nonatomic, strong, readonly) NSString *defaultName;

@property (nonatomic, strong, readonly) NSString *descriptionAttributes;

@end

NS_ASSUME_NONNULL_END
