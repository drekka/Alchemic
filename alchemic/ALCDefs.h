//
//  ALCDefs.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Notification sent after Alchemic has finished starting all singleton instances.
 */
FOUNDATION_EXPORT NSString *AlchemicDidFinishStarting;

/**
 Notification sent when Alchemic stores a new object in a factory.
 */
FOUNDATION_EXPORT NSString *AlchemicDidStoreObject;

/**
 Key for AlchemicDidStoreObject, contains the old value.
 */
FOUNDATION_EXPORT NSString *AlchemicDidStoreObjectUserInfoOldValue;

/**
 Key for AlchemicDidStoreObject, contains the new value.
 */
FOUNDATION_EXPORT NSString *AlchemicDidStoreObjectUserInfoNewValue;

