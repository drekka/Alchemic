//
//  ALCConstantValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 16/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCValueSource.h"
#import "ALCAbstractValueSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A ALCArgument that returns a specific constant value every time it is asked for a value.
 
 @discussion Because this value source returns a a fixed value, it does not access the model and all the validation and post processing methods in it are empty.
 */
@interface ALCConstantValueSource : ALCAbstractValueSource

/**
 Default initializer.

 @param argumentType The expected type of the argument. This is used when deciding what to return from resolving.
 @param value The value that will be the constant value.

 @return An instance of this class.
 */
-(instancetype) initWithType:(Class)argumentType value:(id) value NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END