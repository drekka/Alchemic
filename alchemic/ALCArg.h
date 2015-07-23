//
//  ACArg.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCValueSourceFactory.h"
#import "ALCMacro.h"

@protocol ALCValueSource;
@protocol ALCValueDefMacro;

NS_ASSUME_NONNULL_BEGIN

@interface ALCArg : ALCValueSourceFactory<ALCMacro>

@property (nonatomic, assign, readonly) Class argType;

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithArgType:(Class) argType NS_DESIGNATED_INITIALIZER;

+(instancetype) argWithType:(Class) argType macros:(id<ALCValueDefMacro>) firstMacro, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
