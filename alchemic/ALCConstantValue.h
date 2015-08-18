//
//  ALCConstantValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCMacro.h"

/**
 ALCConstantValue objects store objects which are to be injected into a dependency.
 
 @discussion Instances of this class will always return the same value and do not search the model or any other source. Effectively providing constant values to the dependencies that reference them.
 */
@interface ALCConstantValue : NSObject<ALCMacro>

/**
 The constant value.
 */
@property(nonatomic, strong, readonly) id value;

/**
 Default initializer.
 
 @param value The constant value to be stored.s
 */
+(instancetype) constantValue:(id) value;

@end

