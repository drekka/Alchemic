//
//  ALCWithClass.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCModelSearchExpression.h"
#import "ALCValueDefMacro.h"
#import "ALCMacro.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Wraps an argument so that it can be conveniantly passed around.
 */
@interface ALCClass : NSObject<ALCModelSearchExpression, ALCValueDefMacro, ALCMacro>

@property (nonatomic, assign, readonly) Class aClass;

+(instancetype) withClass:(Class) aClass;

-(BOOL) isEqualToClass:(ALCClass *) withClass;

@end

NS_ASSUME_NONNULL_END