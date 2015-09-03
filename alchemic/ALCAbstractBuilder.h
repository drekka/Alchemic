//
//  ALCObjectBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCBuilder.h"
#import "ALCAbstractResolvable.h"
#import "ALCInternalMacros.h"

@protocol ALCValueStorage;
@protocol ALCInstantiator;

NS_ASSUME_NONNULL_BEGIN

/**
 Base builder for creating objects.

 @discussion This class uses a variety of strategy classes to implement a variety of builder functions.
 */

@interface ALCAbstractBuilder : ALCAbstractResolvable<ALCBuilder>

/**
 Provides access to the instantiator used to build the objects that the builder represents.
 */
@property (nonatomic, strong, readonly) id<ALCInstantiator> instantiator;

/**
 Return a set of flags for configuring what macros are accepted by the builder.
 */
@property (nonatomic, assign, readonly) NSUInteger macroProcessorFlags;

hideInitializer(init);

/**
 defaul initializer.

 @param instantiator     An instance of ALCInstantiator which implements the code which builds objects and injects them with dependencies.
 @param forClass         The class of the object that the builder will create.

 @return An instance of a ALCBuilder.
 */

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass NS_DESIGNATED_INITIALIZER;

/**
 Called when we need to instantiate an object.
 
 @discussion This should in turn make a call to the insantiator being used by this builder.

 @return The objet built by the instantiator.
 */
-(id) instantiateObject;

@end

NS_ASSUME_NONNULL_END