//
//  ALCAlchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCContext;

/**
 This is the main access class for Alchemic.
 
 @discussion It's job is to start, stop and provide access to the main context.
 @see ALCContext
 */
@interface ALCAlchemic : NSObject

/**
 Returns the main context.

 @return The current instance of ALCContext.
 */
+(ALCContext *) mainContext;

@end
