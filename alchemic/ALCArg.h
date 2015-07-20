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

+(instancetype) argWithType:(Class) argType expressions:(id) firstExpression, ... NS_REQUIRES_NIL_TERMINATION;

-(id<ALCValueSource>) valueSource;

@end

NS_ASSUME_NONNULL_END
