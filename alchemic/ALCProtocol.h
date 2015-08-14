//
//  ALCWithProtocol.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCModelSearchExpression.h"
#import "ALCMacro.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Wraps an argument so that it can be conveniantly passed around.
 
 @discussion ALCProtocol objects define search expressions for locating ALCBuilder instances in the model based on what protocols their values implement.
 */
@interface ALCProtocol : NSObject<ALCModelSearchExpression, ALCMacro>

/// The protocol to be used as a search expression.
@property (nonatomic, strong, readonly) Protocol *aProtocol;

/**
 Default initializer.
 
 @param aProtocol The protocol to search for.
 @return An instance of ALCProtocol.
 */
+(instancetype) withProtocol:(Protocol *) aProtocol;

/**
 Part of equals processing.
 
 @discussion Two ALCProtocol instances are considered to be equal if they represent the same protocol.
 
 @param withProtocol And instance of ALCProtocol to compare against.
 @return YES if both ALCProtocol instances represent the same protocol.
 */
-(BOOL) isEqualToProtocol:(ALCProtocol *) withProtocol;

@end

NS_ASSUME_NONNULL_END