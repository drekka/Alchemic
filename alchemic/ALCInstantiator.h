//
//  ALCInstantiator.h
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCResolvable.h"

/**
 These objects are used to create instances and handle injections for a builder.
 */
@protocol ALCInstantiator <ALCResolvable>

/**
 Used when builders are describing themselves.
 */
@property (nonatomic, strong, readonly) NSString *attributeText;

/**
 Returns the name to use for the builder.
 */
@property (nonatomic, strong, readonly) NSString *builderName;

/**
 Create an object using the passed arguments for any method arguments.

 @return An instance of the object that the builder represents.
 */
-(id) instantiateWithArguments:(NSArray *) arguments;

@end
