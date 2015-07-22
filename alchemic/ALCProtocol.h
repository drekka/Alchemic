//
//  ALCWithProtocol.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCModelSearchExpression.h"
#import "ALCValueDefMacro.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Wraps an argument so that it can be conveniantly passed around.
 */
@interface ALCProtocol : NSObject<ALCModelSearchExpression, ALCValueDefMacro>

@property (nonatomic, strong, readonly) Protocol *aProtocol;

+(instancetype) withProtocol:(Protocol *) aProtocol;

-(BOOL) isEqualToWithProtocol:(ALCProtocol *) withProtocol;

@end

NS_ASSUME_NONNULL_END