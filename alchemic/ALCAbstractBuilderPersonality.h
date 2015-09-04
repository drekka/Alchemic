//
//  ALCAbstractPersonality.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCBuilderPersonality.h"
@class ALCBuilder;
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Abstract super class of all builder personalities.
 */
@interface ALCAbstractBuilderPersonality : NSObject<ALCBuilderPersonality>

@end

NS_ASSUME_NONNULL_END
