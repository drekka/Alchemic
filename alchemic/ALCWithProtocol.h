//
//  ALCWithProtocol.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCModelSearchExpression.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Wraps an argument so that it can be conveniantly passed around.
 */
@interface ALCWithProtocol : NSObject<ALCModelSearchExpression>

@property (nonatomic, strong, readonly) Protocol *aProtocol;

+(instancetype) withProtocol:(Protocol *) aProtocol;

-(BOOL) isEqualToWithProtocol:(ALCWithProtocol *) withProtocol;

@end

NS_ASSUME_NONNULL_END