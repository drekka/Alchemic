//
//  ALCInstantiator.h
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCResolvable.h"
@class ALCClassBuilder;

/**
 These objects are used to create instances and handle injections for a builder.
 */
@protocol ALCInstantiator <ALCResolvable>

/**
 If set, this block is called when the instantiators dependencies come online.
 */
@property (nonatomic, copy) ALCWhenAvailableBlock whenAvailable;

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

 @param classBuilder The class builder being asked to instantiate.
 @param arguments    An array of arguments being passed, mostly used in methods and initializers.
 @return An instance of the object that the builder represents.
 */
-(id) instantiateWithClassBuilder:(ALCClassBuilder *) classBuilder arguments:(NSArray *) arguments;

@end
