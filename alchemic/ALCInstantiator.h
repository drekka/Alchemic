//
//  ALCObjectGenerator.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCResolvable.h"
#import "ALCDefs.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALCInstantiator <ALCResolvable>

@property (nonatomic, strong, readonly) NSString *defaultModelKey;

@property (nonatomic, assign, readonly) ALCObjectCompletion objectCompletion;

-(id) createObject;


@end

NS_ASSUME_NONNULL_END
