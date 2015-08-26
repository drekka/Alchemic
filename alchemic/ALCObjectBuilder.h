//
//  ALCObjectBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCBuilder.h"
@protocol ALCValueStorage;
@protocol ALCInstantiator;

NS_ASSUME_NONNULL_BEGIN

/**
 Base builder for creating objects.

 @discussion This class uses a variety of strategy classes to implement a variety of builder functions.
 */

@interface ALCObjectBuilder : NSObject<ALCBuilder>

-(instancetype) init NS_UNAVAILABLE;

/**
 defaul initializer.

 @param instantiator     An instance of ALCInstantiator which implements the code which builds objects and injects them with dependencies.
 @param forClass         The class of the object that the builder will create.

 @return An instance of a ALCBuilder.
 */

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END