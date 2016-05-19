//
//  ALCDefs.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCContext;

/**
 Typedef for the simplest form of block. no args and no return.
 */
typedef void (^ALCSimpleBlock) (void);

#define ALCObjectCompletionArgs id object

/**
 Typedef for completion blocks.
 
 @param object The object that is completing.
 */
typedef void (^ALCObjectCompletion) (ALCObjectCompletionArgs);

/**
 Notification psoted after an object's completion is executed.
 */
FOUNDATION_EXPORT NSString *AlchemicDidCreateObject;

/**
 Key for the AlchemicDidCreateObject notification userInfo.
 */
FOUNDATION_EXPORT NSString *AlchemicDidCreateObjectUserInfoObject;

/**
 Notification sent after Alchemic has finished starting all singleton instances.
 */
FOUNDATION_EXPORT NSString *AlchemicDidFinishStarting;

