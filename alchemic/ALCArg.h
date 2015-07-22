//
//  ACArg.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCValueSource;
#import "ALCValueDefMacro.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCArg : NSObject

@property (nonatomic, assign, readonly) Class argType;

-(instancetype) initWithArgType:(Class) argType NS_DESIGNATED_INITIALIZER;

+(instancetype) argWithType:(Class) argType macros:(id<ALCValueDefMacro>) firstMacro, ... NS_REQUIRES_NIL_TERMINATION;

-(void) addMacro:(id<ALCValueDefMacro>) macro;

-(id<ALCValueSource>) valueSource;

-(void) validate;

@end

NS_ASSUME_NONNULL_END
