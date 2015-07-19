//
//  ACArg.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCValueSource;

NS_ASSUME_NONNULL_BEGIN

@interface ALCArg : NSObject

@property (nonatomic, assign, readonly) Class argType;
@property (nonatomic, strong, readonly) id<ALCValueSource> valueSource;

+(instancetype) argWithType:(Class) argType, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
