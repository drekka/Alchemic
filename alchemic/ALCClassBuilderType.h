//
//  ALCBuilderType.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
#import "ALCBuilderType.h"
@class ALCValueSourceFactory;

NS_ASSUME_NONNULL_BEGIN

/**
 A builder strategy that is used to build classes.
 */
@interface ALCClassBuilderType : NSObject<ALCBuilderType>

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithType:(Class) valueClass;

@end

NS_ASSUME_NONNULL_END
