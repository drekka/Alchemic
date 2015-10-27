//
//  ALCWithName.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCModelSearchExpression.h"
#import "ALCSourceMacro.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Wraps an argument so that it can be conveniantly passed around.
 
 @discussion ALCName macros represent expressions for searching the model using the object names to locate candidate objects.
 */
@interface ALCName : NSObject<ALCModelSearchExpression, ALCSourceMacro>

/// The name to search for.
@property (nonatomic, strong, readonly) NSString *aName;

/**
Default initializer.
 
 @param aName The name to search for.
 */
+(instancetype) withName:(NSString *) aName;

/**
 Part of equals processing.
 
 @discussion ALCName instances are considered to be equal if they contain the same name.
 
 @param withName another ALCName object to test to see if they are equal.
 */
-(BOOL) isEqualToName:(ALCName *) withName;

@end

NS_ASSUME_NONNULL_END